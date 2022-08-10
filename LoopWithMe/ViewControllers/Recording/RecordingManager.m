//
//  Recorder.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/26/22.
//

#import "RecordingManager.h"
#import "AVFoundation/AVFAudio.h"
#import "RecordingView.h"

#import "Parse/Parse.h"
#import "Track.h"

NSDate *pauseStart, *previousFireDate;

static float const TIMER_TOLERANCE = 0.003;
static float const TIMER_MULTIPLIER = 0.01;
static NSString const * BPM_KEY = @"bpm";
static float const DEFAULT_BPM = 100;
static float const NUM_OF_COUNTIN_BEATS = 4;
/* DON'T CHANGE */
static float const SECONDS_IN_MINUTE = 60.0;
static float const DEFAULT_RECORDING_DURATION = 20.0;

@interface RecordingManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, RecordingViewDelegate>

@property AVAudioSession *recordingSession;
@property AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioPlayer *countInPlayer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSURL *audioFileUrl;
@property (strong, nonatomic) RecordingView *recordingView;

@property CFAbsoluteTime lastTick;
@property int counter;
@property BOOL permissionToRecord;

@end

@implementation RecordingManager

#pragma mark - Initialization

- (instancetype)initWithRecordingView:(RecordingView *)recordingView  {
    self = [super init];
    if (self){
        self.recordingView = recordingView;
        [self customInit];
    }
    return self;
}

- (void)customInit{
    self.recordingView.delegate = self;
    // set up metronome
    NSString *path = [[NSBundle mainBundle] pathForResource:@"count-in-short" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.countInPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.countInPlayer prepareToPlay];
    [self.recordingView updateMagicLabelWithCountIn:0];
    
    if (!self.bpm) {
        self.bpm = DEFAULT_BPM;
    }
    
    // set up recording session
    self.recordingSession = [AVAudioSession sharedInstance];
    // TODO: Handle errors
    NSError *setCategoryError = nil;
    NSError *setActiveError = nil;
    [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&setCategoryError];
    [self.recordingSession setActive:YES error:&setActiveError];
    [self.recordingSession requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted){
                self.permissionToRecord = YES;
                [self.recordingView initialState:self.permissionToRecord];
                [self setUpRecorder];
            } else{
                [self.delegate recordingAlert:@"Make sure to enable recording via microphone on your System Settings."];
                self.permissionToRecord = NO;
            }
        });
    }];
}

- (void)setViewToInitialState {
    self.audioPlayer = nil;
    self.counter = 0;
    if ([self recording]){
        [self.audioRecorder stop];
    }
    [self.recordingView initialState:self.permissionToRecord];
}

#pragma mark - RecordingViewDelegate methods
- (void)playbackToggle {
    BOOL play;
    if (self.audioPlayer.playing){
        [self.audioPlayer pause];
        play = YES;
    } else {
        [self.audioPlayer play];
        play = NO;
    }
    [self.recordingView playStopUI:play];
}

- (void)startRecordingProcess {
    self.audioPlayer = nil;
    [self.recordingView countInState:NUM_OF_COUNTIN_BEATS :self.bpm];
    [self countIn];
}

- (void)stopRecordingStartPlayback {
    [self finishRecording:YES];
}

- (void)doneRecording {
    [self.audioPlayer stop];
    Track *track = [self createTrack];
    [self.delegate doneRecording:track];
}


#pragma mark - Count-in

- (void)countIn {
    self.counter = 1;
    float bpm = (float) self.bpm;
    NSTimer *countInTimer = [NSTimer timerWithTimeInterval:SECONDS_IN_MINUTE/bpm*TIMER_MULTIPLIER  target:self selector:@selector(tick:) userInfo:@{BPM_KEY:[NSNumber numberWithFloat:bpm]} repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:countInTimer forMode:NSDefaultRunLoopMode];
}

- (void)tick:(NSTimer *)timer {
    CFAbsoluteTime elapsedTime = CFAbsoluteTimeGetCurrent() - self.lastTick;
    float targetTime = SECONDS_IN_MINUTE/[(NSNumber *)[timer.userInfo objectForKey:BPM_KEY] floatValue];
    if ((elapsedTime > targetTime) || (fabs(elapsedTime - targetTime) < TIMER_TOLERANCE)) {
        if (self.counter == -1){ // manually invalidate timer
            [timer invalidate];
        } else if (self.counter > NUM_OF_COUNTIN_BEATS){
            if (self.recordingView.metronomeSwitch.on) {
                self.counter = 0; // done with count-in but keep timer for metronome
            }
            else {
                [timer invalidate];
            }
            [self.recordingView updateMagicLabelWithCountIn:0];
            [self countInDone];
        }
        else {
            self.lastTick = CFAbsoluteTimeGetCurrent();
            [self.countInPlayer play];
            if (self.counter > 0){ // if count-in is in progress
                [self.recordingView updateMagicLabelWithCountIn:self.counter];
                self.counter += 1;
            }
            else {
                NSAssert(self.recordingView.metronomeSwitch.on, @"Metronome is off but metronome timer stil running after count-in");
            }
        }
    }
}

- (BOOL)recording {
    return self.audioRecorder.isRecording;
}

#pragma mark - Private helper methods

- (void)setUpRecorder {
    self.audioFileUrl = [self getRecordingFileUrl];
    NSDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError  *initRecorderError = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileUrl settings:recordSettings error:&initRecorderError];
    // TODO: Handle error
    if (initRecorderError){
        NSLog(@"Error when initializing audiorecorder");
    }
    self.audioRecorder.delegate = self;
}

- (void)countInDone {
    [self.recordingView updateMagicLabelWithTimer:0];
    if (!self.recordingDuration || self.newLoop) {
        self.recordingDuration = DEFAULT_RECORDING_DURATION;
    }
    @try {
        [self.audioRecorder recordForDuration:self.recordingDuration];
        [self.recordingView recordingState:self.recordingDuration :self.newLoop];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecordingTimer)userInfo:nil repeats:YES];
    } @catch (NSException *exception) {
        NSLog(@"Didn't finish recording successfully");
        [self finishRecording:NO];
        [self.recordingView initialState:YES];
        return;
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag {
    [self finishRecording:flag];
}

- (void)finishRecording:(BOOL)success {
    [self.audioRecorder stop];
    if (self.recordingView.metronomeSwitch.on) {
        self.counter = -1; // turn off metronome
    }
    if (self.timer){
        [self.timer invalidate];
    }
    if (success){
        [self initializeAudioPlayer];
        if (self.newLoop){
            self.recordingDuration = self.audioPlayer.duration;

        }
    } else{
        [self.delegate recordingAlert:@"An error occurred while recording, try again"];
        [self.recordingView initialState:YES];
        return;
    }
    [self.audioPlayer prepareToPlay];
    [self.recordingView playbackState:[self.audioPlayer duration]];
    [self.audioPlayer play];
}

- (void) initializeAudioPlayer {
    NSAssert(self.audioFileUrl != nil, @"AudioFileUrl is null");
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileUrl error:nil];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops = -1;
}

- (void) updateRecordingTimer{
    [self.recordingView updateMagicLabelWithTimer:self.audioRecorder.currentTime];
}
- (NSURL *)getRecordingFileUrl {
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/recording.m4a", NSTemporaryDirectory()]];
}

- (Track *)createTrack {
    NSError *dataError = nil;
    NSURL *audioFilePFUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",self.audioFileUrl.absoluteString]];
    
    NSData *audioData = [NSData dataWithContentsOfURL:audioFilePFUrl
                                options:NSDataReadingMappedIfSafe
                                error:&dataError];
    Track *track = [Track new];
    track.audioFilePF = [PFFileObject fileObjectWithData:audioData];
    track.composer = [PFUser currentUser];
    return track;
}

@end
