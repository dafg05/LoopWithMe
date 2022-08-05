//
//  PrototypeView.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/25/22.
//

#import "RecordingView.h"
#import "PlayStopButton.h"

static NSString *const INITIAL_STATE = @"initial";
static NSString *const COUNTIN_STATE = @"count-in";
static NSString *const RECORDING_STATE = @"recording";
static NSString *const PLAYBACK_STATE = @"playback";

static float const SECONDS_IN_MINUTE = 60;

@interface RecordingView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSString *recordingState;

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
    [self.playStopButton initWithColor:[UIColor colorNamed:@"light blue"]];
    [self initialState:NO];
}

#pragma mark - Button actions

- (IBAction)didTapDone:(id)sender {
    [self.delegate doneRecording];
}

- (IBAction)didTapMagicButton:(id)sender {
    NSString *state = [self getCurrentState];
    NSAssert(![state isEqualToString:COUNTIN_STATE], @"Magic button can't be pressed in count-in");
    if ([state isEqualToString:INITIAL_STATE]) {
        [self.delegate startRecordingProcess];
        
    } else if ([state isEqualToString:RECORDING_STATE]) {
        [self.delegate stopRecordingStartPlayback];
        
    } else if ([state isEqualToString:PLAYBACK_STATE]) {
        [self.delegate startRecordingProcess];
    }
}

- (IBAction)didTapPlayStop:(id)sender {
    NSAssert([[self getCurrentState] isEqualToString:PLAYBACK_STATE], @"Cannot play/stop outside of playback state");
    [self.delegate playbackToggle];
}

#pragma mark - States

- (void)initialState:(BOOL)recordingAvailable {
    [self setRecordingState:INITIAL_STATE];
    self.doneButton.enabled = NO;
    self.magicLabel.text = @"";
    [self.progressAnimationView deleteAnimation];
    [self.progressAnimationView setCirleLayerColor:[UIColor colorNamed:@"animation-color-initial"]];
    [self.magicButton setImage:[UIImage systemImageNamed:@"circle.fill"] forState:UIControlStateNormal];
    if (recordingAvailable) {
        self.magicButton.enabled = YES;
        [self.magicButton setTintColor:[UIColor colorNamed:@"magic-button-initial"]];
    }
    else {
        self.magicButton.enabled = NO;
        [self.magicButton setImage:[UIImage systemImageNamed:@"circle.fill"] forState:UIControlStateDisabled];
        [self.magicButton setTintColor:[UIColor colorNamed:@"animation-color-count-in"]];
    }
}

- (void)countInState:(int)beats :(float)bpm {
    [self setRecordingState:COUNTIN_STATE];
    self.doneButton.enabled = NO;
    self.magicButton.enabled = NO;
    [self.progressAnimationView deleteAnimation];
    [self.progressAnimationView setCirleLayerColor:[UIColor colorNamed:@"animation-color-count-in"]];
    [self.progressAnimationView createAnimationWithDuration:SECONDS_IN_MINUTE/bpm];
    [self.progressAnimationView startAnimation:beats - 1];
    [self.magicButton setImage:[UIImage systemImageNamed:@"square"] forState:UIControlStateNormal];
    [self.magicButton setTintColor:[UIColor colorNamed:@"animiation-color-count-in"]];
}

- (void)recordingState:(float)duration {
    [self setRecordingState:RECORDING_STATE];
    self.doneButton.enabled = NO;
    self.magicButton.enabled = YES;
    [self.progressAnimationView setCirleLayerColor:[UIColor colorNamed:@"animation-color-recording"]];
    [self.progressAnimationView createAnimationWithDuration:duration];
    [self.progressAnimationView startAnimation:0];
    [self.magicButton setImage:[UIImage systemImageNamed:@"square.fill"] forState:UIControlStateNormal];
    [self.magicButton setTintColor:[UIColor colorNamed:@"magic-button-initial"]];
}

- (void)playbackState:(float)duration {
    [self setRecordingState:PLAYBACK_STATE];
    self.playStopButton.enabled = YES;
    [self.playStopButton UIPause];
    self.doneButton.enabled = YES;
    self.magicLabel.text = @"";
    [self.progressAnimationView setCirleLayerColor:[UIColor colorNamed:@"animation-color-playback"]];
    [self.progressAnimationView createAnimationWithDuration:duration];
    // animation repeat count: infinity
    [self.progressAnimationView startAnimation:-1];
    [self.magicButton setImage:[UIImage systemImageNamed:@"circle.fill"] forState:UIControlStateNormal];
    [self.magicButton setTintColor:[UIColor colorNamed:@"magic-button-initial"]];
}

#pragma mark - Label updates

- (void)updateMagicLabelWithCountIn:(int)counter {
    if (!counter){
        self.magicLabel.text = @"";
    }
    else {
        self.magicLabel.text = [NSString stringWithFormat:@"%d", counter];
    }
}

- (void)updateMagicLabelWithTimer:(NSTimeInterval)timeElapsed {
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.allowedUnits = (NSCalendarUnitMinute | NSCalendarUnitSecond);
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    self.magicLabel.text = [formatter stringFromTimeInterval:timeElapsed];
}

#pragma mark - Helpers

- (void)setRecordingState:(NSString *)currentState {
    if (![currentState isEqualToString:PLAYBACK_STATE]){
        self.playStopButton.enabled = NO;
    }
    _recordingState = currentState;
}

- (NSString *)getCurrentState {
    return _recordingState;
}

- (void)playStopUI:(BOOL)play {
    if (play){
        [self.playStopButton UIPlay];
        [self.progressAnimationView pauseAnimation];
    } else {
        [self.playStopButton UIPause];
        [self.progressAnimationView resumeAnimation];
    }
}

@end
