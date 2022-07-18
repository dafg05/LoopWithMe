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

@interface LoopStackVC () <UITableViewDataSource, LoopTrackCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *trackTableView;
@property (weak, nonatomic) IBOutlet PlayStopButton *playMixButton;
@property (weak, nonatomic) IBOutlet PlayStopButton *stopMixButton;
@property AVAudioEngine *audioEngine;
@property AVAudioMixerNode *mixerNode;
@property BOOL mixPlayedLast;
@property (strong, nonatomic) TrackFileManager *fileManager;
@property (weak, nonatomic) IBOutlet UILabel *trackCountLabel;

@end

@implementation LoopStackVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define MAX_NUM_TRACKS 8

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)didTapBack:(id)sender {
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LoopTrackCell *cell = [self.trackTableView dequeueReusableCellWithIdentifier:
                           @"LoopTrackCell"];
    cell.track = self.loop.tracks[indexPath.row];
    cell.delegate = self;
    [cell.playTrackButton initWithColor:[UIColor blackColor]];
    [cell.playTrackButton UIPlay];
    cell.trackNumberLabel.text = @"Track";
    NSData *audioData = [cell.track.audioFilePF getData];
    cell.trackAudioUrl = [self.fileManager writeToAvailableUrl:audioData];
    return cell;
}

- (void) updateTrackCountLabel{
    self.trackCountLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)[self.loop.tracks count], MAX_NUM_TRACKS];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loop.tracks count];
}

-(void) startMix{
    [self.audioEngine stop];
    [self.audioEngine attachNode:self.mixerNode];
    [self.audioEngine connect:self.mixerNode to:self.audioEngine.outputNode format:nil];

    NSError *startError = nil;
    [self.audioEngine startAndReturnError:&startError];

    if (startError != nil){
        NSLog(@"%@", startError.localizedDescription);
    }else{
        for (LoopTrackCell *cell in self.trackTableView.visibleCells){
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

- (void) startTrack:(NSURL *) trackUrl{
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

- (IBAction)didTapPlayMix:(id)sender{
    [self startMix];
}

- (IBAction)didTapStopMix:(id)sender{
    [self.audioEngine stop];
}

- (void)playTrack:(NSURL *) trackUrl{
    [self startTrack:trackUrl];
}

- (IBAction)didTapAddTrack:(id)sender {
    if ([self.loop.tracks count] < MAX_NUM_TRACKS){
        [self.audioEngine stop];
        UINavigationController *navController = (UINavigationController *) [self presentingViewController];
        RecordingVC *vc = (RecordingVC *) navController.topViewController;
        vc.loop = self.loop;
        [vc setUpRecording];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (IBAction)didTapShare:(id)sender {
    [self performSegueWithIdentifier:@"ShareSegue" sender:nil];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    ShareVC *vc = (ShareVC *)navController.topViewController;
    vc.loop = self.loop;
}

@end
