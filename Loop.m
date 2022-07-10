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

// TODO: define class method to convert array of AVAudioFiles to PFFileObjects
// Note that the view controller will play audio with AVAudioFiles,
// but PFFileObjects are needed to connect with the database

// TODO: posting a loop
// parameter: An already declared loop object with non-null name,
// caption, tracks, postAuthor; potentially null taSettings, parentLoop.


@end
