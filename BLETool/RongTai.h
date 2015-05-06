//
//  RongTai.h
//  BLETool
//
//  Created by Jaben on 15/5/6.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#ifndef BLETool_RongTai_h
#define BLETool_RongTai_h

#define SOI 0xf0 //frame begin
#define EOI 0xf1 //frame end
/*
 // 校验：除了SOI和EOI之外的所有数据相加后取反，并将最高位清零，位置在倒数第二个字节，即EOI之前
    eg: 0xf0 0x84 0x82 0xNN 0xf1
    0xNN = (~(0x84 + 0x82)) & 0x7f
 */


/*
 press command
 */
// direction

#define RTControl_NoTimeDisplay 0x80
#define RTControl_TimeDisplay   0x81
#define RTControl_TFTDisplay    0x82
#define RTControl_Android       0x83
#define RTControl_iOS           0x84


#endif
