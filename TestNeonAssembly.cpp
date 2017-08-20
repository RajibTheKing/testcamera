//
//  TestNeonAssembly.cpp
//  TestCamera 
//
//  Created by Rajib Chandra Das on 7/26/17.
//
//

#include "TestNeonAssembly.hpp"
#include <arm_neon.h>



TestNeonAssembly::TestNeonAssembly()
{
    
}

TestNeonAssembly::~TestNeonAssembly()
{
    
}

void TestNeonAssembly::reference_convert (unsigned char * __restrict dest, unsigned char * __restrict src, int n)
{
    int i;
    for (i=0; i<n; i++)
    {
        int r = *src++; // load red
        int g = *src++; // load green
        int b = *src++; // load blue
        
        // build weighted average:
        int y = (r*77)+(g*151)+(b*28);
        
        // undo the scale by 256 and write to memory:
        *dest++ = (y>>8);
    }
}

void TestNeonAssembly::neon_intrinsic_convert (unsigned char * __restrict dest, unsigned char * __restrict src, int n)
{
    int i;
    uint8x8_t rfac = vdup_n_u8 (77);
    uint8x8_t gfac = vdup_n_u8 (151);
    uint8x8_t bfac = vdup_n_u8 (28);
    n/=8;
    
    for (i=0; i<n; i++)
    {
        uint16x8_t  temp;
        uint8x8x3_t rgb  = vld3_u8 (src);
        uint8x8_t result;
        
        temp = vmull_u8 (rgb.val[0],      rfac);
        temp = vmlal_u8 (temp,rgb.val[1], gfac);
        temp = vmlal_u8 (temp,rgb.val[2], bfac);
        
        result = vshrn_n_u16 (temp, 8);
        vst1_u8 (dest, result);
        src  += 8*3;
        dest += 8;
    }
}

void TestNeonAssembly::neon_assembly_convert (unsigned char*  __restrict dest, unsigned char*  __restrict src, int n)
{
    convert_asm_neon(dest,src,n);
}

void TestNeonAssembly::neon_assembly_Inc(unsigned char*  __restrict dest, unsigned char*  __restrict src, int n)
{
    add_asm_neon(dest,src,n);
}

void TestNeonAssembly::Copy_Assembly_Inc(unsigned char* __restrict src, unsigned char* __restrict dest, int iLen)
{
    copy_asm_neon(src, dest, iLen);
}

void TestNeonAssembly::convert_nv12_to_i420_assembly(unsigned char* __restrict src, unsigned char* __restrict dest, int iHeight, int iWidth)
{
    convert_nv12_to_i420_asm_neon(src, dest, iHeight, iWidth);
}
