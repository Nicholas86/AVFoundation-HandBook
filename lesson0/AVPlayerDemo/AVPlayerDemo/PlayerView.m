//
//  PlayerView.m
//  AVPlayerDemo
//
//  Created by Jack on 16/6/8.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
