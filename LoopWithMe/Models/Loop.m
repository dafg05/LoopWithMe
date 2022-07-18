//
//  Loop.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "Loop.h"

@implementation Loop

@dynamic loopID;
@dynamic userID;
@dynamic name;
@dynamic caption;
@dynamic tracks;
@dynamic parentLoop;
@dynamic childrenLoops;
@dynamic postAuthor;
@dynamic taSettings;

+ (nonnull NSString *)parseClassName {
    return @"Loop";
}

+ (void) postLoop: (Loop *)loop withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    [loop saveInBackgroundWithBlock:completion];
}
// TODO: posting a loop
// parameter: An already declared loop object with non-null name,
// caption, tracks, postAuthor; potentially null taSettings, parentLoop.


@end
