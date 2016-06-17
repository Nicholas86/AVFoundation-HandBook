//
//  JkAudioBuffer.h
//  JKSimpleAudioPlayerDemo
//
//  Created by Jack on 16/6/17.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "JKParsedAudioData.h"

@interface JkAudioBuffer : NSObject

+ (instancetype)buffer;

- (void)enqueueData:(JKParsedAudioData *)data;
- (void)enqueueFromDataArray:(NSArray *)dataArray;


- (BOOL)hasData;
- (UInt32)bufferedSize;

//descriptions needs free
- (NSData *)dequeueDataWithSize:(UInt32)requestSize
                    packetCount:(UInt32 *)packetCount
                   descriptions:(AudioStreamPacketDescription **)descriptions;

- (void)clean;


@end
