package com.reactlibrary;

import android.support.annotation.Nullable;

import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class CameraViewManager extends ViewGroupManager<TFCameraView> {
  public enum Events {
    EVENT_CAMERA_READY("onCameraReady"),
    EVENT_ON_MOUNT_ERROR("onMountError"),
    EVENT_ON_PREDICTION_MADE("onPredictionMade");

    private final String mName;

    Events(final String name) {
      mName = name;
    }

    @Override
    public String toString() {
      return mName;
    }
  }
  private static final String REACT_CLASS = "TfCamera";

  @Override
  @Nullable
  public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
    MapBuilder.Builder<String, Object> builder = MapBuilder.builder();
    for (Events event : Events.values()) {
      builder.put(event.toString(), MapBuilder.of("registrationName", event.toString()));
    }
    return builder.build();
  }

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public void onDropViewInstance(TFCameraView view) {
    view.stop();
    super.onDropViewInstance(view);
  }

  @Override
  protected TFCameraView createViewInstance(ThemedReactContext themedReactContext) {
    return new TFCameraView(themedReactContext);
  }

  @ReactProp(name = "predictionEnabled")
  public void predictionEnabled(TFCameraView view, boolean predictionEnabled) {
    view.enablePrediction(predictionEnabled);
  }
  @ReactProp(name = "autoFocus")
  public void setAutoFocus(TFCameraView view, boolean autoFocus) {
    view.setAutoFocus(autoFocus);
  }
}