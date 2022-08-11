//
//  ColorManager.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 8/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorManager : NSObject

- (instancetype)initWithColorNameArray:(NSArray *)colors;
- (NSString *)reserveAvailableColorName;
- (void)freeColorName:(NSString *)colorName;


@end

NS_ASSUME_NONNULL_END
