//
//  VideoSockets.m
//  TestCamera 
//
//  Created by Apple on 11/18/15.
//
//

#import <Foundation/Foundation.h>

#include <pthread.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

#include <iostream>
#include <string>
#include <sstream>
#include <queue>
#include <sys/time.h>
using namespace std;
#include "VideoSockets.h"
#include "Constants.h"
//#define printf(...)
#include "VideoCallProcessor.h"

string g_sServerIP = "38.127.68.60"; //"192.168.57.113";

int g_iVideoSocketPort = 15001;
int g_iServerPort = 10001;

struct sockaddr_in si_me, si_other, si_VideoSocket, si_VideoSendSocket;
struct sockaddr_in Server;

int ServerFd, s, i, slen = sizeof(si_other) , recv_len, s_VideoSocket, s_VideoSendSocket, sVideoSocketLen = sizeof(si_VideoSocket), sVideoSendSocketLen = sizeof(si_VideoSendSocket);

byte baDataReceiverBuffer[MAXBUFFER_SIZE];
byte baVideoReceiverBuffer[MAXBUFFER_SIZE];


@implementation VideoSockets

- (id) init
{
    self = [super init];
    NSLog(@"Inside VideoSockets Constructor");
    [self InitializeSocket];
    return self;
}

+ (id)GetInstance
{
    if(!m_pVideoSockets)
    {
        cout<<"Video_Team: m_pVideoCallProcessor Initialized"<<endl;
        
        m_pVideoSockets = [[VideoSockets alloc] init];
        
    }
    return m_pVideoSockets;
}

- (void)SetVideoAPI:(CVideoAPI *)pVideoAPI
{
    m_pVideoAPI = pVideoAPI;
}

-(void)InitializeSocket
{
    
    if ( (s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        printf("socket");
    }
    
    memset((char *) &si_other, 0, sizeof(si_other));
    si_other.sin_family = AF_INET;
    si_other.sin_port = htons(g_iServerPort);
    
    if (inet_aton(g_sServerIP.c_str() , &si_other.sin_addr) == 0)
    {
        fprintf(stderr, "inet_aton() failed\n");
        exit(1);
    }
    
    
    if ( (s_VideoSocket=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        printf("socket");
    }
    
    memset((char *) &si_VideoSocket, 0, sizeof(si_VideoSocket));
    si_VideoSocket.sin_family = AF_INET;
    si_VideoSocket.sin_port = htons(g_iVideoSocketPort);
    
    if (inet_aton(g_sServerIP.c_str() , &si_VideoSocket.sin_addr) == 0)
    {
        fprintf(stderr, "inet_aton() failed\n");
        exit(1);
    }
    
    
    dispatch_queue_t PacketReceiverQ = dispatch_queue_create("PacketReceiverQ",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(PacketReceiverQ, ^{
        [self PacketReceiver];
    });
    
    dispatch_queue_t PacketReceiverForVideoDataQ = dispatch_queue_create("PacketReceiverForVideoDataQ",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(PacketReceiverForVideoDataQ, ^{
        [self PacketReceiverForVideoData];
    });
    
}

- (void) SetUserID:(long long)lUserId
{
    m_lUserId = lUserId;
}

-(void) BindSocketToReceiveRemoteData
{
    if ( (s_VideoSendSocket =socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        printf("socket");
    }
    
    
    memset((char *) &si_VideoSendSocket, 0, sizeof(si_VideoSendSocket));
    si_VideoSendSocket.sin_family = AF_INET;
    si_VideoSendSocket.sin_port = htons(32321);
    
    si_VideoSendSocket.sin_addr.s_addr = htonl(INADDR_ANY);
    
    //bind socket to port
    if( bind(s_VideoSendSocket , (struct sockaddr*)&si_VideoSendSocket, sizeof(si_VideoSendSocket) ) == -1)
    {
        printf("bind\n");
    }
    
    
    
    dispatch_queue_t PacketReceiverForVideoSendSocketQ = dispatch_queue_create("PacketReceiverForVideoSendSocketQ",DISPATCH_QUEUE_SERIAL);
    dispatch_async(PacketReceiverForVideoSendSocketQ, ^{
        [self PacketReceiverForVideoSendSocket];
    });
}

void SendToVideoSocket(byte sendingBytePacket[], int length)
{
    int iRet;
    iRet = sendto(s_VideoSocket, sendingBytePacket, length, 0, (struct sockaddr*) &si_VideoSocket, sizeof(si_VideoSocket));
    
    printf("SendPacketVideoSocket, iRet = %d\n", iRet);
    
}

void SendToVideoSendSocket(byte sendingBytePacket[], int length)
{
    int iRet;
    printf("First byte of sending video data = %d\n", (int)sendingBytePacket[0]);
    iRet = sendto(s_VideoSendSocket, sendingBytePacket, length, 0, (struct sockaddr*) &si_VideoSendSocket, sizeof(si_VideoSendSocket));
    
    printf("SendPacketVideoSocket, iRet = %d\n", iRet);
    
}


- (void)PacketReceiverForVideoSendSocket
{
    printf("Rajib_Check: Inside PacketReceiveerforVideoSocket called\n");
    struct sockaddr_in sss_other;
    int ssslen = sizeof(si_other);
    while(true)
    {
        printf("Waiting for data..., PacketReceiverForVideoSendSocket");
        fflush(stdout);
        int iDataLen;
        //try to receive some data, this is a blocking call
        
        if ((iDataLen = recvfrom(s_VideoSendSocket, baVideoReceiverBuffer, MAXBUFFER_SIZE, 0, (struct sockaddr *) &sss_other, (socklen_t*)&ssslen)) == -1)
        {
            printf("ERROR: Packet receive Failed\n");
            continue;
        }
        
        printf("Data VideoSendSocket type: %d, iRet = %d\n" , (int)baVideoReceiverBuffer[0], iDataLen);
        
        int iPacketType = (int)baVideoReceiverBuffer[0];
        if(iPacketType == 33 && iDataLen !=-1)
        {
            /*
            //MARK: receiving video data.
            NSData *receivedData = [[NSData alloc] initWithBytes:baVideoReceiverBuffer+1 length:iDataLen-1];
            [[RingCallAudioManager sharedInstance] processReceivedRTPPacket:receivedData];
            */
            //long long lUser = [[VideoCallProcessor GetInstance] GetUserId];
            m_pVideoAPI->PushPacketForDecodingV(m_lUserId, baVideoReceiverBuffer+1, iDataLen-1);
            
            //int availableBytes = 0;
            //TPCircularBufferProduceBytes([[RingCallAudioManager sharedInstance]., shortArray, (availableBytes));
            
            //m_pVideoAPI->PushPacketForDecoding(m_lUserId, baVideoReceiverBuffer+1, iDataLen-1);
            
            /*printf("VideoTeamCheck: AUDIO PACKET Found, iLen = %d\n", iDataLen);
            
            NSData *receivedData = [[NSData alloc] initWithBytes:baVideoReceiverBuffer+1 length:iDataLen-1];
            [[RingCallAudioManager sharedInstance] processReceivedRTPPacket:receivedData];*/
            
        }
        else if(iPacketType == 43 && iDataLen !=-1)
        {
            
            printf("VideoTeamCheck: AUDIO PACKET Found, iLen = %d\n", iDataLen);
            
            NSData *receivedData = [[NSData alloc] initWithBytes:baVideoReceiverBuffer+1 length:iDataLen-1];
            [[RingCallAudioManager sharedInstance] processReceivedRTPPacket:receivedData];
            
            
        }
        else
        {
            /*
            printf("VideoTeamCheck: AUDIO PACKET Found, iLen = %d\n", iDataLen);
            
            NSData *receivedData = [[NSData alloc] initWithBytes:baVideoReceiverBuffer length:iDataLen];
            [[RingCallAudioManager sharedInstance] processReceivedRTPPacket:receivedData];
            
            
            
            //WriteToFileV(byteData, len);
            
            //CVideoAPI::GetInstance()->PushAudioForDecoding(200, byteData, len);
             
             */
        }
        
    }
    
}


- (void)PacketReceiverForVideoData
{
    
    while(true)
    {
        printf("Waiting for data, PacketReceiverForVideoData\n");
        fflush(stdout);
        
        //try to receive some data, this is a blocking call
        if ((recv_len = recvfrom(s_VideoSocket, baDataReceiverBuffer, MAXBUFFER_SIZE, 0, (struct sockaddr *) &si_VideoSocket, (socklen_t*)&sVideoSocketLen)) == -1)
        {
            printf("recvfrom()");
        }
        
        //print details of the client/peer and the data received
        printf("Inside VIdeo Socket Received packet from %s:%d\n", inet_ntoa(si_VideoSocket.sin_addr), ntohs(si_VideoSocket.sin_port));
        printf("Data Inside VideoSocket: %d\n" , (int)baDataReceiverBuffer[0]);
        
        
        //if (recv_len != -1)
        //mySignalReceiver->SignalingPacketProcess((byte*)buf, recv_len);
        
        int iPacketType = (int)baDataReceiverBuffer[0];
        if(iPacketType == 31 )
        {
            cout<<"VIDEO_SERVER_REGISTATION_RESPONSE Found"<<endl;
            //ClientConstents.FRIEND_PORT = ByteArrayToIntegerConvert(receivedMessage, ++start);
            
            int start = 1;
            int iFriendPort = ByteArrayToIntegerConvert((byte*)baDataReceiverBuffer, ++start);
            
            
            cout<<"VideoSocket:: VideoAPI->SetRelayServerInformation --> "<<"lUser = "<<[[VideoCallProcessor GetInstance] GetFriendId]<<", g_serverip  = "<<g_sServerIP<<", iFriendPort = "<<iFriendPort<<endl;
            //CVideoAPI::GetInstance()->SetRelayServerInformation(200, (int)2/*Audio*/,  "38.127.68.60", 60001);
            //CVideoAPI::GetInstance()->SetRelayServerInformation(200, (int)1/*Audio*/,  "38.127.68.60", 60001);
            
            /*
            if ( (s_VideoSendSocket =socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
            {
                printf("socket");
            }
            
            
            InitializeServerSocketForRemoteUser(s_VideoSendSocket, g_sServerIP, iFriendPort);
            
            dispatch_queue_t PacketReceiverForVideoSendSocketQ = dispatch_queue_create("PacketReceiverForVideoSendSocketQ",DISPATCH_QUEUE_SERIAL);
            dispatch_async(PacketReceiverForVideoSendSocketQ, ^{
                [self PacketReceiverForVideoSendSocket];
            });
            */
            
            
            /*
            
            bStartVideoSending = true;
            [g_pVideoCallProcessor StartAllThreads];
            //[self StartCameraSession];
            [session startRunning];
             
            */
            
        }
        else
        {
            cout<<"Packet Type Not Found: Invalid Data"<<endl;
        }
    }
}



- (void)PacketReceiver
{
    
    while(true)
    {
        printf("Waiting for data...");
        fflush(stdout);
        
        //try to receive some data, this is a blocking call
        if ((recv_len = recvfrom(s, baDataReceiverBuffer, 1024, 0, (struct sockaddr *) &si_other, (socklen_t*)&slen)) == -1)
        {
            printf("recvfrom()");
        }
        
        //print details of the client/peer and the data received
        printf("Received packet from %s:%d\n", inet_ntoa(si_other.sin_addr), ntohs(si_other.sin_port));
        printf("Data: %d\n" , (int)baDataReceiverBuffer[0]);
        
        
        int iPacketType = (int)baDataReceiverBuffer[0];
        if(iPacketType == Constants::CALL_RESPONSE)
        {
            
            cout<<"Call_Response Message_Found"<<endl;
            /*
            int iLength = 1 + 1 + sMyId.size() + 1 + sFrinedId.size();
            byte* message = (byte*)malloc(iLength);
            
            pMessageProcessor->prepareLoginRequestMessageR(sMyId, sFrinedId, message);
            
            SendToVideoSocket(message, iLength);
            */
            
        }
        if(iPacketType == Constants::CALL_REQUEST)
        {
            cout<<"Call_Request Message_Found"<<endl;
            /*
            size_t iLengthCall = 1 + 4 + sMyId.size() + 4 + sFrinedId.size();
            byte* messageCall = (byte*)malloc(iLengthCall);
            
            CMessageProcessor *pMessageProcessor = new CMessageProcessor();
            pMessageProcessor->prepareCallRequestMessage(messageCall, sMyId, sFrinedId);
            messageCall[0] = (int)103;
            SendPacket(messageCall, iLengthCall);
            
            
            int iLength = 1 + 1 + sMyId.size() + 1 + sFrinedId.size();
            byte* message = (byte*)malloc(iLength);
            pMessageProcessor->prepareLoginRequestMessageR(sMyId, sFrinedId, message);
            
            SendToVideoSocket(message, iLength);
            */
            
        }
    }
}


void InitializeSocketForRemoteUser(string sRemoteIp)
{
    if ( (ServerFd=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        printf("socket");
    }
    
    memset((char *) &Server, 0, sizeof(Server));
    Server.sin_family = AF_INET;
    Server.sin_port = htons(32321);
    
    //if (inet_aton("192.168.57.152" , &Server.sin_addr) == 0)
    if (inet_aton(sRemoteIp.c_str() , &Server.sin_addr) == 0)
    {
        fprintf(stderr, "inet_aton() failed\n");
        exit(1);
    }
}


void InitializeServerSocketForRemoteUser(int &SocketFd, string sRemoteIp, int iRemotePort)
{
    
    if ( (ServerFd=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
    {
        printf("socket");
    }
    
    memset((char *) &Server, 0, sizeof(Server));
    Server.sin_family = AF_INET;
    Server.sin_port = htons(iRemotePort);
    
    if (inet_aton(sRemoteIp.c_str() , &Server.sin_addr) == 0)
    {
        fprintf(stderr, "inet_aton() failed\n");
        exit(1);
    }
    SocketFd = ServerFd;
}

void SendToServer(byte sendingBytePacket[], int length)
{
    int iRet;
    //s_VideoSendSocket
    
    iRet = sendto(ServerFd, sendingBytePacket, length, 0, (struct sockaddr*) &Server, sizeof(Server));
    //iRet = sendto(s_VideoSendSocket, sendingBytePacket, length, 0, (struct sockaddr*) &Server, sizeof(Server));
    
    printf("-->SendPacketVideoSocket, iRet = %d\n", iRet);
    
}

void SendPacket(byte sendingBytePacket[], int length)
{
    //now reply the client with the same data
    int iRet;
    iRet = sendto(s, sendingBytePacket, length, 0, (struct sockaddr*) &si_other, sizeof(si_other));
    
    printf("SendPacket, iRet = %d\n", iRet);
    
}
int ByteArrayToIntegerConvert( byte* rawData, int stratPoint )
{
    int TotalDataLen = 0;
    
    TotalDataLen += (rawData[stratPoint++] & 0xFF) << 24;
    TotalDataLen += (rawData[stratPoint++] & 0xFF) << 16;
    TotalDataLen += (rawData[stratPoint++] & 0xFF) << 8;
    TotalDataLen += (rawData[stratPoint++] & 0xFF);
    
    return TotalDataLen;
}




@end