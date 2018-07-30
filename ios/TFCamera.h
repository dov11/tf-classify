#import <React/RCTViewManager.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>

#include <vector>

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"

@class TFCamera;

@interface TFCamera : UIView <AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic) IBOutlet UIView* previewView;
@property(nonatomic) AVCaptureVideoPreviewLayer* previewLayer;
@property(nonatomic) AVCaptureVideoDataOutput* videoDataOutput;
@property(nonatomic) dispatch_queue_t videoDataOutputQueue;
@property(nonatomic, strong) AVCaptureDeviceInput *videoCaptureDeviceInput;
@property(nonatomic) UIView* flashView;
@property(nonatomic) BOOL isUsingFrontFacingCamera;
// @property(nonatomic) NSMutableDictionary* oldPredictionValues;
// @property(nonatomic) NSMutableArray* labelLayers;
@property(nonatomic) AVCaptureSession* session;
  NSMutableArray* labelLayers;
  std::vector<std::string> labels;
  std::unique_ptr<tflite::FlatBufferModel> model;
  tflite::ops::builtin::BuiltinOpResolver resolver;
  std::unique_ptr<tflite::Interpreter> interpreter;
  - (id)initWithBridge:(RCTBridge *)bridge;
@end