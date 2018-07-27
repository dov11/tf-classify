#import <React/RCTViewManager.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>

@class TFCamera;

@interface TFCamera : UIView <AVCaptureVideoDataOutputSampleBufferDelegate>
@property(nonatomic) IBOutlet UIView* previewView;
@property(nonatomic) AVCaptureVideoPreviewLayer* previewLayer;
@property(nonatomic) AVCaptureVideoDataOutput* videoDataOutput;
@property(nonatomic) dispatch_queue_t videoDataOutputQueue;
@property(nonatomic) UIView* flashView;
@property(nonatomic) BOOL isUsingFrontFacingCamera;
// @property(nonatomic) NSMutableDictionary* oldPredictionValues;
// @property(nonatomic) NSMutableArray* labelLayers;
@property(nonatomic) AVCaptureSession* session;
  - (id)initWithBridge:(RCTBridge *)bridge;
@end
  