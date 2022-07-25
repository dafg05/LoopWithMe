//
//  PrototypeView.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/25/22.
//

#import "PrototypeView.h"

@interface PrototypeView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation PrototypeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self){
        [self customInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        [self customInit];
    }
    return self;
}

-(void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"PrototypeView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

@end
