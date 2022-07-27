//
//  RecordingVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "RecordingVC.h"
#import "AVFoundation/AVFAudio.h"
#import "Loop.h"
#import "Track.h"
#import "Parse/Parse.h"
#import "LoopStackVC.h"
#import "NewLoopVC.h"
#import "PlayStopButton.h"

@interface RecordingVC () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property AVAudioSession *recordingSession;
@property AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *recordingTimer;
@property (weak, nonatomic) IBOutlet PlayStopButton *playStopButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSURL *audioFileUrl;

@end

@implementation RecordingVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

# pragma mark - Initial View Controller setup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpVC];
}

-(void)setUpVC {
    if (self.loop.tracks == nil){
        self.loop.tracks = [NSMutableArray new];
    }
    [self recordingUnavailableUI];
    self.timerLabel.text = @"00:00";
    [self.playStopButton initWithColor:[UIColor systemGray2Color]];
    [self.playStopButton disable];
    self.doneButton.enabled = NO;
    
    self.recordingSession = [AVAudioSession sharedInstance];
    @try {
        NSError *setCategoryError = nil;
        NSError *setActiveError = nil;
        [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
        [self.recordingSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [self.recordingSession setActive:YES error:&setActiveError];
        [self.recordingSession requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted){
                    [self recordingAvailableUI];
                    [self setUpRecorder];
                } else{
                    [self recordingAlert:@"Make sure to enable recording via microphone on your System Settings."];
                }
            });
        }];
    } @catch (NSException *exception){
        [self recordingAlert:[NSString stringWithFormat:@"An exception occurred while setting up recording: %@", exception.name]];
    }
}

- (void)setUpRecorder {
    self.audioFileUrl = [self getRecordingFileUrl];
    NSDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError  *initRecorderError = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileUrl settings:recordSettings error:&initRecorderError];
    if (initRecorderError){
        NSLog(@"Error when initializing audiorecorder");
    }
    self.audioRecorder.delegate = self;
}

#pragma mark - UI

-(void)recordingAvailableUI {
    self.recordButton.enabled = YES;
    [self.recordButton setTitleColor:UIColor.systemRedColor forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor colorNamed:@"darker-system-red color"] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
}

-(void)recordingUnavailableUI {
    self.recordButton.enabled = NO;
    [self.recordButton setTitle:@"Recording Unavailable" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:UIColor.systemGrayColor forState:UIControlStateDisabled];
}

- (void)updateTimerLabel {
    if(self.audioRecorder.recording){
        NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
        formatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        self.timerLabel.text = [formatter stringFromTimeInterval:self.audioRecorder.currentTime];
    }
}

-(void)recordingAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Recording Alert"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Button Actions

- (IBAction)didTapRecord:(id)sender {
    if (self.audioRecorder.recording){
        [self finishRecording:YES];
    } else{
        self.timerLabel.text = @"00:00";
        [self startRecording];
    }
}

- (IBAction)didTapPlayStop:(id)sender {
    if (self.audioPlayer.playing){
        [self.audioPlayer stop];
        [self.playStopButton UIPlay];
    }
    else{
        [self.audioPlayer play];
        [self.playStopButton UIStop];
    }
}

- (IBAction)didTapDone:(id)sender {
    [self.audioPlayer stop];
    [self setUpLoopData];
    // Send loop data back to presenting view controller when dismissing
    UIViewController *presentingVC = self.presentingViewController;
    if ([presentingVC isKindOfClass:[UITabBarController class]]){
        UIViewController *tabItemVC = ((UITabBarController *) presentingVC).selectedViewController;
        if ([tabItemVC isKindOfClass:[NewLoopVC class]]){
            NewLoopVC *newLoopVC = (NewLoopVC *) tabItemVC;
            newLoopVC.loop = self.loop;
            [self dismissViewControllerAnimated:YES completion:nil];
            [newLoopVC performSegueWithIdentifier:@"RecordingDoneSegue" sender:nil];
        }
    } else if ([presentingVC isKindOfClass:[UINavigationController class]]){
        UIViewController *topVC = ((UINavigationController *) presentingVC).topViewController;
        if ([topVC isKindOfClass:[LoopStackVC class]]){
            LoopStackVC *loopStackVC = (LoopStackVC *) topVC;
            loopStackVC.loop = self.loop;
            [loopStackVC reloadLoopData];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        NSLog(@"Segue not supported");
    }
}

#pragma mark - Recording and playback

- (void)startRecording {
    self.audioPlayer = nil;
    self.doneButton.enabled = NO;
    [self.playStopButton disable];
    @try {
        [self.audioRecorder record];
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
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
        [self.recordButton setTitle:@"Re-record" forState:UIControlStateNormal];
        [self initializeAudioPlayer];
        self.doneButton.enabled = YES;
    }else{
        [self recordingAlert:@"An error occurred while recording, try again"];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (void)initializeAudioPlayer {
    NSAssert(self.audioFileUrl != nil, @"AudioFileUrl is null");
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileUrl error:nil];
    self.audioPlayer.delegate = self;
    self.playStopButton.enabled = YES;
    [self.playStopButton UIPlay];
}

/* AVAudioPlayer delegate method*/
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.playStopButton UIPlay];
}

#pragma mark - Miscellanous helper methods

-(void)setUpLoopData {
    NSAssert(self.audioFileUrl != nil, @"AudioFileUrl is null");
    NSError *dataError = nil;
    NSURL *audioFilePFUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",self.audioFileUrl.absoluteString]];
    
    NSData *audioData = [NSData dataWithContentsOfURL:audioFilePFUrl
                                options:NSDataReadingMappedIfSafe
                                error:&dataError];
    Track *track = [Track new];
    track.audioFilePF = [PFFileObject fileObjectWithData:audioData];
    track.composer = [PFUser currentUser];
    [self.loop.tracks addObject:track];
}

- (NSURL *)getRecordingFileUrl {
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/recording.m4a", DOCUMENTS_FOLDER]];
}

@end
