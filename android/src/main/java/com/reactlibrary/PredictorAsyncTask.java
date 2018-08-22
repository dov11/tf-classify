package com.reactlibrary;

import java.util.List;

import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Matrix;
import com.reactlibrary.tensorflow.utils.ImageUtils;
import android.util.Log;

public class PredictorAsyncTask extends android.os.AsyncTask<Void, Void, List<Classifier.Recognition>> {

  private PredictorAsyncTaskDelegate mDelegate;
  private Classifier mClassifier;
  private byte[] mImageData;
  private int mWidth;
  private int mHeight;
  private int mSensorOrientation;
  private int[] rgbBytes = null;
  private Runnable imageConverter;

  private Bitmap rgbFrameBitmap = null;
  private Bitmap croppedBitmap = null;

  private Matrix frameToCropTransform;
  private Matrix cropToFrameTransform;

  private static final int INPUT_SIZE = 224;

  protected int[] getRgbBytes() {
    imageConverter.run();
    return rgbBytes;
  }

  public PredictorAsyncTask(PredictorAsyncTaskDelegate delegate, Classifier classifier, byte[] imageData, int width,
      int height, int sensorOrientation) {
    mDelegate = delegate;
    mClassifier = classifier;
    mImageData = imageData;
    mWidth = width;
    mHeight = height;
    mSensorOrientation = sensorOrientation;
  }

  @Override
  protected List<Classifier.Recognition> doInBackground(Void... ignored) {
    if (isCancelled() || mDelegate == null || mClassifier == null) {
      return null;
    }
    if (rgbBytes == null) {
      rgbBytes = new int[mWidth * mHeight];
    }
    rgbFrameBitmap = Bitmap.createBitmap(mWidth, mHeight, Config.ARGB_8888);
    croppedBitmap = Bitmap.createBitmap(INPUT_SIZE, INPUT_SIZE, Config.ARGB_8888);
    frameToCropTransform = ImageUtils.getTransformationMatrix(mWidth, mHeight, INPUT_SIZE, INPUT_SIZE, mSensorOrientation, true);
    cropToFrameTransform = new Matrix();
    frameToCropTransform.invert(cropToFrameTransform);
    imageConverter = new Runnable() {
      @Override
      public void run() {
        ImageUtils.convertYUV420SPToARGB8888(mImageData, mWidth, mHeight, rgbBytes);
      }
    };
    ImageUtils.convertYUV420SPToARGB8888(mImageData, mWidth, mHeight, rgbBytes);
    rgbFrameBitmap.setPixels(getRgbBytes(), 0, mWidth, 0, 0, mWidth, mHeight);
    final Canvas canvas = new Canvas(croppedBitmap);
    canvas.drawBitmap(rgbFrameBitmap, frameToCropTransform, null);
    // ImageUtils.saveBitmap(croppedBitmap);
    return mClassifier.recognizeImage(croppedBitmap);
  }

  @Override
  protected void onPostExecute(List<Classifier.Recognition> results) {
    super.onPostExecute(results);

    if (results != null) {
      mDelegate.onPredictionMade(results);
    }
    mDelegate.onPredictorTaskCompleted();
  }
}