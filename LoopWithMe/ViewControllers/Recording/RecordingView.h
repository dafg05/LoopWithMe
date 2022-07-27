//
//  PrototypeView.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/25/22.
//

#import <UIKit/UIKit.h>
#import "PlayStopButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordingViewDelegate;

@interface RecordingView : UIView

@property (weak, nonatomic) IBOutlet PlayStopButton *playStopButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) id<RecordingViewDelegate> delegate;

- (IBAction)didTapRecord:(id)sender;
- (IBAction)didTapPlayStop:(id)sender;
- (IBAction)didTapDone:(id)sender;

- (void)recordingAvailableUI;
- (void)recordingUnavailableUI;
- (void)currentlyRecordingUI;
- (void)doneRecordingUI;
- (void)playbackEnabledUI;
- (void)updateTimerLabel:(NSTimeInterval)timeElapsed;
- (void)resetTimerLabel;

@end

@protocol RecordingViewDelegate
/* Takes care of playback and recording, updates UI of recordingView appropriately*/
- (void)recordToggle;
- (void)playbackToggle;
- (void)doneRecording;

@end

NS_ASSUME_NONNULL_END
