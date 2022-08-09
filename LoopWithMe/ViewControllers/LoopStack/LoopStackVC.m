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
#import "TrackPlayerModel.h"

static int const MAX_NUM_TRACKS = 8;
static NSString *const NEW_LOOP_STATUS = @"New Loop Mix";
static NSString *const OTHER_LOOP_STATUS = @"Loop Mix";
static NSString *const RELOOP_STATUS = @"Reloop mix";

@interface LoopStackVC () <UITableViewDataSource, LoopTrackCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *trackTableView;
@property (weak, nonatomic) IBOutlet PlayStopButton *playStopMixButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *trackCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *loopStatusLabel;
/* mixing */
@property AVAudioEngine *audioEngine;
@property AVAudioMixerNode *mixerNode;
@property (strong, nonatomic) NSMutableDictionary *trackPlayerDict;
@property (strong, nonatomic) TrackFileManager *fileManager;
@property long long mixFrameCount;
/* For relooping*/
@property BOOL editMode;
@property (strong, nonatomic) Loop *parentLoop;
@property (strong, nonatomic) Loop *cachedReloop;

@end

@implementation LoopStackVC

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
    [self.playStopMixButton initWithColor:[UIColor blackColor]];
    [self.playStopMixButton UIPlay];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.mixerNode = [[AVAudioMixerNode alloc] init];
    self.fileManager = [[TrackFileManager alloc] initWithPath:NSTemporaryDirectory() withSize:MAX_NUM_TRACKS];
//    self.trackUrlDict = [NSMutableDictionary new];
    
    [self updateTrackCountLabel];
    [self setUpMixer];
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
        [self stopMix];
        LoopTrackCell *cellToDelete =  [tableView cellForRowAtIndexPath:indexPath];
        NSURL *urlToFree = [self getTPModelFromTrack:cellToDelete.track].url;
        [self.fileManager freeUrl:urlToFree];
        [self.trackPlayerDict removeObjectForKey:self.loop.tracks[indexPath.row]]; // does this deallocate the trackPlayerModel?
        [self.loop.tracks removeObjectAtIndex:indexPath.row];
        [self setUpMixer];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateTrackCountLabel];
    }
}

#pragma mark - Button Actions

- (IBAction)didTapPlayStopMix:(id)sender {
    if (self.audioEngine.isRunning){
        [self stopMix];
    }
    else {
        [self startMix];
        
    }
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

/* LoopTrack cell delegate method: called when LoopTrackCell button is pressed */
- (void)playTrack:(Track *)track {
    [self.audioEngine stop];
    NSLog(@"Not refactored yet!");
}

#pragma mark - Playback

- (void)startMix {
    [self.audioEngine stop];
    [self.audioEngine startAndReturnError:nil];
    for (id key in self.trackPlayerDict) {
        TrackPlayerModel *tpModel = (TrackPlayerModel *) self.trackPlayerDict[key];
        [tpModel.player stop];
        [tpModel.player scheduleBuffer:tpModel.buffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        [tpModel.player play];
        NSLog(@"%d", tpModel.player.isPlaying);
    }
    [self.playStopMixButton UIStop];
}

- (void)stopMix {
    [self.audioEngine stop];
    [self.playStopMixButton UIPlay];
}

- (void)startTrack:(NSURL *)trackUrl {
    [self.audioEngine stop];
    NSLog(@"Not refactored yet!");
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
    // need to reinitialize the file manager because every cell is being reloaded
    self.fileManager = nil;
    self.fileManager = [[TrackFileManager alloc] initWithPath:NSTemporaryDirectory() withSize:MAX_NUM_TRACKS];
    [self updateTrackCountLabel];
    [self.trackTableView reloadData];
    [self setUpMixer];
}

#pragma mark - Relooping

- (void)canEditLoop {
    NSAssert(!self.newLoop, @"Edit mode is not mutable in newLoop");
    [self stopMix];
    [self setUpReloop];
    self.editMode = YES;
    [self.editButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.addTrackButton.hidden = NO;
    self.shareButton.enabled = YES;
    self.loopStatusLabel.text = RELOOP_STATUS;
}

- (void)cancelEditLoop {
    NSAssert(!self.newLoop, @"Edit mode is not mutable in newLoop");
    [self stopMix];
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
        self.loop.duration = self.parentLoop.duration;
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

# pragma mark - Helpers

- (TrackPlayerModel *)getTPModelFromTrack:(Track *)track {
    NSValue *trackValue = [NSValue valueWithNonretainedObject:track];
    return [self.trackPlayerDict objectForKey:trackValue];
}

- (void) setUpMixer{
    self.trackPlayerDict = [NSMutableDictionary new];
    [self.audioEngine attachNode:self.mixerNode];
    [self.audioEngine connect:self.mixerNode to:self.audioEngine.outputNode format:nil];
    NSMutableArray *frameCountArray = [NSMutableArray new];
    NSMutableArray *audioObjectsArray = [NSMutableArray new];
    // Initialize audiofiles and urls, get min frame count of audio for looping
    for (Track *track in self.loop.tracks){
        NSData *audioData = [track.audioFilePF getData];
        NSURL *trackUrl = [self.fileManager writeToAvailableUrl:audioData];
        AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:trackUrl error:nil];
        NSNumber *frameCount = [NSNumber numberWithLongLong:audioFile.length];
        [frameCountArray addObject:frameCount];
        NSArray *audioObjects = @[audioFile, trackUrl, track];
        [audioObjectsArray addObject:audioObjects];
    }
    // get min of Framecount, to loop audio of the same length
    long long mixFrameCount = [self minOfPositiveNumArray:frameCountArray];
    
    // set up buffers and player nodes for each file
    for (NSArray *audioObjects in audioObjectsArray){
        AVAudioFile *file = audioObjects[0];
        NSURL *trackUrl = audioObjects[1];
        Track *track = audioObjects[2];
        AVAudioPCMBuffer *buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat
                                                                 frameCapacity:(UInt32)mixFrameCount];
        [file readIntoBuffer:buffer error:nil];
        AVAudioPlayerNode *playerNode = [[AVAudioPlayerNode alloc] init];
        [self.audioEngine attachNode:playerNode];
        [self.audioEngine connect:playerNode to:self.mixerNode format:file.processingFormat];
        // Set up trackPlayerDict
        TrackPlayerModel *trackPlayerModel = [[TrackPlayerModel alloc] init];
        trackPlayerModel.buffer = buffer;
        trackPlayerModel.player = playerNode;
        trackPlayerModel.url = trackUrl;
        NSValue *trackValue = [NSValue valueWithNonretainedObject:track];
        [self.trackPlayerDict setObject:trackPlayerModel forKey:trackValue];
    }
    self.mixFrameCount = [self minOfPositiveNumArray:frameCountArray];
}

- (long long)minOfPositiveNumArray:(NSArray *)array {
    long long min = -1;
    for (NSNumber *nsNum in array){
        long long num = [nsNum longLongValue];
        if (min == -1) {
            min = num;
        }
        else if (num < min){
            min = num;
        }
    }
    NSLog(@"%lld", min);
    return min;
}

@end
