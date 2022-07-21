//
//  ProfileVC.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileVC : UIViewController

@property (strong, nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
