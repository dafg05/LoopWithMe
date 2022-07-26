//
//  Recorder.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/26/22.
//

#import <Foundation/Foundation.h>
#import "RecordingView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordingManagerDelegate

- (void)recordingAlert:(NSString *)message;

@end

@interface RecordingManager : NSObject  <RecordingViewDelegate>

@property (weak, nonatomic) id<RecordingManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END