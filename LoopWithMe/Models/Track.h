//
//  Track.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Track : PFObject<PFSubclassing>

@property (nonatomic, strong) PFFileObject *audioFilePF;
@property (nonatomic, strong) PFUser *composer;


@end

NS_ASSUME_NONNULL_END
