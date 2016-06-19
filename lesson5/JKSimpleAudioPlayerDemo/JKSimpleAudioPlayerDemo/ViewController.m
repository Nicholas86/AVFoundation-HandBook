//
//  ViewController.m
//  JKSimpleAudioPlayerDemo
//
//  Created by Jack on 16/6/17.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "JKSimpleAudioPlayer.h"
#import "NSTimer+BlocksSupport.h"
@interface ViewController () {
@private
    JKSimpleAudioPlayer *_player;
    NSTimer *_timer;
}
@end

@implementation ViewController

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (!_player)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MP3Sample" ofType:@"mp3"];
        _player = [[JKSimpleAudioPlayer alloc] initWithFilePath:path fileType:kAudioFileMP3Type];
        
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"M4ASample" ofType:@"m4a"];
        //        _player = [[MCSimpleAudioPlayer alloc] initWithFilePath:path fileType:kAudioFileAAC_ADTSType];
        
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"CAFSample" ofType:@"caf"];
        //        _player = [[MCSimpleAudioPlayer alloc] initWithFilePath:path fileType:kAudioFileCAFType];
        
        [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }
    [_player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - status kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _player)
    {
        if ([keyPath isEqualToString:@"status"])
        {
            [self performSelectorOnMainThread:@selector(handleStatusChanged) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)handleStatusChanged
{
    if (_player.isPlayingOrWaiting)
    {
        [self.playOrPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self startTimer];
        
    }
    else
    {
        [self.playOrPauseButton setTitle:@"Play" forState:UIControlStateNormal];
        [self stopTimer];
        [self progressMove];
    }
}

#pragma mark - timer
- (void)startTimer
{
    if (!_timer)
    {
        __weak typeof(self)weakSelf = self;
        _timer = [NSTimer bs_scheduledTimerWithTimeInterval:1 block:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf progressMove];
        } repeats:YES];
        [_timer fire];
    }
}

- (void)stopTimer
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)progressMove
{
    if (!self.progressSlider.tracking)
    {
        if (_player.duration != 0)
        {
            self.progressSlider.value = _player.progress / _player.duration;
        }
        else
        {
            self.progressSlider.value = 0;
        }
    }
}

#pragma mark - actions
- (IBAction)playOrPause:(id)sender {
    if (_player.isPlayingOrWaiting)
    {
        [_player pause];
    }
    else
    {
        [_player play];
    }
}

- (IBAction)stop:(id)sender {
    [_player stop];

}

- (IBAction)seek:(id)sender {
    _player.progress = _player.duration * self.progressSlider.value;

}



@end
