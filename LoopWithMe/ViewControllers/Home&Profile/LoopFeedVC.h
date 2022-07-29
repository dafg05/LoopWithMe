//
//  LoopFeedVC.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/27/22.
//

#import <UIKit/UIKit.h>
#import "Loop.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoopFeedVC : UIViewController
/* Used as a parent class for HomeVC and ProfileVC */

- (NSAttributedString *)getAuthorDescriptionString:(Loop *)loop;

@end

NS_ASSUME_NONNULL_END
