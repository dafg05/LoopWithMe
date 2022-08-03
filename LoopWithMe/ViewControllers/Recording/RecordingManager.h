//
//  Recorder.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/26/22.
//

#import <Foundation/Foundation.h>
#import "RecordingView.h"
#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordingManagerDelegate

- (void)recordingAlert:(NSString *)message;
- (void)doneRecording:(Track *)track;

@end

@interface RecordingManager : NSObject  <RecordingViewDelegate>

@property int bpm;
@property (weak, nonatomic) id<RecordingManagerDelegate> delegate;

- (instancetype)initWithRecordingView:(RecordingView *)recordingView;
- (BOOL)recording;
@end

NS_ASSUME_NONNULL_END
