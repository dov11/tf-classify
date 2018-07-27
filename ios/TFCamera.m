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
//        self.sessionQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL);
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
#if !(TARGET_IPHONE_SIMULATOR)
        self.previewLayer =
        [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.needsDisplayOnBoundsChange = YES;
#endif

        [self initializeCaptureSessionInput];
//         self.videoDataOutput = [AVCaptureVideoDataOutput new];

//   NSDictionary* rgbOutputSettings =
//       [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
//                                   forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//   [self.videoDataOutput setVideoSettings:rgbOutputSettings];
//   [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
//   self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
//   [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];

//   if ([self.session canAddOutput:self.videoDataOutput]) [self.session addOutput:self.videoDataOutput];
//   [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

//   self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//   [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
//   [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
//   CALayer* rootLayer = [self.previewView layer];
//   [rootLayer setMasksToBounds:YES];
//   [self.previewLayer setFrame:[rootLayer bounds]];
//   [rootLayer addSublayer:self.previewLayer];
//        self.paused = NO;
        // [self changePreviewOrientation:[UIApplication sharedApplication].statusBarOrientation];
//        [self initializeCaptureSessionInput];
        [self.session startRunning];
        // [[NSNotificationCenter defaultCenter] addObserver:self
        //                                          selector:@selector(orientationChanged:)
        //                                              name:UIDeviceOrientationDidChangeNotification
        //                                            object:nil];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.previewLayer.frame = self.bounds;
    [self setBackgroundColor:[UIColor blackColor]];
    [self.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
    [self insertSubview:view atIndex:atIndex + 1];
    [super insertReactSubview:view atIndex:atIndex];
    return;
}

- (void)removeReactSubview:(UIView *)subview
{
    [subview removeFromSuperview];
    [super removeReactSubview:subview];
    return;
}

- (void)removeFromSuperview
{
//     [self stopRunning];
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)initializeCaptureSessionInput
{
//     if (self.videoCaptureDeviceInput.device.position == self.presetCamera) {
//         return;
//     }
    __block UIInterfaceOrientation interfaceOrientation;
    
    void (^statusBlock)() = ^() {
        interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    };
    if ([NSThread isMainThread]) {
        statusBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), statusBlock);
    }
    
//     AVCaptureVideoOrientation orientation = [RNCameraUtils videoOrientationForInterfaceOrientation:interfaceOrientation];
    dispatch_async(self.videoDataOutputQueue, ^{
        [self.session beginConfiguration];
        
        NSError *error = nil;
        AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput* deviceInput =
                [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        if (error) {
            RCTLog(@"%s: %@", __func__, error);
            return;
        }
        
        [self.session removeInput:self.videoCaptureDeviceInput];
        if ([self.session canAddInput:deviceInput]) {
            [self.session addInput:deviceInput];
            
            self.videoCaptureDeviceInput = deviceInput;
        //     [self.previewLayer.connection setVideoOrientation:orientation];
        }
        
        [self.session commitConfiguration];
    });
}

@end