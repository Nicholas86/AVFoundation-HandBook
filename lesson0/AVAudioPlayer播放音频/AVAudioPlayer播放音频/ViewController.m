//
//  ViewController.m
//  AVAudioPlayer播放音频
//
//  Created by Jack on 16/6/9.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *player;

@property (weak, nonatomic) IBOutlet UISlider *volumeSilder;
@property (weak, nonatomic) IBOutlet UISlider *rateSilder;
@property (weak, nonatomic) IBOutlet UISlider *panSidler;

@property (nonatomic, assign) BOOL playing;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"TFBOYS" withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    //注册中断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    self.player.numberOfLoops = -1;
    self.player.enableRate = YES;
    [self.player prepareToPlay];

    self.volumeSilder.value = 0.5;
    self.rateSilder.value = 1.0;
    self.panSidler.value = 0;
    
}

#pragma mark - handle notification

- (void)handleInterruption:(NSNotification *)notification {
    
    NSDictionary  *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //中断开始
        [self stop:nil];
    } else {
        //中断结束
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            [self play:nil];
        }
    }
    NSLog(@"%@",info);

}

- (void)handleRouteChange:(NSNotification *)notification {
    
    /*
     当耳机插入的时候，AVAudioSessionRouteChangeReason等于AVAudioSessionRouteChangeReasonNewDeviceAvailable
     代表一个新外接设备可用，但是插入耳机，我们不需要处理。所以不做判断。
     当耳机拔出的时候 AVAudioSessionRouteChangeReason等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable
     代表一个之前外的外接设备不可用了，此时我们需要处理，让他播放器静音 。
     AVAudioSessionRouteChangePreviousRouteKey：当之前的线路改变的时候，
     获取到线路的描述对象：AVAudioSessionRouteDescription，然后获取到输出设备，判断输出设备的类型是否是耳机,
     如果是就暂停播放
     */
    
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        NSString *portType = previousOutput.portType;
        
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
            [self stop:nil];
        }
        
    }
    NSLog(@"%@",info);
    
}


#pragma mark - IB functions

- (IBAction)volumeChange:(UISlider *)sender {
    self.player.volume = sender.value;
}

- (IBAction)rateChange:(UISlider *)sender {
    self.player.rate = sender.value;
}

- (IBAction)panChange:(UISlider *)sender {
    self.player.pan = sender.value;
}


- (IBAction)play:(id)sender {
    if (!self.playing) {
        [self.player playAtTime:self.player.deviceCurrentTime];
        //或者 [self.player play];
        self.playing = YES;
        
        
    }
}


- (IBAction)stop:(id)sender {
    if (self.playing) {
        [self.player stop];
        self.playing = NO;
    }
}


- (IBAction)reset:(id)sender {
    [self.volumeSilder setValue:0.5 animated:YES];
    [self.rateSilder setValue:1.0 animated:YES];
    [self.panSidler setValue:0 animated:YES];
    
    [self volumeChange:_volumeSilder];
    [self rateChange:_rateSilder];
    [self panChange:_panSidler];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
