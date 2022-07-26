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
@property (weak, nonatomic) id<RecordingViewDelegate> delegate;

- (void)recorderSetup;

- (IBAction)didTapRecord:(id)sender;
- (IBAction)didTapPlayStop:(id)sender;
- (IBAction)didTapDone:(id)sender;

- (void)recordingOnUI;
- (void)recordingOffUI;
- (void)updateTimerLabel;

@end

@protocol RecordingViewDelegate
/* Takes care of playback, updates UI of rview appropriately*/

-(void)setUpRecording:(RecordingView *)rview;
-(void)recordToggle:(RecordingView *)rview;
-(void)playbackToggle:(RecordingView *)rview;
-(void)doneRecording:(RecordingView *)rview;

@end

NS_ASSUME_NONNULL_END
