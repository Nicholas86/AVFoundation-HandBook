//
//  NSTimer+BlocksSupport.m
//  JKSimpleAudioPlayerDemo
//
//  Created by Jack on 16/6/19.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "NSTimer+BlocksSupport.h"

@implementation NSTimer (BlocksSupport)
+ (NSTimer*)bs_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(bs_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)bs_blockInvoke:(NSTimer*)timer
{
    void (^block)() = timer.userInfo;
    if (block)
    {
        block();
    }
}

@end
