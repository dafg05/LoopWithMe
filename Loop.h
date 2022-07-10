//
//  Loop.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import <Parse/Parse.h>
#import "TempoAssistSettings.h"
#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

@interface Loop : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *loopID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray<Track *> *tracks;
@property (nonatomic, strong) Loop *parentLoop;
@property (nonatomic, strong) NSArray<Loop *> *childrenLoops;
@property (nonatomic, strong) PFUser *postAuthor;
@property (nonatomic, strong) TempoAssistSettings *taSettings;


// TODO: define class method to convert array of AVAudioFiles to PFFileObjects
// Note that the view controller will play audio with AVAudioFiles,
// but PFFileObjects are needed to connect with the database

// TODO: posting a loop
// parameter: An already declared loop object with non-null name,
// caption, tracks, postAuthor; potentially null taSettings, parentLoop.




@end

NS_ASSUME_NONNULL_END
