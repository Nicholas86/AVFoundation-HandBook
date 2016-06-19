//
//  NSTimer+BlocksSupport.h
//  JKSimpleAudioPlayerDemo
//
//  Created by Jack on 16/6/19.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (BlocksSupport)
+ (NSTimer*)bs_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats;
@end
