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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *trackCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *loopStatusLabel;

@property AVAudioEngine *audioEngine;
@property AVAudioMixerNode *mixerNode;
@property (strong, nonatomic) TrackFileManager *fileManager;
/* For relooping*/
@property BOOL editMode;
@property (strong, nonatomic) Loop *parentLoop;
@property (strong, nonatomic) Loop *cachedReloop;

@end

@implementation LoopStackVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define MAX_NUM_TRACKS 8

#define NEW_LOOP_STATUS @"New Loop Mix"
#define OTHER_LOOP_STATUS @"Loop Mix"
#define RELOOP_STATUS @"Reloop mix"

#pragma mark - Initial View Controller Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpVC];
}

- (void)setUpVC {
    if (self.newLoop){
        self.editButton.hidden = YES;
        self.editMode = YES;
        self.loopStatusLabel.text = NEW_LOOP_STATUS;
        self.loopNameLabel.text = @"Untitled";
    }
    else {
        self.shareButton.enabled = NO;
        self.addTrackButton.hidden = YES;
        self.editMode = NO;
        self.loopStatusLabel.text = OTHER_LOOP_STATUS;
        self.loopNameLabel.text = self.loop.name;
    }
    self.trackTableView.dataSource = self;
    self.trackTableView.allowsMultipleSelectionDuringEditing = NO;
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
    if (!self.editMode) return NO;
    // Cannot delete if there's only one track
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RecordingVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"RecordingVC"];
        UISheetPresentationController *sheet = vc.sheetPresentationController;
        sheet.detents = [NSArray arrayWithObject:[UISheetPresentationControllerDetent mediumDetent]];
        vc.loop = self.loop;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)didTapShare:(id)sender {
    [self performSegueWithIdentifier:@"ShareSegue" sender:nil];
}

- (IBAction)didTapBack:(id)sender {
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapEdit:(id)sender {
    if (self.editMode){
        [self cancelEditLoop];
    }
    else{
        [self canEditLoop];
    }
}

/* LoopTrack cell delegate method: called when LoopTrackCell button is pressed*/
- (void)playTrack:(NSURL *)trackUrl {
    [self startTrack:trackUrl];
}

#pragma mark - Playback

- (void)startMix {
    // TODO: inconsistent audioEngine start between startMix and startTrack
    [self.audioEngine stop];
    [self.audioEngine attachNode:self.mixerNode];
    [self.audioEngine connect:self.mixerNode to:self.audioEngine.outputNode format:nil];

    NSError *startError = nil;
    [self.audioEngine startAndReturnError:&startError];

    if (startError != nil){
        NSLog(@"%@", startError.localizedDescription);
    } else{
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShareSegue"]){
        ShareVC *vc = (ShareVC *)segue.destinationViewController;
        vc.loop = self.loop;
        if (self.newLoop){
            vc.isLoopReloop = NO;
        } else{
            NSAssert(self.loop.parentLoop != nil, @"Not sharing a reloop nor a new loop");
            vc.isLoopReloop = YES;
        }
    }
    else if ([[segue identifier] isEqualToString:@"AddTrackSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        RecordingVC *vc = (RecordingVC *)navController.topViewController;
        vc.loop = self.loop;
    }
}

/* Needs to be called to reload table view outside of ViewDidLoad */
- (void)reloadLoopTableViewData {
    // TODO: Refactor so that we don't need to reload the whole table view.
    // need to reinitialize the file manager because every cell is being reloaded
    self.fileManager = nil;
    self.fileManager = [[TrackFileManager alloc] initWithPath:DOCUMENTS_FOLDER withSize:MAX_NUM_TRACKS];
    [self updateTrackCountLabel];
    [self.trackTableView reloadData];
}

#pragma mark - Relooping helpers

- (void)canEditLoop {
    NSAssert(!self.newLoop, @"Edit mode is not mutable in newLoop");
    [self.audioEngine stop];
    [self setUpReloop];
    self.editMode = YES;
    [self.editButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.addTrackButton.hidden = NO;
    self.shareButton.enabled = YES;
    self.loopStatusLabel.text = RELOOP_STATUS;
}

- (void)cancelEditLoop {
    NSAssert(!self.newLoop, @"Edit mode is not mutable in newLoop");
    [self.audioEngine stop];
    [self discardReloop];
    self.editMode = NO;
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    self.addTrackButton.hidden = YES;
    self.shareButton.enabled = NO;
    self.loopStatusLabel.text = self.loopStatusLabel.text = OTHER_LOOP_STATUS;
}

- (void)setUpReloop {
    self.parentLoop = self.loop;
    if (self.cachedReloop){
        NSLog(@"Did this!");
        self.loop = self.cachedReloop;
    }
    else{
        self.loop = [Loop new];
        self.loop.bpm = self.parentLoop.bpm;
        self.loop.tracks = [NSMutableArray arrayWithArray:self.parentLoop.tracks];
        self.loop.postAuthor = [PFUser currentUser];
        self.loop.parentLoop = self.parentLoop;
    }
    [self reloadLoopTableViewData];
    NSAssert (self.loop != self.parentLoop, @"Pointer to loop and parent loop are the same");
}

- (void)discardReloop {
    self.cachedReloop = self.loop;
    self.loop = self.parentLoop;
    [self reloadLoopTableViewData];
    NSAssert(!self.loop.dirty, @"Original loop was somehow modified");
}

@end
