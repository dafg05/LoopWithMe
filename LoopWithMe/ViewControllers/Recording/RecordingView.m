//
//  PrototypeView.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/25/22.
//

#import "RecordingView.h"
#import "PlayStopButton.h"

@interface RecordingView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation RecordingView

-(instancetype)init {
    self = [super init];
    if (self){
        [self customInit];
    }
    return self;
}

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
    [[NSBundle mainBundle] loadNibNamed:@"RecordingView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    self.contentView.layer.cornerRadius = 10;
}

- (void)recorderSetup {
    
}

- (IBAction)didTapDone:(id)sender {
    self.hidden = YES;
}

- (IBAction)didTapPlayStop:(id)sender {
}

- (IBAction)didTapRecord:(id)sender {
}

- (void)recordingOnUI {
}

- (void)recordingOffUI {
}

- (void)updateTimerLabel {
}

@end
