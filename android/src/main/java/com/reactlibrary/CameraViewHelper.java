package com.reactlibrary;

import android.view.ViewGroup;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.UIManagerModule;

import java.util.List;

public class CameraViewHelper {

  // Mount error event

  public static void emitMountErrorEvent(ViewGroup view, String error) {
    CameraMountErrorEvent event = CameraMountErrorEvent.obtain(view.getId(), error);
    ReactContext reactContext = (ReactContext) view.getContext();
    reactContext.getNativeModule(UIManagerModule.class).getEventDispatcher().dispatchEvent(event);
  }

  // Camera ready event

 public static void emitCameraReadyEvent(ViewGroup view) {
   CameraReadyEvent event = CameraReadyEvent.obtain(view.getId());
   ReactContext reactContext = (ReactContext) view.getContext();
   reactContext.getNativeModule(UIManagerModule.class).getEventDispatcher().dispatchEvent(event);
 }

  // Prediction made event

  public static void emitPredictionMadeEvent(
      ViewGroup view,
      List<Classifier.Recognition>  result) {

    PredictionMadeEvent event = PredictionMadeEvent.obtain(
        view.getId(),
        result
    );

    ReactContext reactContext = (ReactContext) view.getContext();
    reactContext.getNativeModule(UIManagerModule.class).getEventDispatcher().dispatchEvent(event);
  }

  // Utilities

  // public static int getCorrectCameraRotation(int rotation, int facing) {
  //   if (facing == CameraView.FACING_FRONT) {
  //     return (rotation - 90 + 360) % 360;
  //   } else {
  //     return (-rotation + 90 + 360) % 360;
  //   }
  // }


}