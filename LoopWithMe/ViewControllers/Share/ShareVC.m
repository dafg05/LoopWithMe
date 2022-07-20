//
//  ShareVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "ShareVC.h"

@interface ShareVC () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLoopLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ShareVC

#define CHAR_LIMIT 140

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareLoopLabel.text = [NSString stringWithFormat:@"Share %@", self.loop.name];
    self.captionTextView.layer.cornerRadius = 5;
    self.captionTextView.delegate = self;
    [self updateCharCountLabel:0];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (IBAction)didTapPost:(id)sender {
    [self.spinner startAnimating];
    self.loop.caption = self.captionTextView.text;
    [Loop postLoop:self.loop withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"%@,", error.localizedDescription);
        }
        else{
            NSLog(@"Posted loop succesfully!");
            [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [self.spinner stopAnimating];
    }];
}

- (IBAction)didTapBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *newText = [self.captionTextView.text stringByReplacingCharactersInRange:range withString:text];
    return newText.length <= CHAR_LIMIT;
}

-(void)textViewDidChange:(UITextView *)textView{
    int charCount = (int)[self.captionTextView.text length];
    [self updateCharCountLabel:charCount];
}

-(void) updateCharCountLabel:(int) charCount{
    self.charCountLabel.text = [NSString stringWithFormat:@"%d/%d", charCount, CHAR_LIMIT];
}

-(void)dismissKeyboard{
    [self.view endEditing:YES];
}


@end
