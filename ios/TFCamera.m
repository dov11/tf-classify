#import "TFCamera.h"

@implementation TFCamera
- (id)initWithBridge:(RCTBridge *)bridge
{
    if ((self = [super init])) {
        self.bridge = bridge;
        self.session = [AVCaptureSession new];
        self.sessionQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
#if !(TARGET_IPHONE_SIMULATOR)
        self.previewLayer =
        [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.needsDisplayOnBoundsChange = YES;
#endif
        self.paused = NO;
        // [self changePreviewOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [self initializeCaptureSessionInput];
        [self startSession];
        // [[NSNotificationCenter defaultCenter] addObserver:self
        //                                          selector:@selector(orientationChanged:)
        //                                              name:UIDeviceOrientationDidChangeNotification
        //                                            object:nil];
    }
    return self;
}

@end