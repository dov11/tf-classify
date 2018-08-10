package com.reactlibrary;

import android.support.v4.util.Pools;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import android.util.Log;

import java.util.List;


public class PredictionMadeEvent extends Event<PredictionMadeEvent> {

  private static final Pools.SynchronizedPool<PredictionMadeEvent> EVENTS_POOL =
      new Pools.SynchronizedPool<>(3);


  private List<Classifier.Recognition> mResult;

  private PredictionMadeEvent() {}

  public static PredictionMadeEvent obtain(
      int viewTag,
      List<Classifier.Recognition> result) {
    PredictionMadeEvent event = EVENTS_POOL.acquire();
    if (event == null) {
      event = new PredictionMadeEvent();
    }
    event.init(viewTag, result);
    return event;
  }

  private void init(
      int viewTag,
      List<Classifier.Recognition> result) {
    super.init(viewTag);
    mResult = result;
  }

  @Override
  public String getEventName() {
    return CameraViewManager.Events.EVENT_ON_PREDICTION_MADE.toString();
}


  @Override
  public void dispatch(RCTEventEmitter rctEventEmitter) {
    rctEventEmitter.receiveEvent(getViewTag(), getEventName(), serializeEventData());
  }

  private WritableMap serializeEventData() {
    WritableMap resultsMap = Arguments.createMap();
    for (Classifier.Recognition recognition : mResult) {
      String title = recognition.getTitle();
      Float confidence = recognition.getConfidence();
      resultsMap.putDouble(title, confidence);
    }

    WritableMap event = Arguments.createMap();
    event.putString("type", "predictions");
    event.putMap("data", resultsMap);
    event.putInt("target", getViewTag());
    Log.i("TFcamera", "event" + event);
    return event;
  }
}