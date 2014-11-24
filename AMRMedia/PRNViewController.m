//
//  PRNViewController.m
//  AMRMedia
//
//  Created by 翁阳 on 14/11/21.
//  Copyright (c) 2014年 prinsun. All rights reserved.
//

#import "PRNViewController.h"
#import "PRNAmrRecorder.h"
#import "PRNAmrPlayer.h"

#define PATH_OF_DOCUMENT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface PRNViewController () <PRNAmrRecorderDelegate>
{
    PRNAmrRecorder *recorder;
    PRNAmrPlayer *player;
    
    BOOL outputMode;
}

@property (weak, nonatomic) IBOutlet UILabel *powerLabel;

@end

@implementation PRNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    recorder = [[PRNAmrRecorder alloc] init];
    recorder.delegate = self;
    
    player = [[PRNAmrPlayer alloc] init];
}

- (IBAction)startRecord:(id)sender
{
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"test.amr"];
    
    [recorder setSpeakMode:NO];
    [recorder recordWithURL:[NSURL URLWithString:recordFile]];
}

- (IBAction)stopRecord:(id)sender
{
    [recorder stop];
}

- (IBAction)playRecord:(id)sender
{
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"test.amr"];
    [player setSpeakMode:outputMode];
    [player playWithURL:[NSURL URLWithString:recordFile]];
}

- (IBAction)changeOuput:(id)sender
{
    outputMode = !outputMode;
    [player setSpeakMode:outputMode];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PRNAmrRecorderDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)recorder:(PRNAmrRecorder *)aRecorder didRecordWithFile:(PRNAmrFileInfo *)fileInfo
{
    NSLog(@"==================================================================");
    NSLog(@"record with file : %@", fileInfo.fileUrl);
    NSLog(@"file size: %llu", fileInfo.fileSize);
    NSLog(@"file duration : %f", fileInfo.duration);
     NSLog(@"==================================================================");
}

- (void)recorder:(PRNAmrRecorder *)aRecorder didPickSpeakPower:(float)power
{
    self.powerLabel.text = [NSString stringWithFormat:@"%f", power];
}

@end
