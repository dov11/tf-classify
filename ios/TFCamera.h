#import <React/RCTViewManager.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>

#include <vector>

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"

@class TFCamera;

@interface TFCamera : UIView <AVCaptureVideoDataOutputSampleBufferDelegate> {
 IBOutlet UIView* previewView;
 AVCaptureVideoPreviewLayer* previewLayer;
 AVCaptureVideoDataOutput* videoDataOutput;
 dispatch_queue_t videoDataOutputQueue;
 AVCaptureDeviceInput *videoCaptureDeviceInput;
 UIView* flashView;
 BOOL isUsingFrontFacingCamera;
  NSMutableDictionary* oldPredictionValues;
 AVCaptureSession* session;
  NSMutableArray* labelLayers;
  std::vector<std::string> labels;
  std::unique_ptr<tflite::FlatBufferModel> model;
  tflite::ops::builtin::BuiltinOpResolver resolver;
  std::unique_ptr<tflite::Interpreter> interpreter;
}
  - (id)initWithBridge:(RCTBridge *)bridge;
@end