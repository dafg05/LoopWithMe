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

@end

@implementation ShareVC

#define CHAR_LIMIT 140

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shareLoopLabel.text = [NSString stringWithFormat:@"Share %@", self.loop.name];
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


@end
