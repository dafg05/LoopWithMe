//
//  NSTrackUrlManager.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/15/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TrackFileManager : NSObject


- (id)initWithPath:(NSString *)path withSize:(int)size;
- (NSURL *)writeToAvailableUrl:(NSData *)data;
- (void)freeUrl:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
