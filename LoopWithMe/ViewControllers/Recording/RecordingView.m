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

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self){
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self){
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
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
    [self resetCountInLabel];
    [self.playStopButton UIPlay];
    [self recordingUnavailableUI];
}

#pragma mark - Button actions

- (IBAction)didTapDone:(id)sender {
    [self.delegate doneRecording];
}

- (IBAction)didTapPlayStop:(id)sender {
    [self.delegate playbackToggle];
}

- (IBAction)didTapRecord:(id)sender {
    [self.delegate recordToggle];
}

#pragma mark - UI

- (void)recordingAvailableUI {
    self.recordButton.enabled = YES;
    [self.recordButton setTitleColor:UIColor.systemRedColor forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor colorNamed:@"darker-system-red color"] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
}

- (void)recordingUnavailableUI {
    self.recordButton.enabled = NO;
    [self.recordButton setTitle:@"Recording Unavailable" forState:UIControlStateNormal];
    [self.recordButton setTitleColor:UIColor.systemGrayColor forState:UIControlStateDisabled];
    [self.playStopButton disable];
}

- (void)startCountInUI {
    [self resetTimerLabel];
    self.doneButton.enabled = NO;
    [self.playStopButton disable];
    self.recordButton.enabled = NO;
    [self.recordButton setTitle:@"Starting" forState:UIControlStateDisabled];
}

- (void)updateCountInLabel:(int)counter {
    self.countInLabel.text = [NSString stringWithFormat:@"%d", counter];
}

- (void)resetCountInLabel {
    self.countInLabel.text = @"";
}

- (void)currentlyRecordingUI {
    self.recordButton.enabled = YES;
    self.doneButton.enabled = NO;
    [self.playStopButton disable];
    [self.recordButton setTitle:@"Stop recording" forState:UIControlStateNormal];
}

- (void)doneRecordingUI {
    [self.recordButton setTitle:@"Re-record" forState:UIControlStateNormal];
    self.doneButton.enabled = YES;
}

- (void)playbackEnabledUI {
    self.playStopButton.enabled = YES;
    [self.playStopButton UIPlay];
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
