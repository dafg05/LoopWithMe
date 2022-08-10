//
//  RecordingVC.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/27/22.
//

#import <UIKit/UIKit.h>
#import "Loop.h"
#import "TrackFileManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordingVC : UIViewController

@property (strong, nonatomic) Loop *loop;
@property (strong, nonatomic) TrackFileManager *fileManager;

@end

NS_ASSUME_NONNULL_END
