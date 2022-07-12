//
//  RecordingVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "RecordingVC.h"
#import "AVFoundation/AVFAudio.h"

@interface RecordingVC () <AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property AVAudioSession *recordingSession;
@property AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation RecordingVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

- (void)viewDidLoad {
    [super viewDidLoad];
    [self recordingUnavailableUI];
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


- (IBAction)didTapRecord:(id)sender {
    if (self.audioRecorder.recording){
        [self finishRecording:YES];
    } else{
        [self startRecording];
    }
    
}

- (void)setUpRecorder{
    NSURL *audioFileUrl = [self getRecordingFileUrl];
    NSDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError *__autoreleasing *initRecorderError = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:audioFileUrl settings:recordSettings error:initRecorderError];
    if (initRecorderError){
        NSLog(@"Error when initializing audiorecorder");
    }
    self.audioRecorder.delegate = self;
}

- (void)startRecording{
    @try {
        [self.audioRecorder record];
        [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
    } @catch (NSException *exception) {
        [self finishRecording:NO];
    }
}

- (void)finishRecording:(BOOL)success{
    [self.audioRecorder stop];
    if (success){
        [self.recordButton setTitle:@"Re-record" forState:UIControlStateNormal];
    }else{
        [self recordingAlert:@"An error occurred while recording, try again"];
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
}

- (IBAction)didTapPlay:(id)sender {
    // TODO: only show up when audio has already been recorded
    [self playAudio];
}

-(void) playAudio{
    // TODO: Either fix bug, or switch to AVAudioEngine
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/recording.m4a", DOCUMENTS_FOLDER];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [self.audioPlayer play];
}

- (NSURL *)getRecordingFileUrl{
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/recording.m4a", DOCUMENTS_FOLDER]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
