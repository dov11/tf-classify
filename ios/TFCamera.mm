#import "TFCamera.h"
// #import <ImageIO/ImageIO.h>
#include <sys/time.h>
#include <fstream>
#include <iostream>
#include <queue>

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"
#include "tensorflow/contrib/lite/string_util.h"
#include "tensorflow/contrib/lite/tools/mutable_op_resolver.h"

#define LOG(x) std::cerr

// If you have your own model, modify this to the file name, and make sure
// you've added the file to your app resources too.
static NSString* model_file_name = @"mobilenet_quant_v1_224";
static NSString* model_file_type = @"tflite";

// If you have your own model, point this to the labels file.
static NSString* labels_file_name = @"labels";
static NSString* labels_file_type = @"txt";

// These dimensions need to match those the model was trained with.
static const int wanted_input_width = 224;
static const int wanted_input_height = 224;
static const int wanted_input_channels = 3;

static NSString* FilePathForResourceName(NSString* name, NSString* extension) {
  NSString* file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
  if (file_path == NULL) {
    LOG(FATAL) << "Couldn't find '" << [name UTF8String] << "." << [extension UTF8String]
               << "' in bundle.";
  }
  return file_path;
}

static void LoadLabels(NSString* file_name, NSString* file_type,
                       std::vector<std::string>* label_strings) {
  NSString* labels_path = FilePathForResourceName(file_name, file_type);
  if (!labels_path) {
    LOG(ERROR) << "Failed to find model proto at" << [file_name UTF8String]
               << [file_type UTF8String];
  }
  std::ifstream t;
  t.open([labels_path UTF8String]);
  std::string line;
  while (t) {
    std::getline(t, line);
    label_strings->push_back(line);
  }
  t.close();
}

// Returns the top N confidence values over threshold in the provided vector,
// sorted by confidence in descending order.
static void GetTopN(const uint8_t* prediction, const int prediction_size, const int num_results,
                    const float threshold, std::vector<std::pair<float, int>>* top_results) {
  // Will contain top N results in ascending order.
  std::priority_queue<std::pair<float, int>, std::vector<std::pair<float, int>>,
                      std::greater<std::pair<float, int>>>
      top_result_pq;

  const long count = prediction_size;
  for (int i = 0; i < count; ++i) {
    const float value = prediction[i] / 255.0;
    // Only add it if it beats the threshold and has a chance at being in
    // the top N.
    if (value < threshold) {
      continue;
    }

    top_result_pq.push(std::pair<float, int>(value, i));

    // If at capacity, kick the smallest value out.
    if (top_result_pq.size() > num_results) {
      top_result_pq.pop();
    }
  }

  // Copy to output vector and reverse into descending order.
  while (!top_result_pq.empty()) {
    top_results->push_back(top_result_pq.top());
    top_result_pq.pop();
  }
  std::reverse(top_results->begin(), top_results->end());
}


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
        [self.session startRunning];
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

        self.videoDataOutput = [AVCaptureVideoDataOutput new];
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];

        if ([self.session canAddOutput:self.videoDataOutput]) [self.session addOutput:self.videoDataOutput];
        [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

  NSDictionary* rgbOutputSettings =
      [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey];
  [self.videoDataOutput setVideoSettings:rgbOutputSettings];
  [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        
        [self.session commitConfiguration];
    });
}

- (void)captureOutput:(AVCaptureOutput*)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection*)connection {
  CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CFRetain(pixelBuffer);
//   [self runModelOnFrame:pixelBuffer];
  CFRelease(pixelBuffer);
}

- (void)runModelOnFrame:(CVPixelBufferRef)pixelBuffer {
  assert(pixelBuffer != NULL);

  OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
  assert(sourcePixelFormat == kCVPixelFormatType_32ARGB ||
         sourcePixelFormat == kCVPixelFormatType_32BGRA);

  const int sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
  const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
  const int fullHeight = (int)CVPixelBufferGetHeight(pixelBuffer);

  CVPixelBufferLockFlags unlockFlags = kNilOptions;
  CVPixelBufferLockBaseAddress(pixelBuffer, unlockFlags);

  unsigned char* sourceBaseAddr = (unsigned char*)(CVPixelBufferGetBaseAddress(pixelBuffer));
  int image_height;
  unsigned char* sourceStartAddr;
  if (fullHeight <= image_width) {
    image_height = fullHeight;
    sourceStartAddr = sourceBaseAddr;
  } else {
    image_height = image_width;
    const int marginY = ((fullHeight - image_width) / 2);
    sourceStartAddr = (sourceBaseAddr + (marginY * sourceRowBytes));
  }
  const int image_channels = 4;
  assert(image_channels >= wanted_input_channels);
  uint8_t* in = sourceStartAddr;

  int input = interpreter->inputs()[0];

  uint8_t* out = interpreter->typed_tensor<uint8_t>(input);
  for (int y = 0; y < wanted_input_height; ++y) {
    uint8_t* out_row = out + (y * wanted_input_width * wanted_input_channels);
    for (int x = 0; x < wanted_input_width; ++x) {
      const int in_x = (y * image_width) / wanted_input_width;
      const int in_y = (x * image_height) / wanted_input_height;
      uint8_t* in_pixel = in + (in_y * image_width * image_channels) + (in_x * image_channels);
      uint8_t* out_pixel = out_row + (x * wanted_input_channels);
      for (int c = 0; c < wanted_input_channels; ++c) {
        out_pixel[c] = in_pixel[c];
      }
    }
  }

  double startTimestamp = [[NSDate new] timeIntervalSince1970];
  if (interpreter->Invoke() != kTfLiteOk) {
    LOG(FATAL) << "Failed to invoke!";
  }
  double endTimestamp = [[NSDate new] timeIntervalSince1970];
  total_latency += (endTimestamp - startTimestamp);
  total_count += 1;
  NSLog(@"Time: %.4lf, avg: %.4lf, count: %d", endTimestamp - startTimestamp,
        total_latency / total_count, total_count);

  const int output_size = 136;
  const int kNumResults = 5;
  const float kThreshold = 0.1f;

  std::vector<std::pair<float, int>> top_results;

  uint8_t* output = interpreter->typed_output_tensor<uint8_t>(0);
  GetTopN(output, output_size, kNumResults, kThreshold, &top_results);

  NSMutableDictionary* newValues = [NSMutableDictionary dictionary];
  for (const auto& result : top_results) {
    const float confidence = result.first;
    const int index = result.second;
    NSString* labelObject = [NSString stringWithUTF8String:labels[index].c_str()];
    NSNumber* valueObject = [NSNumber numberWithFloat:confidence];
    [newValues setObject:valueObject forKey:labelObject];
  }
  dispatch_async(dispatch_get_main_queue(), ^(void) {
    [self setPredictionValues:newValues];
  });

  CVPixelBufferUnlockBaseAddress(pixelBuffer, unlockFlags);

  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

@end