//
//  NewLoopVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import "NewLoopVC.h"
#import "Loop.h"
#import "LoopStackVC.h"
#import "Parse/Parse.h"

#import "RecordingView.h"
#import "RecordingManager.h"

static int const DEFAULT_BPM = 100;

@interface NewLoopVC () <RecordingManagerDelegate>

@property (weak, nonatomic) IBOutlet RecordingView *recordingView;
@property (strong, nonatomic) RecordingManager *recordingManager;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UISlider *bpmSlider;

@end

@implementation NewLoopVC

#define RECORDING_ALERT_TITLE @"Recording Alert"
#define ALERT_ACTION_TITLE @"Ok"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recordingManager = [[RecordingManager alloc] initWithRecordingView:self.recordingView];
    self.recordingManager.delegate = self;
    self.recordingManager.bpm = DEFAULT_BPM;
    self.bpmSlider.value = DEFAULT_BPM;
    self.bpmLabel.text = [NSString stringWithFormat:@"%d bpm", DEFAULT_BPM];
    self.recordingManager.newLoop = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.recordingManager setViewToInitialState];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"RecordingDoneSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        LoopStackVC *vc = (LoopStackVC *)navController.topViewController;
        vc.loop = self.loop;
        vc.newLoop = YES;
    }
}

#pragma mark - RecordingManagerDelegate Methods

- (void)doneRecording:(nonnull Track *)track {
    self.loop = [Loop new];
    self.loop.bpm = self.bpmSlider.value;
    self.loop.postAuthor = [PFUser currentUser];
    self.loop.tracks = [NSMutableArray new];
    self.loop.duration = (float) self.recordingManager.recordingDuration;
    [self.loop.tracks addObject:track];
    [self performSegueWithIdentifier:@"RecordingDoneSegue" sender:nil];
}

- (void)recordingAlert:(nonnull NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:RECORDING_ALERT_TITLE
                                                            message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:ALERT_ACTION_TITLE
                                             style:UIAlertActionStyleDefault
                                             handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

# pragma mark - Misc

- (IBAction)sliderDidChange:(id)sender {
    if (self.recordingManager.recording) {
        return;
    }
    UISlider *slider = (UISlider *) sender;
    int bpm = floor(slider.value);
    self.recordingManager.bpm = bpm;
    self.bpmLabel.text = [NSString stringWithFormat:@"%d bpm", bpm];
}

@end
