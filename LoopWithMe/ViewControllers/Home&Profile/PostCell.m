//
//  FeedCell.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/20/22.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.profileImageView.layer.cornerRadius = 5;
    [self.profileImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)didTapUserProfile:(UITapGestureRecognizer *)sender {
    [self.delegate postCell:self didTap:self.loop.postAuthor];
}

@end
