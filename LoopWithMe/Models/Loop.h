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
@property (nonatomic, strong) NSMutableArray<Track *> *tracks;
@property (nonatomic, strong) Loop *parentLoop;
@property (nonatomic, strong) NSMutableArray<Loop *> *childrenLoops;
@property (nonatomic, strong) PFUser *postAuthor;
@property (nonatomic, strong) TempoAssistSettings *taSettings;
@property float length;

+ (void)postLoop:(Loop *)loop withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
