//
//  Common.h
//  TestCamera 
//
//  Created by IPV-VIDEO on 11/18/15.
//
//

#ifndef Common_h
#define Common_h

#include <sstream>
#include <cstdlib>


#include <time.h>
#include <chrono>
#include <stdio.h>
#include <ctime>
#include <chrono>

using namespace std;



//#define printf(...)
#define MAXWIDTH 1280
#define MAXHEIGHT 1280
#define MAXBUFFER_SIZE 500000
#define byte unsigned char
#define MAX_FRAME_SIZE (MAXWIDTH * MAXHEIGHT * 3 / 2)

#define MEDIA_TYPE_AUDIO 1
#define MEDIA_TYPE_VIDEO 2
#define MEDIA_TYPE_LIVE_STREAM 3

#define SERVICE_TYPE_CALL 11
#define SERVICE_TYPE_SELF_CALL 13

#define ENTITY_TYPE_CALLER 31

#define SERVICE_TYPE_LIVE_STREAM 12
#define SERVICE_TYPE_SELF_STREAM 14

#define ENTITY_TYPE_PUBLISHER 31
#define ENTITY_TYPE_VIEWER 32
#define ENTITY_TYPE_VIEWER_CALLEE 2
#define ENTITY_TYPE_PUBLISHER_CALLER 1

#define FULL_PACKET_CODE 100
#define LAST_PACKET_CODE 99
#define MAX_SEND_BUFFER_SIZE 9000

#define PUBLISHER_IN_CALL 1
#define VIEWER_IN_CALL 2
#define CALL_NOT_RUNNING 4;

class CCommon
{
public:
    CCommon();
    ~CCommon();
};


static long long CurrentTimeStamp()
{
    namespace sc = std::chrono;
    auto time = sc::system_clock::now(); // get the current time
    auto since_epoch = time.time_since_epoch(); // get the duration since epoch
    // I don't know what system_clock returns
    // I think it's uint64_t nanoseconds since epoch
    // Either way this duration_cast will do the right thing
    auto millis = sc::duration_cast<sc::milliseconds>(since_epoch);
    long long now = millis.count(); // just like java (new Date()).getTime();
    return now;
}
static void SOSleep(int nSleepTimeout)
{
    timespec t;
    
    u_int32_t seconds = nSleepTimeout / 1000;
    t.tv_sec = seconds;
    t.tv_nsec = (nSleepTimeout - (seconds * 1000)) * (1000 * 1000);
    
    nanosleep(&t, NULL);
    
}
//#define nullptr NULL

#endif /* Common_h */
