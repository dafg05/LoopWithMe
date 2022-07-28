//
//  ShareVC.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import <UIKit/UIKit.h>
#import "Loop.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShareVCDelegate

-(void)didShare;

@end

@interface ShareVC : UIViewController

@property (strong, nonatomic) Loop *loop;
@property (weak, nonatomic) id<ShareVCDelegate> delegate;
@property BOOL isLoopReloop;

@end

NS_ASSUME_NONNULL_END
