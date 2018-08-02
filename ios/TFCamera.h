#import <AVFoundation/AVFoundation.h>
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <UIKit/UIKit.h>

#include <vector>

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"

@class TFCamera;

@interface TFCamera : UIView <AVCaptureVideoDataOutputSampleBufferDelegate> {
  IBOutlet UIView *previewView;
  AVCaptureVideoPreviewLayer *previewLayer;
  AVCaptureVideoDataOutput *videoDataOutput;
  dispatch_queue_t videoDataOutputQueue;
  AVCaptureDeviceInput *videoCaptureDeviceInput;
  UIView *flashView;
  BOOL isUsingFrontFacingCamera;
  NSMutableDictionary *oldPredictionValues;
  AVCaptureSession *session;
  NSMutableArray *labelLayers;
  std::vector<std::string> labels;
  std::unique_ptr<tflite::FlatBufferModel> model;
  tflite::ops::builtin::BuiltinOpResolver resolver;
  std::unique_ptr<tflite::Interpreter> interpreter;
  double total_latency;
  int total_count;
  int output_size;
}
- (id)initWithBridge:(RCTBridge *)bridge;
- (void)onPredictionMade:(NSDictionary *)event;
- (void)updatePredicting:(id)json;
@end