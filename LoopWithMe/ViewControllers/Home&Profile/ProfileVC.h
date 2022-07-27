//
//  ProfileVC.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "LoopFeedVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileVC : LoopFeedVC

@property (strong, nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
