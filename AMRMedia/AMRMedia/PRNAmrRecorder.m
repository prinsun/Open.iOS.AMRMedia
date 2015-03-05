//
//  PRNAmrRecorder.m
//  AMRMedia
//
//  Created by 翁阳 on 14/11/21.
//  Copyright (c) 2014年 prinsun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PRNAmrRecorder.h"
#import "amr_wav_converter.h"

@interface PRNAmrRecorder () <AVAudioRecorderDelegate>
{
    AVAudioRecorder *audioRecorder;
    
    NSURL *tempRecordFileURL;
    NSURL *currentRecordFileURL;
    
    BOOL isRecording;
    dispatch_source_t timer;
}

@end

@implementation PRNAmrRecorder


- (instancetype)init
{
    if (self = [super init]) {
        [self p_setupAudioRecorder];
    }
    return self;
}

- (void)dealloc
{
    if (isRecording) [audioRecorder stop];
}

- (void)p_setupAudioRecorder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"records"];
    
    if (![fileManager fileExistsAtPath:recordFilePath]) {
        [fileManager createDirectoryAtPath:recordFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *recordFile = [recordFilePath stringByAppendingPathComponent:@"rec.wav"];
    tempRecordFileURL = [NSURL URLWithString:recordFile];
    
    NSDictionary *recordSetting = @{ AVSampleRateKey        : @8000.0,                      // 采样率
                                     AVFormatIDKey          : @(kAudioFormatLinearPCM),     // 音频格式
                                     AVLinearPCMBitDepthKey : @16,                          // 采样位数 默认 16
                                     AVNumberOfChannelsKey  : @1                            // 通道的数目
                                     };
    
    // AVLinearPCMIsBigEndianKey    大端还是小端 是内存的组织方式
    // AVLinearPCMIsFloatKey        采样信号是整数还是浮点数
    // AVEncoderAudioQualityKey     音频编码质量
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:tempRecordFileURL
                                                settings:recordSetting
                                                   error:nil];
    
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
}


- (void)recordWithURL:(NSURL *)fileUrl;
{
    if (isRecording) return;
    
    [self p_prepareRecordFileURL:fileUrl];
    
    [audioRecorder prepareToRecord];
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    
    [audioRecorder record];
    isRecording = YES;
    
    [self p_createPickSpeakPowerTimer];
    
}

- (void)p_prepareRecordFileURL:(NSURL *)fileUrl
{
    currentRecordFileURL = fileUrl;
    
    NSString *wavFileUrlString = [fileUrl.absoluteString stringByAppendingString:@".wav"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:wavFileUrlString]) {
        [fileManager removeItemAtPath:wavFileUrlString error:nil];
    }
}

- (void)p_createPickSpeakPowerTimer
{
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_source_set_event_handler(timer, ^{
        __strong __typeof(weakSelf) _self = weakSelf;
        
        if ([_self.delegate respondsToSelector:@selector(recorder:didPickSpeakPower:)]) {
            [_self->audioRecorder updateMeters];
            
            double lowPassResults = pow(10, (0.05 * [_self->audioRecorder peakPowerForChannel:0]));
            [_self.delegate recorder:_self didPickSpeakPower:lowPassResults];
        }
    });
    
    dispatch_resume(timer);
}

- (void)stop;
{
    if (!isRecording) return;
    
    [audioRecorder stop];
}

- (void)setSpeakMode:(BOOL)speakMode
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        AVAudioSessionPortOverride portOverride = speakMode ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:portOverride error:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UInt32 route = speakMode ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
#pragma clang diagnostic pop
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - AVAudioRecorderDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
   int frames = wave_file_to_amr_file([tempRecordFileURL.absoluteString cStringUsingEncoding:NSASCIIStringEncoding],
                          [currentRecordFileURL.absoluteString cStringUsingEncoding:NSASCIIStringEncoding], 1, 16);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *wavFileUrlString = [currentRecordFileURL.absoluteString stringByAppendingString:@".wav"];
    [fileManager copyItemAtPath:tempRecordFileURL.absoluteString toPath:wavFileUrlString error:nil];
    
    if ([self.delegate respondsToSelector:@selector(recorder:didRecordWithFile:)]) {
        
        PRNAmrFileInfo *recFileInfo = [[PRNAmrFileInfo alloc] init];
        recFileInfo.fileUrl = currentRecordFileURL;
        recFileInfo.fileSize = [fileManager attributesOfItemAtPath:currentRecordFileURL.path error:nil].fileSize;
        recFileInfo.duration = (double)frames * 20.0 / 1000.0;
        
        [self.delegate recorder:self didRecordWithFile:recFileInfo];
    }
    
    if (timer) {
        dispatch_source_cancel(timer);
        timer = NULL;
    }
    
    isRecording = NO;
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    [recorder stop];
}


@end

@implementation PRNAmrFileInfo @end
