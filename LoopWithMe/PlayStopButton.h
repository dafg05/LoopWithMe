//
//  PlayStopButton.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/15/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayStopButton : UIButton

- (void) initializeDisabled;

- (void) UIStop;

- (void) UIPlay;

- (void) disable;

@end

NS_ASSUME_NONNULL_END
