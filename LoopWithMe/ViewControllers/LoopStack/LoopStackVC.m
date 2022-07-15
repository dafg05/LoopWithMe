//
//  LoopStackVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "LoopStackVC.h"
#import "LoopTrackCell.h"
#import "AVFoundation/AVFAudio.h"

@interface LoopStackVC () <UITableViewDataSource, LoopTrackCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *trackTableView;
@property AVAudioEngine *audioEngine;
@property AVAudioMixerNode *mixerNode;
@property (strong, nonatomic) NSMutableDictionary* trackUrlDict;

@end

@implementation LoopStackVC

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trackTableView.dataSource = self;
    self.loopNameLabel.text = self.loop.name;
    self.trackUrlDict = [NSMutableDictionary new];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.mixerNode = [[AVAudioMixerNode alloc] init];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LoopTrackCell *cell = [self.trackTableView dequeueReusableCellWithIdentifier:
                           @"LoopTrackCell"];
    cell.track = self.loop.tracks[indexPath.row];
    cell.delegate = self;
    int trackNumber = (int) indexPath.row + 1;
    
    // TODO: figure out a better naming scheme for files
    cell.trackNumberLabel.text = [NSString stringWithFormat:@"Track %d", trackNumber];
    NSData *audioData = [cell.track.audioFilePF getData];
    NSURL *cellUrl = [self getRecordingFileUrl: trackNumber];
    NSError *writingError = nil;
    [audioData writeToURL:cellUrl options:NSDataWritingAtomic error:&writingError];
    if (writingError != nil) NSLog(@"%@", writingError.localizedDescription);
    else {
        NSValue *trackKey = [NSValue valueWithNonretainedObject:cell.track];
        [self.trackUrlDict setObject:cellUrl forKey:trackKey];
        NSLog(@"At least this is working");
    }
    return cell;
}

- (NSURL *)getRecordingFileUrl:(int) trackNumber{
    return [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/track%d.m4a", DOCUMENTS_FOLDER, trackNumber]];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loop.tracks count];
}


- (IBAction)didTapBack:(id)sender {
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
        for (id key in self.trackUrlDict){
            NSURL *fileUrl = [self.trackUrlDict objectForKey:key];
            AVAudioPlayerNode *playerNode = [[AVAudioPlayerNode alloc] init];
            [self.audioEngine attachNode:playerNode];
            NSError *readingError = NULL;
            AVAudioFile *file = [[AVAudioFile alloc] initForReading:fileUrl.absoluteURL error:&readingError];
            [self.audioEngine connect:playerNode to:self.mixerNode format:file.processingFormat];
            [playerNode scheduleFile:file atTime:nil completionHandler:nil];
            [playerNode play];
        }
    }
}

- (void) startTrack:(NSURL *) fileUrl{
    [self.audioEngine stop];
    NSError *creationError = NULL;
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:fileUrl.absoluteURL error:&creationError];
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

- (IBAction)didTapPlayStopMix:(id)sender{
    // TODO: implement start stop functionality
    [self startMix];
//    if ([self.audioEngine isRunning]){
//        [self.audioEngine stop];
//    }
//    else{
//        [self startMix];
//    }
}

- (void)playStopTrack:(Track *) track{
    NSURL *fileUrl = [self.trackUrlDict objectForKey:[NSValue valueWithNonretainedObject:track]];
    [self startTrack:fileUrl];

//    if ([self.audioEngine isRunning]){
//        [self.audioEngine stop];
//    }
//    else{
//        NSURL *fileUrl = [self.trackUrlDict objectForKey:[NSValue valueWithNonretainedObject:track]];
//        [self startTrack:fileUrl];
//    }
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
