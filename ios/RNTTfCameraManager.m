
#import "TFCamera.h"
#import "RNTTfCameraManager.h"
#import <React/RCTViewManager.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>

// @interface RNTTfCamera : RCTViewManager
// @end

@implementation RNTTfCameraManager

// - (dispatch_queue_t)methodQueue
// {
//     return dispatch_get_main_queue();
// }
RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[TfCamera alloc] initWithBridge:self.bridge];
}

@end
  