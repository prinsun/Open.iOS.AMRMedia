//
//  PRNAmrRecorder.h
//  AMRMedia
//
//  Created by 翁阳 on 14/11/21.
//  Copyright (c) 2014年 prinsun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PRNAmrRecorderDelegate;

/**
 *  AMR 录音器
 */
@interface PRNAmrRecorder : NSObject

/**
 *  开始录音
 *
 *  @param fileUrl 录音要保存的路径
 */
- (void)recordWithURL:(NSURL *)fileUrl;

/**
 *  结束录音
 */
- (void)stop;

/**
 *  使用免提, 还是耳机线进行录制
 *
 *  @param speakMode 是否使用免提录制
 */
- (void)setSpeakMode:(BOOL)speakMode;

/**
 *  录音器委托
 */
@property (nonatomic, weak) id<PRNAmrRecorderDelegate> delegate;


@end


/**
 *  录音器委托
 */
@protocol PRNAmrRecorderDelegate <NSObject>
@optional

/**
 *  录音完毕的回调
 *
 *  @param aRecorder 录音器
 *  @param fileUrl   产生的录音文件
 */
- (void)recorder:(PRNAmrRecorder *)aRecorder didRecordWithFile:(NSURL *)fileUrl;


/**
 *  录音时, 语音大小值
 *
 *  @param aRecorder 录音器
 *  @param power     音量大小 (0f - 1f)
 */
- (void)recorder:(PRNAmrRecorder *)aRecorder didPickSpeakPower:(float)power;

@end
