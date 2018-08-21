package com.reactlibrary;

import com.facebook.react.bridge.*;
import com.facebook.react.uimanager.ThemedReactContext;
import com.google.android.cameraview.CameraView;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.pm.PackageManager;
import android.view.View;
import android.os.AsyncTask;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.graphics.Color;
import android.content.res.AssetManager;
import android.util.Log;

import java.util.*;

public class TFCameraView extends CameraView implements LifecycleEventListener, PredictorAsyncTaskDelegate {
  private ThemedReactContext mThemedReactContext;

  private Classifier mClassifier;

  private boolean mIsPaused = false;
  private boolean mIsNew = true;
  private boolean mPredictionEnabled = false;

  public volatile boolean predictorLock = false;

  private static final int INPUT_SIZE = 224;

  // private static final String MODEL_FILE = "mobilenet_quant_v1_224.tflite";
  // private static final String LABEL_FILE = "retrained_labels.txt";
  private static final String MODEL_FILE = "file:///android_asset/retrained_graph.pb";
  private static final String LABEL_FILE =
      "file:///android_asset/retrained_labels.txt";
  private static final int IMAGE_MEAN = 128;
  private static final float IMAGE_STD = 128;
  private static final String INPUT_NAME = "input";
  private static final String OUTPUT_NAME = "final_result";

  private static final boolean MAINTAIN_ASPECT = true;

  public TFCameraView(ThemedReactContext themedReactContext) {
    super(themedReactContext, true);
    mThemedReactContext = themedReactContext;
    themedReactContext.addLifecycleEventListener(this);

    addCallback(new Callback() {
      // @Override
      // public void onCameraOpened(CameraView cameraView) {
      // Log.i("TFcamera", "cameraOpened");
      // CameraViewHelper.emitCameraReadyEvent(cameraView);
      // }

      @Override
      public void onMountError(CameraView cameraView) {
        CameraViewHelper.emitMountErrorEvent(cameraView,
            "Camera view threw an error - component could not be rendered.");
      }

      @Override
      public void onFramePreview(CameraView cameraView, byte[] data, int width, int height, int rotation) {
        // int correctRotation = CameraViewHelper.getCorrectCameraRotation(rotation,
        // getFacing());
        boolean willCallPredictorTask = mPredictionEnabled && !predictorLock
            && cameraView instanceof PredictorAsyncTaskDelegate;
        if (!willCallPredictorTask) {
          return;
        }

        if (data.length < (1.5 * width * height)) {
          return;
        }

        if (willCallPredictorTask) {
          Log.i("TFcamera", "will call");
          predictorLock = true;
          PredictorAsyncTaskDelegate delegate = (PredictorAsyncTaskDelegate) cameraView;
          new PredictorAsyncTask(delegate, mClassifier, data, width, height // , correctRotation
          ).execute();
        }
      }
    });
  }

  @Override
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
    Log.i("TFcamera", "onLayout");
    View preview = getView();
    if (null == preview) {
      return;
    }
    if (null == preview) {
      return;
    }
    this.setBackgroundColor(Color.BLACK);
    int width = right - left;
    int height = bottom - top;
    preview.layout(0, 0, width, height);
//    float width = right - left;
//    float height = bottom - top;
//    float ratio = getAspectRatio().toFloat();
//    int orientation = getResources().getConfiguration().orientation;
//    int correctHeight;
//    int correctWidth;
//    this.setBackgroundColor(Color.BLACK);
//    if (orientation == android.content.res.Configuration.ORIENTATION_LANDSCAPE) {
//      if (ratio * height < width) {
//        correctHeight = (int) (width / ratio);
//        correctWidth = (int) width;
//      } else {
//        correctWidth = (int) (height * ratio);
//        correctHeight = (int) height;
//      }
//    } else {
//      if (ratio * width > height) {
//        correctHeight = (int) (width * ratio);
//        correctWidth = (int) width;
//      } else {
//        correctWidth = (int) (height / ratio);
//        correctHeight = (int) height;
//      }
//    }
//    int paddingX = (int) ((width - correctWidth) / 2);
//    int paddingY = (int) ((height - correctHeight) / 2);
//    preview.layout(paddingX, paddingY, correctWidth + paddingX, correctHeight + paddingY);
  }

  @SuppressLint("all")
  @Override
  public void requestLayout() {
    // React handles this for us, so we don't need to call super.requestLayout();
  }

  @Override
  public void onViewAdded(View child) {
    if (this.getView() == child || this.getView() == null) {
      return;
    }
    this.removeView(this.getView());
    this.addView(this.getView(), 0);
  }

  private void setupClassifier() {
    AssetManager mngr = mThemedReactContext.getAssets();
    mClassifier = TensorFlowImageClassifier.create(mngr, MODEL_FILE,
    LABEL_FILE,
    INPUT_SIZE,
    IMAGE_MEAN,
    IMAGE_STD,
    INPUT_NAME,
    OUTPUT_NAME);
  }

  public void enablePrediction(boolean predictionEnabled) {
    if (predictionEnabled && mClassifier == null) {
      setupClassifier();
    }
    this.mPredictionEnabled = predictionEnabled;
    setScanning(mPredictionEnabled);
  }

  @Override
  public void onPredictionMade(List<Classifier.Recognition> results) {
    if (!mPredictionEnabled) {
    return;
    }

    CameraViewHelper.emitPredictionMadeEvent(this, results);
  }

  @Override
  public void onHostResume() {
    if (hasCameraPermissions()) {
      if ((mIsPaused && !isCameraOpened()) || mIsNew) {
        mIsPaused = false;
        mIsNew = false;
        start();
      }
    } else {
      CameraViewHelper.emitMountErrorEvent(this, "Camera permissions not granted - component could not be rendered.");
    }
  }

  @Override
  public void onHostPause() {
    if (!mIsPaused && isCameraOpened()) {
      mIsPaused = true;
      stop();
    }
  }

  @Override
  public void onHostDestroy() {
    if (mClassifier != null) {
      mClassifier.close();
    }
    stop();
    mThemedReactContext.removeLifecycleEventListener(this);
  }

  @Override
  public void onPredictorTaskCompleted() {
    predictorLock = false;
  }

  private boolean hasCameraPermissions() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      int result = ContextCompat.checkSelfPermission(getContext(), Manifest.permission.CAMERA);
      return result == PackageManager.PERMISSION_GRANTED;
    } else {
      return true;
    }
  }

}