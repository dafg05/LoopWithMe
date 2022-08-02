//
//  CircularAnimationView.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 8/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircularAnimationView : UIView

- (void)createAnimationWithDuration:(float)duration;
- (void)startAnimation;
- (void)resetAnimation;
- (void)deleteAnimation;

@end

NS_ASSUME_NONNULL_END
