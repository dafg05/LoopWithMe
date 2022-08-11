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

- (instancetype)initWithColorNameArray:(NSArray *)colorNames {
    if (self) {
        self.freeColorStack = [NSMutableArray arrayWithArray:colorNames];
        self.allColors = [NSArray arrayWithArray:colorNames];
        return self;
    } else {
        return nil;
    }
}

- (NSString *)reserveAvailableColorName {
    if ([self.freeColorStack count] == 0){
        [NSException raise:@"ReserveColorsException" format:@"No free colors left"];
        return nil;
    }
    uint32_t rnd = arc4random_uniform((uint32_t)[self.freeColorStack count]);
    NSString *randomColorName = [self.freeColorStack objectAtIndex:rnd];
    [self.freeColorStack removeObject:randomColorName];
    return randomColorName;
}

- (void)freeColorName:(NSString *)colorName {
    if ([self.freeColorStack containsObject:colorName]){
        [NSException raise:@"FreeColorException" format:@"Double free"];
    }
    if (![self.allColors containsObject:colorName]){
        [NSException raise:@"FreeColorException" format:@"Trying to free a non-allocated color name"];
    }
    [self.freeColorStack addObject:colorName];
}

@end
