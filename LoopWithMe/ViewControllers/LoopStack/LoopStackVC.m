//
//  LoopStackVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "LoopStackVC.h"
#import "LoopTrackCell.h"
#import "AVFoundation/AVFAudio.h"
#import "RecordingVC.h"
#import "ShareVC.h"
#import "PlayStopButton.h"
#import "TrackFileManager.h"
#import "RecordingView.h"

@interface LoopStackVC () <UITableViewDataSource, LoopTrackCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *trackTableView;
@property (weak, nonatomic) IBOutlet PlayStopButton *playMixButton;
@property (weak, nonatomic) IBOutlet PlayStopButton *stopMixButton;
@property AVAudioEngine *audioEngine;
@property AVAudioMixerNode *mixerNode;
@property (strong, nonatomic) TrackFileManager *fileManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UILabel *trackCountLabel;
@property (strong, nonatomic) RecordingView *recordingview;

@end

@implementation LoopStackVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define MAX_NUM_TRACKS 8

#pragma mark - Initial View Controller Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpVC];
    NSLog(@"%lu", (unsigned long)[self.loop.tracks count]);
}

- (void)setUpVC {
    if (self.readOnly){
        self.shareButton.enabled = NO;
        self.addTrackButton.hidden = YES;
    }
    self.trackTableView.dataSource = self;
    self.trackTableView.allowsMultipleSelectionDuringEditing = NO;
    self.loopNameLabel.text = self.loop.name;
    [self.playMixButton initWithColor:[UIColor blackColor]];
    [self.playMixButton UIPlay];
    [self.stopMixButton initWithColor:[UIColor blackColor]];
    [self.stopMixButton UIStop];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.mixerNode = [[AVAudioMixerNode alloc] init];
    self.fileManager = [[TrackFileManager alloc] initWithPath:DOCUMENTS_FOLDER withSize:MAX_NUM_TRACKS];
    [self updateTrackCountLabel];
}

#pragma mark - UITableViewDataSource methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LoopTrackCell *cell = [self.trackTableView dequeueReusableCellWithIdentifier:
                           @"LoopTrackCell"];
    cell.layer.cornerRadius = 5;
    cell.track = self.loop.tracks[indexPath.row];
    cell.delegate = self;
    [cell.playTrackButton initWithColor:[UIColor blackColor]];
    [cell.playTrackButton UIPlay];
    cell.trackNumberLabel.text = @"Track";
    NSData *audioData = [cell.track.audioFilePF getData];
    cell.trackAudioUrl = [self.fileManager writeToAvailableUrl:audioData];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loop.tracks count];
}

- (void)updateTrackCountLabel {
    self.trackCountLabel.text = [NSString stringWithFormat:@"%lu/%d tracks", (unsigned long)[self.loop.tracks count], MAX_NUM_TRACKS];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Cannot delete if there's only one track
    if (self.readOnly) return NO;
    return ([self.loop.tracks count] > 1);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LoopTrackCell *cellToDelete =  [tableView cellForRowAtIndexPath:indexPath];
        [self.fileManager freeUrl:cellToDelete.trackAudioUrl];
        [self.loop.tracks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateTrackCountLabel];
    }
}

#pragma mark - Button Actions

- (IBAction)didTapPlayMix:(id)sender {
    [self startMix];
}

- (IBAction)didTapStopMix:(id)sender {
    [self.audioEngine stop];
}

- (IBAction)didTapAddTrack:(id)sender {
    if ([self.loop.tracks count] < MAX_NUM_TRACKS){
        [self.audioEngine stop];
        [self performSegueWithIdentifier:@"AddTrackSegue" sender:nil];
    }
}

- (IBAction)didTapShare:(id)sender {
    [self performSegueWithIdentifier:@"ShareSegue" sender:nil];
}

- (IBAction)didTapBack:(id)sender {
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

/* LoopTrack cell delegate method: called when LoopTrackCell button is pressed*/
- (void)playTrack:(NSURL *)trackUrl {
    [self startTrack:trackUrl];
}

#pragma mark - Playback

-(void)startMix {
    // TODO: inconsistent audioEngine start between startMix and startTrack
    [self.audioEngine stop];
    [self.audioEngine attachNode:self.mixerNode];
    [self.audioEngine connect:self.mixerNode to:self.audioEngine.outputNode format:nil];

    NSError *startError = nil;
    [self.audioEngine startAndReturnError:&startError];

    if (startError != nil){
        NSLog(@"%@", startError.localizedDescription);
    }else{
        for (int section = 0; section < [self.trackTableView numberOfSections]; section++){
            for (int row = 0; row < [self.trackTableView numberOfRowsInSection:section]; row++){
                NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
                LoopTrackCell* cell = [self.trackTableView cellForRowAtIndexPath:cellPath];
                NSURL *trackUrl = cell.trackAudioUrl;
                AVAudioPlayerNode *playerNode = [[AVAudioPlayerNode alloc] init];
                [self.audioEngine attachNode:playerNode];
                NSError *readingError = NULL;
                AVAudioFile *file = [[AVAudioFile alloc] initForReading:trackUrl.absoluteURL error:&readingError];
                [self.audioEngine connect:playerNode to:self.mixerNode format:file.processingFormat];
                [playerNode scheduleFile:file atTime:nil completionHandler:nil];
                [playerNode play];
            }
        }
    }
}

- (void)startTrack:(NSURL *)trackUrl {
    [self.audioEngine stop];
    NSError *creationError = NULL;
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:trackUrl.absoluteURL error:&creationError];
    if (creationError != nil){
        NSLog(@"Error initializing AVAudioFile when playing track");
    }
    else{
        AVAudioPlayerNode *playerNode = [[AVAudioPlayerNode alloc] init];
        [self.audioEngine attachNode:playerNode];
        [self.audioEngine connect:playerNode to:self.audioEngine.outputNode format:file.processingFormat];
        NSError *startError = NULL;
        [self.audioEngine startAndReturnError:&startError];
        [playerNode scheduleFile:file atTime:nil completionHandler:nil];
        if (startError != nil){
            NSLog(@"%@", startError.localizedDescription);
        }
        else{
            [playerNode play];
        }
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShareSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        ShareVC *vc = (ShareVC *)navController.topViewController;
        vc.loop = self.loop;
    }
    else if ([[segue identifier] isEqualToString:@"AddTrackSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        RecordingVC *vc = (RecordingVC *)navController.topViewController;
        vc.loop = self.loop;
    }
}

/* Needs to be called if tableView is reloaded */
-(void)reloadLoopData {
    // TODO: Refactor so that we don't need to reload the whole table view.
    // need to reinitialize the file manager because every cell is being reloaded
    self.fileManager = nil;
    self.fileManager = [[TrackFileManager alloc] initWithPath:DOCUMENTS_FOLDER withSize:MAX_NUM_TRACKS];
    [self updateTrackCountLabel];
    [self.trackTableView reloadData];
}

- (IBAction)didTapPrototype:(id)sender {
    self.recordingview = [[RecordingView alloc] init];
    [self.recordingview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.recordingview];
    [self.recordingview.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.recordingview.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.recordingview.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.recordingview.heightAnchor constraintEqualToConstant:250].active = YES;
    [self.view bringSubviewToFront:self.recordingview];
}

@end
