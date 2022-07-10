//
//  TempoAssistSettings.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "TempoAssistSettings.h"

@implementation TempoAssistSettings

@dynamic tempo;
@dynamic barCount;
@dynamic ts;
@dynamic isSilent;

+ (nonnull NSString *)parseClassName {
    return @"TempoAssistSettings";
}

@end
