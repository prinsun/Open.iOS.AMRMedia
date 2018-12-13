AMRMedia
--------

## 说明
实现方式采用的是先录制, 再转换, 播放也是类似. 感觉这样不是很好, 所以后续如果有精力的话, 会把它进行改造. 采用`AudioQueue`来实现边解码边播放, 也可以实现边录制边编码.

另外, iOS上的`AudioFile`和`AudioFileStream`对AMR还是有完整的支持的,具体可以参考`AudioTookbox`类库中的实现.

## 录制

* 录制 Amr 格式的音频:

```objc
- (IBAction)startRecord:(id)sender
{
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"test.amr"];
    
    [recorder setSpeakMode:NO];
    [recorder recordWithURL:[NSURL URLWithString:recordFile]];
}

```

* 录制回调信息:

```objc
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
```

## 播放

* 播放指定 Amr 文件:

```objc
- (IBAction)playRecord:(id)sender
{
    NSString *recordFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"test.amr"];
    [player setSpeakMode:outputMode];
    [player playWithURL:[NSURL URLWithString:recordFile]];
}
```

* 更改播放输出 (听筒 | 扬声器)

```objc
- (IBAction)changeOuput:(id)sender
{
    outputMode = !outputMode;
    [player setSpeakMode:outputMode];
}
```


## 参考资料

http://www.cnblogs.com/guligei/p/3518761.html
