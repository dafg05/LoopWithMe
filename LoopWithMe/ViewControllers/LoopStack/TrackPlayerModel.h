//
//  TrackPlayerModel.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 8/8/22.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFAudio.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackPlayerModel : NSObject

@property AVAudioPlayerNode *player;
@property AVAudioPCMBuffer *buffer;
@property NSURL *url;

@end

NS_ASSUME_NONNULL_END
