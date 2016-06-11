//
//  JKAudioFileStream.h
//  JKAudioFileStream
//
//  Created by Jack on 16/6/11.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "JKParsedAudioData.h"

@class JKAudioFileStream;
@protocol JKAudioFileStreamDelegate <NSObject>
@required
- (void)audioFileStream:(JKAudioFileStream *)audioFileStream audioDataParsed:(NSArray *)audioData;
@optional
- (void)audioFileStreamReadyToProducePackets:(JKAudioFileStream *)audioFileStream;
@end


@interface JKAudioFileStream : NSObject

@property (nonatomic, assign, readonly) AudioFileTypeID fileType;
@property (nonatomic, assign, readonly) BOOL available;
@property (nonatomic, assign, readonly) BOOL readyToProducePackets;
@property (nonatomic, weak) id<JKAudioFileStreamDelegate> delegate;

@property (nonatomic, assign, readonly) AudioStreamBasicDescription format;
@property (nonatomic, assign, readonly) unsigned long long fileSize;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) UInt32 bitRate;
@property (nonatomic, assign, readonly) UInt32 maxPacketSize;
@property (nonatomic, assign, readonly) UInt64 audioDataByteCount;

- (instancetype)initWithFileType:(AudioFileTypeID)fileType fileSize:(unsigned long long)fileSize error:(NSError **)error;

- (BOOL)parseData:(NSData *)data error:(NSError **)error;

/**
 *  seek to timeinterval
 *
 *  @param time On input, timeinterval to seek.
 On output, fixed timeinterval.
 *
 *  @return seek byte offset
 */

- (SInt64)seekToTime:(NSTimeInterval *)time;

- (NSData *)fetchMagicCookie;

- (void)close;

@end
