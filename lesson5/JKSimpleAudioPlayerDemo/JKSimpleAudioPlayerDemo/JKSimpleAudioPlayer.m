//
//  JKSimpleAudioPlayer.m
//  JKSimpleAudioPlayerDemo
//
//  Created by Jack on 16/6/17.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "JKSimpleAudioPlayer.h"
#import <pthread.h>

@interface JKSimpleAudioPlayer ()
{
@private
    NSThread *_thread;
    pthread_mutex_t _mutex;
    pthread_cond_t _cond;
    
    JKSAPStatus _status;
    
    unsigned long long _fileSize;
    unsigned long long _offset;
    NSFileHandle *_fileHandler;
    
    UInt32 _bufferSize;
    
    BOOL _started;
    BOOL _pauseRequired;
    BOOL _stopRequired;
    BOOL _pausedByInterrupt;
    BOOL _usingAudioFile;
    
    BOOL _seekRequired;
    NSTimeInterval _seekTime;
    NSTimeInterval _timingOffset;
}
@end


@implementation JKSimpleAudioPlayer
@dynamic status;
@synthesize failed = _failed;
@synthesize fileType = _fileType;
@synthesize filePath = _filePath;
@dynamic isPlayingOrWaiting;
@dynamic duration;
@dynamic progress;


#pragma mark - init & dealloc

- (instancetype)initWithFilePath:(NSString *)filePath
                        fileType:(AudioFileTypeID)fileType {
    if (self = [super init]) {
        _status = JKSAPStatusStopped;
        
        _filePath = filePath;
        _fileType = fileType;
        
        _fileHandler = [NSFileHandle fileHandleForReadingAtPath:_filePath];
        _fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] fileSize];
        
    }
    return self;

}


#pragma mark - mutex

#pragma mark - method

- (void)play {
    if (!_started) {
        _started = YES;
        
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain) object:nil];
        [_thread start];
    } else {
        
    }
}

@end
