package com.reactlibrary;

import android.os.Build;

import com.facebook.react.bridge.*;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;

public class TFCameraModule extends ReactContextBaseJavaModule {
  private ScopedContext mScopedContext;
  public TFCameraModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mScopedContext = new ScopedContext(reactContext);
  }

  public ScopedContext getScopedContext() {
    return mScopedContext;
  }

  @Override
  public String getName() {
    return "TFCameraModule";
  }

//   @ReactMethod
//     public void pausePreview(final int viewTag) {
//         final ReactApplicationContext context = getReactApplicationContext();
//         UIManagerModule uiManager = context.getNativeModule(UIManagerModule.class);
//         uiManager.addUIBlock(new UIBlock() {
//             @Override
//             public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
//                 final TFCameraView cameraView;
                
//                 try {
//                     cameraView = (TFCameraView) nativeViewHierarchyManager.resolveView(viewTag);
//                     if (cameraView.isCameraOpened()) {
//                         cameraView.pausePreview();
//                     }
//                 } catch (Exception e) {
//                     e.printStackTrace();
//                 }
//             }
//         });
//     }
    
//     @ReactMethod
//     public void resumePreview(final int viewTag) {
//         final ReactApplicationContext context = getReactApplicationContext();
//         UIManagerModule uiManager = context.getNativeModule(UIManagerModule.class);
//         uiManager.addUIBlock(new UIBlock() {
//             @Override
//             public void execute(NativeViewHierarchyManager nativeViewHierarchyManager) {
//                 final TFCameraView cameraView;
                
//                 try {
//                     cameraView = (TFCameraView) nativeViewHierarchyManager.resolveView(viewTag);
//                     if (cameraView.isCameraOpened()) {
//                         cameraView.resumePreview();
//                     }
//                 } catch (Exception e) {
//                     e.printStackTrace();
//                 }
//             }
//         });
//     }


}