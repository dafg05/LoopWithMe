//
//  RecordingVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/27/22.
//

#import "RecordingVC.h"
#import "LoopStackVC.h"

#import "RecordingView.h"
#import "RecordingManager.h"

@interface RecordingVC () <RecordingManagerDelegate>

@property (strong, nonatomic) RecordingManager *recordingManager;
@property (weak, nonatomic) IBOutlet RecordingView *recordingView;

@end

@implementation RecordingVC

- (void)viewDidLoad {
    NSAssert(self.presentingViewController != nil, @"This view controller must be presented");
    [super viewDidLoad];
    self.recordingManager = [[RecordingManager alloc] initWithRecordingView:self.recordingView];
    if (self.loop.bpm) {
        self.recordingManager.bpm = self.loop.bpm;
    }
    self.recordingManager.delegate = self;
}

# pragma mark - RecordingManagerDelegate methods
- (void)doneRecording:(nonnull Track *)track {
    [self.loop.tracks addObject:track];
    NSLog(@"%lu", (unsigned long)[self.loop.tracks count]);
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    LoopStackVC *vc = (LoopStackVC *)navController.topViewController;
    vc.loop = self.loop;
    [vc reloadLoopTableViewData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordingAlert:(nonnull NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Recording Alert"
                                                            message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                             style:UIAlertActionStyleDefault
                                             handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
