//
//  NewLoopVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import "NewLoopVC.h"
#import "Loop.h"
#import "RecordingVC.h"

@interface NewLoopVC ()

@property (weak, nonatomic) IBOutlet UITextField *loopNameField;
@property (strong, nonatomic) Loop *loop;
@property (weak, nonatomic) IBOutlet UILabel *nameErrorLabel;


@end

@implementation NewLoopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameErrorLabel.text = @"";
}

- (IBAction)didTapStartRecording:(id)sender {
    if ([self.loopNameField.text isEqualToString:@""] || self.loopNameField.text == nil){
        self.nameErrorLabel.text = @"Please enter a name for your new loop";
    }
    else{
        self.loop = [Loop new];
        self.loop.name = self.loopNameField.text;
        [self performSegueWithIdentifier:@"NewLoopRecordingSegue" sender:nil];
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    RecordingVC *vc = (RecordingVC *)navController.topViewController;
    vc.loop = self.loop;
}


@end
