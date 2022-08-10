//
//  ColorManager.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 8/10/22.
//

#import "ColorManager.h"


@interface ColorManager ()

@property NSMutableArray *freeColorStack;
@property NSArray *allColors;

@end

@implementation ColorManager

- (instancetype)initWithColorNameArray:(NSArray *)colors {
    if (self) {
    }
    return self;
}

- (NSString *)reserveAvailableColor {
    return @"";
}

- (void)freeColor:(NSString *)colorName {
    
}

@end
