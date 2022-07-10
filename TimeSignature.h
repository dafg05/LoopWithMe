//
//  TimeSignature.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeSignature : PFObject

@property (nonatomic) int numerator;
@property (nonatomic) int denominator;

@end

NS_ASSUME_NONNULL_END
