//
//  VideoCallProcessor.h
//  TestCamera 
//
//  Created by Apple on 11/16/15.
//
//

#ifndef VideoCallProcessor_h
#define VideoCallProcessor_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#include "RingBuffer.hpp"
#include <stdio.h>
#include <pthread.h>

#include "VideoConverter.hpp"
#include "Constants.h"
#include "MessageProcessor.hpp"
#include "common.h"
#include "VideoThreadProcessor.h"
#include "VideoAPI.hpp"
#include "VideoSockets.h"
#include "G729CodecNative.h" 


@protocol ViewControllerDelegate <NSObject>
@required
-(int)RenderImage:(UIImage *)uiImageToDraw;
@end




@interface VideoCallProcessor : UIViewController<VideoThreadProcessorDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    RingBuffer<byte> *m_pEncodeBuffer;
    int m_iCameraHeight;
    int m_iCameraWidth;
    long long m_lUserId;
    long long m_lFriendId;
    
    int m_iRenderHeight;
    int m_iRenderWidth;
    int m_iActualFriendPort;
    dispatch_queue_t videoDataOutputQueue;
    
    CVideoConverter *m_pVideoConverter;
    VideoSockets *m_pVideoSockets;
    
    VideoThreadProcessor *m_pVTP;
   
    
    id <ViewControllerDelegate> _delegate;
    CVideoAPI *m_pVideoAPI;
    G729CodecNative *g_G729CodecNative;
    string m_sRemoteIP;
    
    FILE *m_FileForDump;
    
}



@property bool m_bStartVideoSending;
@property long long m_lCameraInitializationStartTime;
+(long long)convertStringIPtoLongLong:(NSString *)ipAddr;
+ (id)GetInstance;

- (id) init;

- (void)SetRemoteIP:(string)sRemoteIP;
- (void)SetFriendId:(long long)lFriendId;

- (void) Initialize : (long long)lUserId;
- (void) InitializeVideoEngine:(long long) lUserId;

- (void)SetWidthAndHeight:(int)iWidth withHeight:(int)iHeight;

- (void)SetVideoSockets:(VideoSockets *)pVideoSockets;

- (void)SetFriendPort:(int)iPort;

- (void)StartAllThreads;
- (void)CloseAllThreads;
- (NSError *)InitializeCameraSession:(AVCaptureSession **)session
                    withDeviceOutput:(AVCaptureVideoDataOutput **)videoDataOutput
                           withLayer:(AVCaptureVideoPreviewLayer **)previewLayer
                          withHeight:(int *)iHeight
                           withWidth:(int *)iWidth;
-(G729CodecNative *)GetG729;
-(long long)GetUserId;
-(long long)GetFriendId;
- (int)FrontConversion:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (void)WriteToFile:(unsigned char *)data dataLength:(int)datalen filePointer:(FILE *)fp;
- (void)InitializeFilePointer:(FILE *)fp fileName:(NSString *)fileName;
int ConvertNV12ToI420(unsigned char *convertingData, int iheight, int iwidth);
-(void)SendDummyData;
-(long long)GetTimeStamp2;
@property (nonatomic,strong) id delegate;



@end

static VideoCallProcessor *m_pVideoCallProcessor = nil;

#endif /* VideoCallProcessor_h */
