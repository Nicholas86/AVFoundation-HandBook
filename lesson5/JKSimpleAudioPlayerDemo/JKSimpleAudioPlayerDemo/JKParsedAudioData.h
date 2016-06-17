//
//  JKParsedAudioData.h
//  JKSimpleAudioPlayerDemo
//
//  Created by Jack on 16/6/17.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>


@interface JKParsedAudioData : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) AudioStreamPacketDescription packetDescription;

+ (instancetype)parseAudioDataWithBytes:(const void *)bytes
                      packetDescription:(AudioStreamPacketDescription)packetDescription;

@end
