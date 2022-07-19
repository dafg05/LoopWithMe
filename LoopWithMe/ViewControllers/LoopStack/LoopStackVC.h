//
//  LoopStackVC.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import <UIKit/UIKit.h>
#import "Loop.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoopStackVC : UIViewController

@property (strong, nonatomic) Loop *loop;

-(void)reloadLoopData;

@end

NS_ASSUME_NONNULL_END
