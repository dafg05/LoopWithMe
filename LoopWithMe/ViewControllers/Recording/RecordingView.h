//
//  PrototypeView.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/25/22.
//

#import <UIKit/UIKit.h>
#import "PlayStopButton.h"
#import "CircularAnimationView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordingViewDelegate;

@interface RecordingView : UIView

@property (weak, nonatomic) IBOutlet UIButton *magicButton;
@property (weak, nonatomic) IBOutlet UILabel *magicLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet CircularAnimationView *progressAnimationView;
@property (weak, nonatomic) id<RecordingViewDelegate> delegate;

- (IBAction)didTapMagicButton:(id)sender;
- (IBAction)didTapDone:(id)sender;

- (void)initialState:(BOOL)recordingAvailable;
- (void)countInState:(int)beats :(float)bpm;
- (void)recordingState:(float)duration;
- (void)playbackState:(float)duration;

- (void)updateMagicLabelWithCountIn:(int)counter;
- (void)updateMagicLabelWithTimer:(NSTimeInterval)timeElapsed;

@end

@protocol RecordingViewDelegate
/* Takes care of playback and recording, updates UI of recordingView appropriately*/
- (void)startRecordingProcess;
- (void)stopRecordingStartPlayback;
- (void)doneRecording;

@end

NS_ASSUME_NONNULL_END
