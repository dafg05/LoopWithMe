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

static NSString *const COUNT_IN_FILE = @"countin-short";
static NSString *const COUNT_IN_FILE_TYPE = @"wav";
static int const HARDCODED_TEMPO = 150;

@interface RecordingManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, RecordingViewDelegate>

@property AVAudioSession *recordingSession;
@property AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *countInPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) NSTimer *recordingTimer;
@property (strong, nonatomic) NSURL *audioFileUrl;
@property (strong, nonatomic) RecordingView *recordingView;

/* For count-in */
@property (assign, nonatomic) int bpm;
@property int counter;
@property float duration;

@end

@implementation RecordingManager

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#pragma mark - Initialization

- (instancetype)initWithRecordingView:(RecordingView *)recordingView {
    self = [super init];
    if (self){
        /* Set up recordingView*/
        self.recordingView = recordingView;
        self.recordingView.delegate = self;
        
        /* Set up countInPlayer */
        NSString *path = [[NSBundle mainBundle] pathForResource:COUNT_IN_FILE ofType:COUNT_IN_FILE_TYPE];
        NSURL *countInUrl = [NSURL fileURLWithPath:path];
        self.countInPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:countInUrl error:nil];
        self.countInPlayer.delegate = self;
        [self.countInPlayer prepareToPlay];
        NSLog(@"%f", self.duration);
        // TODO: remove hard code;
        self.bpm = HARDCODED_TEMPO;
        
        [self customInit];
    }
    return self;
}

- (void)customInit{
    self.recordingSession = [AVAudioSession sharedInstance];
    // TODO: Deal with errors
    NSError *setCategoryError = nil;
    NSError *setActiveError = nil;
    [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
    [self.recordingSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [self.recordingSession setActive:YES error:&setActiveError];
    [self.recordingSession requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted){
                [self.recordingView recordingAvailableUI];
                [self setUpRecorder];
            } else{
                [self.delegate recordingAlert:@"Make sure to enable recording via microphone on your System Settings."];
            }
        });
    }];
}

#pragma mark - RecordingViewDelegate methods

- (void)recordToggle{
    if (self.audioRecorder.recording){
        [self finishRecording:YES];
    } else{
        self.counter = 1;
        [self.recordingView startCountInUI];
        [self.recordingView updateCountInLabel:self.counter];
        [self.countInPlayer play];
    }
}

- (void)playbackToggle {
    if (self.audioPlayer.playing){
        [self.audioPlayer stop];
        [self.recordingView.playStopButton UIPlay];
    } else{
        [self.audioPlayer play];
        [self.recordingView.playStopButton UIStop];
    }
}

- (void)doneRecording {
    [self.audioPlayer stop];
    Track *track = [self createTrack];
    [self.delegate doneRecording:track];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    float delay = (60 / (float)self.bpm) - self.countInPlayer.duration;
    if (player == self.countInPlayer) {
        if (self.counter == 4) {
            [self scheduleRecording:delay];
        }
        else {
            [self runPlayer:player delay:delay];
            self.counter += 1;
            [self.recordingView updateCountInLabel:self.counter];
        }
    } else if (player == self.audioPlayer) {
        [self.recordingView.playStopButton UIPlay];
    }
}

#pragma mark - Count-in feature

- (void)runPlayer:(AVAudioPlayer *)player delay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [player play];
    });
}

- (void)scheduleRecording:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startRecording];
    });
}

#pragma mark - Private helper methods

- (void)setUpRecorder {
    // TODO: Use temporary directory
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

- (void)startRecording {
    self.audioPlayer = nil;
    @try {
        [self.audioRecorder record];
        [self.recordingView currentlyRecordingUI];
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(viewUpdateTimer)userInfo:nil repeats:YES];
    } @catch (NSException *exception) {
        [self finishRecording:NO];
    }
}

- (void)finishRecording:(BOOL)success {
    [self.audioRecorder stop];
    if (self.recordingTimer){
        [self.recordingTimer invalidate];
    }
    if (success){
        [self.recordingView doneRecordingUI];
        [self initializeAudioPlayer];
    } else{
        [self.delegate recordingAlert:@"An error occurred while recording, try again"];
        [self.recordingView recordingAvailableUI];
    }
}

- (void) initializeAudioPlayer {
    NSAssert(self.audioFileUrl != nil, @"AudioFileUrl is null");
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileUrl error:nil];
    self.audioPlayer.delegate = self;
    [self.recordingView playbackEnabledUI];
}

- (void) viewUpdateTimer {
    [self.recordingView updateTimerLabel:self.audioRecorder.currentTime];
}

- (NSURL *)getRecordingFileUrl {
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/recording.m4a", DOCUMENTS_FOLDER]];
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
