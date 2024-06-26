//
//  MessageProcessor.cpp
//  TestCamera 
//
//  Created by Apple on 11/3/15.
//
//

#include "MessageProcessor.hpp"
#include "Constants.h"
#include "TestCameraViewController.h"
#include <stdlib.h>
#include <stdio.h>
#include <string>


CMessageProcessor::CMessageProcessor()
{
    
}
CMessageProcessor::~CMessageProcessor()
{
    
}

CMessageProcessor* CMessageProcessor::GetInstance()
{
    if(m_pMessageProcessor == nullptr)
    {
        m_pMessageProcessor = new CMessageProcessor();
    }
    return m_pMessageProcessor;
}

void CMessageProcessor::Handle_Signaling_Message(unsigned char* buffer, int iLen)
{
    string str((char *)buffer, iLen);
    int startIndex = 1;
    
    cout<<"Handle_Signaling_Message -->";
    for(int i=0;i<iLen;i++)
    {
        printf("%X ", buffer[i]);
    }
    cout<<endl;
    
    if(buffer[0] ==  Constants::REPLY_REGISTER_MESSAGE)
    {
        int userID = ByteToInt(buffer, startIndex);
        char cConvertedCharArray[12];
        sprintf(cConvertedCharArray, "%d", userID);
        string sValue = "UserID = " + std::string(cConvertedCharArray);
        [[TestCameraViewController GetInstance] UpdateUserID:sValue];
        
    }
    else if(buffer[0] ==  Constants::INVITE_MESSAGE)
    {
        [[TestCameraViewController GetInstance] StartAllThreads];
        [[TestCameraViewController GetInstance] InitializeCameraAndMicrophone];
        [[TestCameraViewController GetInstance] InitializeAudioVideoEngineForCall];
        
    }
    else if(buffer[0] ==  Constants::END_CALL_MESSAGE)
    {
        [[TestCameraViewController GetInstance] UnInitializeAudioVideoEngine];
        [[TestCameraViewController GetInstance] UnInitializeCameraAndMicrophone];
        [[TestCameraViewController GetInstance] CloseAllThreads];
        
    }
    else if(buffer[0] ==  Constants::REPLY_END_CALL_MESSAGE)
    {
        [[TestCameraViewController GetInstance] UnInitializeAudioVideoEngine];
        [[TestCameraViewController GetInstance] UnInitializeCameraAndMicrophone];
        [[TestCameraViewController GetInstance] CloseAllThreads];
        
    }
    else if(buffer[0] ==  Constants::PUBLISHER_INVITE_MESSAGE)
    {
        int publisherID = ByteToInt(buffer, startIndex);
        int myViewerID =  ByteToInt(buffer, startIndex);
        int targetServerMediaPort = ByteToInt(buffer, startIndex);
        int iInsetID = buffer[startIndex++];
        printf("TestCamera--> PUBLISHER_INVITE_MESSAGE, publisherID --> videwerID = %d --> %d, insetID = %d VIEWER_IN_CALL\n", publisherID, myViewerID, iInsetID);
        //CVideoAPI::GetInstance()->StartCallInLive(200, VIEWER_IN_CALL, CALL_IN_LIVE_TYPE_AUDIO_VIDEO/*, iInsetID*/);
    }
    else if(buffer[0] ==  Constants::REPLY_PUBLISHER_INVITE_MESSAGE)
    {
        
        int publisherID = ByteToInt(buffer, startIndex);
        int myViewerID =  ByteToInt(buffer, startIndex);
        int targetServerMediaPort = ByteToInt(buffer, startIndex);
        int iInsetID = buffer[startIndex++];
        printf("TestCamera--> REPLY_PUBLISHER_INVITE_MESSAGE, publisherID --> videwerID = %d --> %d, insetID = %d PUBLISHER_IN_CALL\n", publisherID, myViewerID, iInsetID);
        //CVideoAPI::GetInstance()->StartCallInLive(200, PUBLISHER_IN_CALL, CALL_IN_LIVE_TYPE_AUDIO_VIDEO/*, iInsetID*/);
    }
    else if(buffer[0] ==  Constants::VIEWER_INVITE_MESSAGE)
    {
        //CVideoAPI::GetInstance()->StartCallInLive(200, PUBLISHER_IN_CALL, CALL_IN_LIVE_TYPE_AUDIO_VIDEO);
    }
    else if(buffer[0] ==  Constants::TERMINATE_ALL_MESSAGE)
    {
        [[TestCameraViewController GetInstance] UnInitializeAudioVideoEngine];
        [[TestCameraViewController GetInstance] UnInitializeCameraAndMicrophone];
        [[TestCameraViewController GetInstance] CloseAllThreads];
    }
    
}

int CMessageProcessor::ByteToInt(unsigned char* data, int &startIndex)
{
    int ret = 0;
    
    ret += (int) (data[startIndex++] & 0xFF) << 24;
    ret += (int) (data[startIndex++] & 0xFF) << 16;
    ret += (int) (data[startIndex++] & 0xFF) << 8;
    ret += (int) (data[startIndex++] & 0xFF);
    
    return ret;
}

void CMessageProcessor::IntToByte(int val, unsigned char* data, int &startIndex)
{
    data[startIndex++] = (unsigned char) ((val >> 24) & 0xFF);
    data[startIndex++] = (unsigned char) ((val >> 16) & 0xFF);
    data[startIndex++] = (unsigned char) ((val >> 8) & 0xFF);
    data[startIndex++] = (unsigned char) ((val >> 0) & 0xFF);
    
}



