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
    [self.playStopButton initWithColor:[UIColor systemGray2Color]];
    self.doneButton.enabled = NO;
    [self resetTimerLabel];
}

- (IBAction)didTapDone:(id)sender {
    [self.delegate doneRecording:self];
}

- (IBAction)didTapPlayStop:(id)sender {
    [self.delegate playbackToggle:self];
}

- (IBAction)didTapRecord:(id)sender {
    [self.delegate recordToggle:self];
}

- (void)recordingAvailableUI {
    self.recordButton.enabled = YES;
    [self.recordButton setTitleColor:UIColor.systemRedColor forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor colorNamed:@"darker-system-red color"] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
}

- (void)recordingOffUI {
    self.recordButton.enabled = NO;
    [self.recordButton setTitle:@"Recording Unavailable" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:UIColor.systemGrayColor forState:UIControlStateDisabled];
}

- (void)updateTimerLabel:(NSTimeInterval)timeElapsed {
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.timerLabel.text = [formatter stringFromTimeInterval:timeElapsed];
}

- (void)resetTimerLabel {
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.timerLabel.text = [formatter stringFromTimeInterval:0];
}

@end
