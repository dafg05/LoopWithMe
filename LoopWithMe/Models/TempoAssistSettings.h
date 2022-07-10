//
//  TempoAssistSettings.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import <Parse/Parse.h>
#import "TimeSignature.h"

NS_ASSUME_NONNULL_BEGIN

@interface TempoAssistSettings : PFObject

@property (nonatomic) int tempo;
@property (nonatomic) int barCount;
@property (nonatomic, strong) TimeSignature *ts;
@property (nonatomic) BOOL isSilent;

@end

NS_ASSUME_NONNULL_END
