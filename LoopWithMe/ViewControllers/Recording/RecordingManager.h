//
//  Recorder.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/26/22.
//

#import <Foundation/Foundation.h>
#import "RecordingView.h"
#import "Track.h"
#import "TrackFileManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordingManagerDelegate

- (void)recordingAlert:(NSString *)message;
- (void)doneRecording:(Track *)track;

@end

@interface RecordingManager : NSObject  <RecordingViewDelegate>

@property int bpm;
@property float recordingDuration;
@property BOOL newLoop;
@property (strong, nonatomic) TrackFileManager *fileManager;
@property (weak, nonatomic) id<RecordingManagerDelegate> delegate;

- (instancetype)initWithRecordingView:(RecordingView *)recordingView withTrackFileManager:(TrackFileManager * _Nullable)fileManager isNewLoop:(BOOL)newLoop;
- (BOOL)recording;
- (void)setViewToInitialState;

@end

NS_ASSUME_NONNULL_END
