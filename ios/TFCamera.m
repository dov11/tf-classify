#import "TFCamera.h"

@interface TFCamera ()
@property (nonatomic, weak) RCTBridge *bridge;
@end

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


//     NSError* error = nil;
//     self.bridge = bridge;
//     self.session = [AVCaptureSession new];
//     self.session.sessionPreset = AVCaptureSessionPreset640x480;

// //   AVCaptureDeviceInput* deviceInput =
// //       [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

//   if (error != nil) {
//     NSLog(@"Failed to initialize AVCaptureDeviceInput. Note: This app doesn't work with simulator");
//     assert(NO);
//   }

// //   if ([session canAddInput:deviceInput]) [session addInput:deviceInput];

// //   videoDataOutput = [AVCaptureVideoDataOutput new];

// //   NSDictionary* rgbOutputSettings =
// //       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
// //                                   forKey:(id)kCVPixelBufferPixelFormatTypeKey];
// //   [videoDataOutput setVideoSettings:rgbOutputSettings];
// //   [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
// //   videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
// //   [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];

// //   if ([session canAddOutput:videoDataOutput]) [session addOutput:videoDataOutput];
// //   [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

// //   previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
// //   [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
// //   [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
// //   CALayer* rootLayer = [previewView layer];
// //   [rootLayer setMasksToBounds:YES];
// //   [previewLayer setFrame:[rootLayer bounds]];
// //   [rootLayer addSublayer:previewLayer];
//     [self.session startRunning];
// //   if (error) {
// //     NSString* title = [NSString stringWithFormat:@"Failed with error %d", (int)[error code]];
// //     UIAlertController* alertController =
// //         [UIAlertController alertControllerWithTitle:title
// //                                             message:[error localizedDescription]
// //                                      preferredStyle:UIAlertControllerStyleAlert];
// //     UIAlertAction* dismiss =
// //         [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
// //     [alertController addAction:dismiss];
// //     [self presentViewController:alertController animated:YES completion:nil];
// //     [self teardownAVCapture];
// //   }
// return self;