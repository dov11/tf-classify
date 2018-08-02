
#import "TFCamera.h"
#import "RNTTfCameraManager.h"
#import <React/RCTViewManager.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
#import <React/RCTEventDispatcher.h>

// @interface RNTTfCamera : RCTViewManager
// @end

@implementation RNTTfCameraManager

// - (dispatch_queue_t)methodQueue
// {
//     return dispatch_get_main_queue();
// }
RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onPredictionMade, RCTDirectEventBlock);

- (UIView *)view
{
  return [[TFCamera alloc] initWithBridge:self.bridge];
}

RCT_CUSTOM_VIEW_PROPERTY(predictionEnabled, BOOL, TFCamera)
{
    [view updatePredicting:json];
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onPredictionMade"];
}

@end
  