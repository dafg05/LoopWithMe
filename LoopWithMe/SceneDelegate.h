//
//  SceneDelegate.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/8/22.
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;

-(void) changeRootViewController:(UIViewController *)vc;

@end

