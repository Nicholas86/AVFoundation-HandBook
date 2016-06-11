//
//  JKAudioSession.m
//  JKAudioSession
//
//  Created by Jack on 16/6/11.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "JKAudioSession.h"

NSString *const JKAudioSessionRouteChangeNotification = @"MCAudioSessionRouteChangeNotification";
NSString *const JKAudioSessionRouteChangeReason = @"MCAudioSessionRouteChangeReason";
NSString *const JKAudioSessionInterruptionNotification = @"MCAudioSessionInterruptionNotification";
NSString *const JKAudioSessionInterruptionStateKey = @"MCAudioSessionInterruptionStateKey";
NSString *const JKAudioSessionInterruptionTypeKey = @"MCAudioSessionInterruptionTypeKey";

static void JKAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState) {
    AudioSessionInterruptionType interruptionType = kAudioSessionInterruptionType_ShouldNotResume;
    UInt32 interruptionTypeSize = sizeof(interruptionType);
    AudioSessionGetProperty(kAudioSessionProperty_InterruptionType,
                            &interruptionTypeSize,
                            &interruptionType);
    NSDictionary *userInfo = @{JKAudioSessionInterruptionStateKey:@(inInterruptionState),
                               JKAudioSessionInterruptionTypeKey:@(interruptionType)};
    __unsafe_unretained JKAudioSession *audioSession = (__bridge JKAudioSession *)inClientData;
    [[NSNotificationCenter defaultCenter] postNotificationName:JKAudioSessionInterruptionNotification object:audioSession userInfo:userInfo];
}

static void JKAudioSessionRouteChangeListener(void *inClientData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange)
    {
        return;
    }
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    NSDictionary *userInfo = @{JKAudioSessionRouteChangeReason:@(routeChangeReason)};
    __unsafe_unretained JKAudioSession *audioSession = (__bridge JKAudioSession *)inClientData;
    [[NSNotificationCenter defaultCenter] postNotificationName:JKAudioSessionRouteChangeNotification object:audioSession userInfo:userInfo];
}

@implementation JKAudioSession

+ (id)sharedInstance {
    static dispatch_once_t once;
    static JKAudioSession *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self _initializeAudioSession];
    }
    return self;
}

- (void)dealloc
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, JKAudioSessionRouteChangeListener, (__bridge void *)self);
}

#pragma mark - public functions
- (BOOL)setActive:(BOOL)active
            error:(NSError *__autoreleasing *)outError {
    OSStatus status = AudioSessionSetActive(active);
    if (status == kAudioSessionNotInitialized)
    {
        [self _initializeAudioSession];
        status = AudioSessionSetActive(active);
    }
    [self _errorForOSStatus:status error:outError];
    return status == noErr;
}

- (BOOL)setActive:(BOOL)active
          options:(UInt32)options
            error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioSessionSetActiveWithFlags(active,options);
    if (status == kAudioSessionNotInitialized)
    {
        [self _initializeAudioSession];
        status = AudioSessionSetActiveWithFlags(active,options);
    }
    [self _errorForOSStatus:status error:outError];
    return status == noErr;
}

- (BOOL)setCategory:(UInt32)category
              error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,sizeof(category),&category);
    if (status == kAudioSessionNotInitialized)
    {
        [self _initializeAudioSession];
        status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,sizeof(category),&category);
    }
    [self _errorForOSStatus:status error:outError];
    return status == noErr;
}

- (BOOL)setProperty:(AudioSessionPropertyID)propertyID
           dataSize:(UInt32)dataSize
               data:(const void *)data
              error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioSessionSetProperty(propertyID,dataSize,data);
    if (status == kAudioSessionNotInitialized)
    {
        [self _initializeAudioSession];
        status = AudioSessionSetProperty(propertyID,dataSize,data);
    }
    [self _errorForOSStatus:status error:outError];
    return status == noErr;
}

- (BOOL)addPropertyListener:(AudioSessionPropertyID)propertyID
             listenerMethod:(AudioSessionPropertyListener)listenerMethod
                    context:(void *)context
                      error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioSessionAddPropertyListener(propertyID,listenerMethod,context);
    if (status == kAudioSessionNotInitialized)
    {
        [self _initializeAudioSession];
        status = AudioSessionAddPropertyListener(propertyID,listenerMethod,context);
    }
    [self _errorForOSStatus:status error:outError];
    return status == noErr;
}


- (BOOL)removePropertyListener:(AudioSessionPropertyID)propertyID
                listenerMethod:(AudioSessionPropertyListener)listenerMethod
                       context:(void *)context
                         error:(NSError *__autoreleasing *)outError
{
    OSStatus status = AudioSessionRemovePropertyListenerWithUserData(propertyID,listenerMethod,context);
    if (status == kAudioSessionNotInitialized)
    {
        [self _initializeAudioSession];
        status = AudioSessionRemovePropertyListenerWithUserData(propertyID,listenerMethod,context);
    }
    [self _errorForOSStatus:status error:outError];
    return status == noErr;
}

+ (BOOL)usingHeadset
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif
    
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    
    BOOL hasHeadset = NO;
    if((route == NULL) || (CFStringGetLength(route) == 0))
    {
        // Silent Mode
    }
    else
    {
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSString* routeStr = (__bridge NSString*)route;
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        
        if (headphoneRange.location != NSNotFound)
        {
            hasHeadset = YES;
        }
        else if(headsetRange.location != NSNotFound)
        {
            hasHeadset = YES;
        }
    }
    
    if (route)
    {
        CFRelease(route);
    }
    
    return hasHeadset;
}



#pragma mark - private functions

- (void)_initializeAudioSession {
    AudioSessionInitialize(NULL, NULL, JKAudioSessionInterruptionListener, (__bridge void *)self);
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, JKAudioSessionRouteChangeListener, (__bridge void *)self);
}


- (void)_errorForOSStatus:(OSStatus)status
                    error:(NSError *__autoreleasing *)outError {
    if (status != noErr && outError != NULL) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
}

+ (BOOL)isAirplayActived
{
    CFDictionaryRef currentRouteDescriptionDictionary = nil;
    UInt32 dataSize = sizeof(currentRouteDescriptionDictionary);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &dataSize, &currentRouteDescriptionDictionary);
    
    BOOL airplayActived = NO;
    if (currentRouteDescriptionDictionary)
    {
        CFArrayRef outputs = CFDictionaryGetValue(currentRouteDescriptionDictionary, kAudioSession_AudioRouteKey_Outputs);
        if(outputs != NULL && CFArrayGetCount(outputs) > 0)
        {
            CFDictionaryRef currentOutput = CFArrayGetValueAtIndex(outputs, 0);
            //Get the output type (will show airplay / hdmi etc
            CFStringRef outputType = CFDictionaryGetValue(currentOutput, kAudioSession_AudioRouteKey_Type);
            
            airplayActived = (CFStringCompare(outputType, kAudioSessionOutputRoute_AirPlay, 0) == kCFCompareEqualTo);
        }
        CFRelease(currentRouteDescriptionDictionary);
    }
    return airplayActived;
}





















@end
