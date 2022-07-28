//
//  ShareVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "ShareVC.h"
#import "HomeVC.h"

@interface ShareVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *loopNameField;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLoopLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameErrorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ShareVC

#define CHAR_LIMIT 140

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isLoopReloop){
        self.shareLoopLabel.text = @"Share Reloop";
    }
    else{
        self.shareLoopLabel.text = @"Share Loop";
    }
    self.captionTextView.layer.cornerRadius = 5;
    self.captionTextView.delegate = self;
    self.nameErrorLabel.text = @"";
    [self updateCharCountLabel:0];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (IBAction)didTapPost:(id)sender {
    if ([self.loopNameField.text isEqualToString:@""] || self.loopNameField.text == nil){
        self.nameErrorLabel.text = @"Please enter a name for your new loop";
    }
    else{
        [self.spinner startAnimating];
        self.loop.caption = self.captionTextView.text;
        self.loop.name = self.loopNameField.text;
        [Loop postLoop:self.loop withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil){
                NSLog(@"%@,", error.localizedDescription);
            }
            else{
                NSLog(@"Posted loop succesfully!");
                [self setHomeFeedAsDelegate];
                [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                [self.delegate didShare];
            }
            [self.spinner stopAnimating];
        }];
    }
}

- (void)setHomeFeedAsDelegate {
    // TODO: Need to make sure that the delegateVC is a HomeVC
    UITabBarController *tabBarVC = (UITabBarController *)self.view.window.rootViewController;
    UINavigationController *navController = tabBarVC.viewControllers[0];
    HomeVC *delegateVC = (HomeVC *) navController.topViewController;
    self.delegate = delegateVC;
}

- (BOOL)textView:(UITextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [self.captionTextView.text stringByReplacingCharactersInRange:range withString:text];
    return newText.length <= CHAR_LIMIT;
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)textViewDidChange:(UITextView *)textView {
    int charCount = (int)[self.captionTextView.text length];
    [self updateCharCountLabel:charCount];
}

-(void)updateCharCountLabel:(int)charCount {
    self.charCountLabel.text = [NSString stringWithFormat:@"%d/%d", charCount, CHAR_LIMIT];
}



@end
