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

@end

@implementation ShareVC

#define CHAR_LIMIT 140

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captionTextView.layer.cornerRadius = 5;
    self.captionTextView.delegate = self;
    [self updateCharCountLabel:0];
}

- (IBAction)didTapPost:(id)sender {
    NSLog(@"Feature to be implemented!");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
