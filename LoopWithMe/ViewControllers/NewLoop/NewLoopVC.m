//
//  NewLoopVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import "NewLoopVC.h"
#import "Loop.h"
#import "RecordingVC.h"
#import "LoopStackVC.h"
#import "Parse/Parse.h"

#import "RecordingView.h"

@interface NewLoopVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loopNameField;
@property (weak, nonatomic) IBOutlet UILabel *nameErrorLabel;
@property (weak, nonatomic) IBOutlet RecordingView *recordingView;

@end

@implementation NewLoopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameErrorLabel.text = @"";
    self.loopNameField.delegate = self;
}

- (IBAction)didTapStartRecording:(id)sender {
    if ([self.loopNameField.text isEqualToString:@""] || self.loopNameField.text == nil){
        self.nameErrorLabel.text = @"Please enter a name for your new loop";
    }
    else{
        self.loop = [Loop new];
        self.loop.name = self.loopNameField.text;
        self.loop.postAuthor = [PFUser currentUser];
        [self performSegueWithIdentifier:@"NewLoopRecordingSegue" sender:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"NewLoopRecordingSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        RecordingVC *vc = (RecordingVC *)navController.topViewController;
        vc.loop = self.loop;
    }
    else if ([[segue identifier] isEqualToString:@"RecordingDoneSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        LoopStackVC *vc = (LoopStackVC *)navController.topViewController;
        vc.loop = self.loop;
        vc.readOnly = NO;
    }
}
@end
