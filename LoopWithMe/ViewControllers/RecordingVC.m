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
#import "LoopStack/LoopStackVC.h"

@interface RecordingVC () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property AVAudioSession *recordingSession;
@property AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *recordingTimer;
@property (weak, nonatomic) IBOutlet UIButton *playStopButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSURL *audioFileUrl;

@end

@implementation RecordingVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"loop name: %@", self.loop.name);
    self.loop.tracks = [NSMutableArray new];
    [self recordingUnavailableUI];
    self.timerLabel.text = @"00:00";
    self.playStopButton.enabled = NO;
    self.doneButton.enabled = NO;
    [self.playStopButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.playStopButton setTitleColor:UIColor.systemGrayColor forState:UIControlStateDisabled];
    
    self.recordingSession = [AVAudioSession sharedInstance];
    @try {
        NSError *__autoreleasing *setCategoryError = nil;
        NSError *__autoreleasing *setActiveError = nil;
        [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:setCategoryError];
        [self.recordingSession setActive:YES error:setActiveError];
        [self.recordingSession requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted){
                    NSLog(@"Permissions granted");
                    [self recordingAvailableUI];
                    [self setUpRecorder];
                } else{
                    [self recordingAlert:@"Make sure to enable recording via microphone on your System Settings."];
                }
            });
        }];
    } @catch (NSException *exception) {
        [self recordingAlert:[NSString stringWithFormat:@"An exception occurred while setting up recording: %@", exception.name]];
    }
}

-(void) recordingAlert:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Recording Alert"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) recordingUnavailableUI{
    self.recordButton.enabled = NO;
    [self.recordButton setTitle:@"Recording Unavailable" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:UIColor.systemGrayColor forState:UIControlStateDisabled];
}

-(void) recordingAvailableUI{
    self.recordButton.enabled = YES;
    [self.recordButton setTitleColor:UIColor.systemRedColor forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor colorNamed:@"darker-system-red color"] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
}

- (void)setUpRecorder{
    self.audioFileUrl = [self getRecordingFileUrl];
    NSDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError *__autoreleasing *initRecorderError = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileUrl settings:recordSettings error:initRecorderError];
    if (initRecorderError){
        NSLog(@"Error when initializing audiorecorder");
    }
    self.audioRecorder.delegate = self;
}


- (IBAction)didTapRecord:(id)sender {
    NSLog(@"%lu", (unsigned long)[self.loop.tracks count]);
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
        [self.playStopButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else{
        [self.audioPlayer play];
        [self.playStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)startRecording{
    // deallocate audioPlayer in case this is a re-recording
    self.audioPlayer = nil;
    self.playStopButton.enabled = NO;
    self.doneButton.enabled = NO;
    [self.playStopButton setTitle:@"Play" forState:UIControlStateNormal];
    @try {
        [self.audioRecorder record];
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    } @catch (NSException *exception) {
        [self finishRecording:NO];
    }
}

-(void)updateTimerLabel{
    if(self.audioRecorder.recording){
        NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
        formatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        self.timerLabel.text = [formatter stringFromTimeInterval:self.audioRecorder.currentTime];
        
    }
}

- (void)finishRecording:(BOOL)success{
    [self.audioRecorder stop];
    if (self.recordingTimer){
        [self.recordingTimer invalidate];
    }
    if (success){
        [self.recordButton setTitle:@"Re-record" forState:UIControlStateNormal];
        // only initialize audioplayer once we're done recording
        [self initializeAudioPlayer];
        self.doneButton.enabled = YES;
    }else{
        [self recordingAlert:@"An error occurred while recording, try again"];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (void) initializeAudioPlayer{
    NSAssert(self.audioFileUrl != nil, @"AudioFileUrl is null");
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioFileUrl error:nil];
    self.audioPlayer.delegate = self;
    self.playStopButton.enabled = YES;
}

- (NSURL *)getRecordingFileUrl{
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/recording.m4a", DOCUMENTS_FOLDER]];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.playStopButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (IBAction)didTapDone:(id)sender {
    [self.audioPlayer stop];
    [self setUpLoopData];
    [self performSegueWithIdentifier:@"RecordingDoneSegue" sender:nil];
}

-(void) setUpLoopData{
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
//    [self testPFFilePlayback];
}

- (void) testPFFilePlayback{
    NSURL *myUrl = [self getRecordingFileUrl];
    PFFileObject *file = self.loop.tracks[0].audioFilePF;
    NSData *audioData = [file getData];
    BOOL success = [audioData writeToURL:myUrl atomically:YES];
    if (!success) NSLog (@"OHHH SHITTTTT");
    NSError *playingError = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:myUrl error:&playingError];
    if (playingError){
        NSLog(@"playing error: %@", playingError.localizedDescription);
    }
    [self.audioPlayer play];
}







#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    LoopStackVC *vc = (LoopStackVC *)navController.topViewController;
    vc.loop = self.loop;
}


@end
