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
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property BOOL recordingAvailable;

@end

@implementation RecordingVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recordingAvailable = NO;
    self.recordingSession = [AVAudioSession sharedInstance];
    self.warningLabel.text = @"";
    [self.recordButton setTitleColor:UIColor.systemGrayColor forState:UIControlStateNormal];
    [self.recordButton setTitle:@"Recording Unavailable" forState:UIControlStateNormal];
    @try {
        NSError *__autoreleasing *setCategoryError = nil;
        NSError *__autoreleasing *setActiveError = nil;
        [self.recordingSession setCategory:AVAudioSessionCategoryPlayAndRecord error:setCategoryError];
        [self.recordingSession setActive:YES error:setActiveError];
        [self.recordingSession requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted){
//                    [self loadRecordingUI];
                    NSLog(@"Permissions granted");
                    self.recordingAvailable = YES;
                    [self.recordButton setTitleColor:UIColor.systemRedColor forState:UIControlStateNormal];
                    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
                } else{
                    self.warningLabel.text = @"Make sure to enable recording via microphone in your System Settings.";
                }
            });
        }];
    } @catch (NSException *exception) {
        NSLog(@"An error occurred setting up a recording session: %@", exception.name);
    }
}

- (IBAction)didTapRecord:(id)sender {
    if (self.recordingAvailable){
        if (self.audioRecorder){
            [self finishRecording:YES];
        } else{
            [self startRecording];
        }
    }
}

- (void)startRecording{
    NSURL *audioFileUrl = [self getRecordingFileUrl];
    // Set recording settings
    NSDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError *__autoreleasing *initRecorderError = nil;
    // Initialize audioRecorder
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:audioFileUrl settings:recordSettings error:initRecorderError];
    if (initRecorderError){
        NSLog(@"Error when initializing audiorecorder");
    }
    else{
        @try {
            self.audioRecorder.delegate = self;
            [self.audioRecorder record];
            [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        } @catch (NSException *exception) {
            [self finishRecording:NO];
        }
    }
}

- (void)finishRecording:(BOOL)success{
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    if (success){
        [self.recordButton setTitle:@"Re-record" forState:UIControlStateNormal];
    }else{
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
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [player play];
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
