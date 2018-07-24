
package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.reactlibrary.tensorflow.ClassifierActivity;

public class RNTfClassifyModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  public static final int MODEL_RECOGNIZE_REQUEST = 61114;
  public static Callback mCallback;

  public RNTfClassifyModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  private final ActivityEventListener mActivityEventListener = new ActivityEventListener() {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        String error = null;
        WritableArray writableArray = null;
        if (requestCode != MODEL_RECOGNIZE_REQUEST) {
            error = "Wrong requestCode code: " + requestCode;
        }else if (resultCode != Activity.RESULT_OK) {
            error = "Wrong result code: " + resultCode;
        } else  {
            writableArray = new WritableNativeArray();
            String [] imagePaths = data.getStringArrayExtra("ImagesPaths");
            for (String path: imagePaths) {
                writableArray.pushString(path);
            }
        }
        mCallback.invoke(error, writableArray);
    }
    @Override
    public void onNewIntent(Intent intent) {

    }
};

  @Override
  public String getName() {
    return "RNTfClassify";
  }

  @ReactMethod
    public void createShootWithCompletionHandler(Callback callback) {
        mCallback = callback;
        Activity activity = getCurrentActivity();
        if (activity == null) {
            return;
        }

        Intent cameraIntent = new Intent(activity, ClassifierActivity.class);
        if (cameraIntent.resolveActivity(activity.getPackageManager()) != null) {
            activity.startActivityForResult(cameraIntent, MODEL_RECOGNIZE_REQUEST);
        }
    }
}