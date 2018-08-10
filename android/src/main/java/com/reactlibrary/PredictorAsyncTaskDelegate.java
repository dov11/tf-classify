package com.reactlibrary;

import android.util.SparseArray;

import java.util.List;

public interface PredictorAsyncTaskDelegate {
  void onPredictionMade(List<Classifier.Recognition> results);
  void onPredictorTaskCompleted();
}