//
//  Common.h
//  TestCamera 
//
//  Created by IPV-VIDEO on 11/18/15.
//
//

#ifndef Common_h
#define Common_h

#include <time.h>
#include <chrono>
#include <stdio.h>
using namespace std;



#define printf(...)
#define MAXWIDTH 640
#define MAXHEIGHT 640
#define MAXBUFFER_SIZE 5000
#define byte unsigned char
#define MAX_FRAME_SIZE (MAXWIDTH * MAXHEIGHT * 3 / 2)

#define SERVICE_TYPE_CALL 11
#define SERVICE_TYPE_LIVE_STREAM 12
#define SERVICE_TYPE_SELF_CALL 13
#define SERVICE_TYPE_SELF_STREAM 14

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
//#define nullptr NULL

#endif /* Common_h */
