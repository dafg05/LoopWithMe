//
//  Recorder.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/26/22.
//

#import "RecordingManager.h"
#import "AVFoundation/AVFAudio.h"


@interface RecordingManager ()

@property AVAudioSession *recordingSession;
@property AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *recordingTimer;

@end

@implementation RecordingManager

- (void)setUpRecording:(nonnull RecordingView *)recordingView {
}

- (void)recordToggle:(nonnull RecordingView *)recordingView {
}

- (void)playbackToggle:(nonnull RecordingView *)recordingView {
}

- (void)doneRecording:(nonnull RecordingView *)recordingView {
}






@end
