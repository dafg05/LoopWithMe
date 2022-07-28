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

@interface NewLoopVC () <RecordingManagerDelegate>

@property (weak, nonatomic) IBOutlet RecordingView *recordingView;
@property (strong, nonatomic) RecordingManager *recordingManager;

@end

@implementation NewLoopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recordingManager = [[RecordingManager alloc] initWithRecordingView:self.recordingView];
    self.recordingManager.delegate = self;
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
    self.loop.postAuthor = [PFUser currentUser];
    self.loop.tracks = [NSMutableArray new];
    [self.loop.tracks addObject:track];
    [self performSegueWithIdentifier:@"RecordingDoneSegue" sender:nil];
    
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
