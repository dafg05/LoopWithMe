//
//  NSTrackUrlManager.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/15/22.
//

#import "TrackFileManager.h"


@interface TrackFileManager ()

@property NSMutableArray *freeUrlStack;
@property NSArray *allUrls;

@end

@implementation TrackFileManager

-(id)initWithPath:(NSString *)path withSize:(int)size {
    self = [super init];
    if (self){
        self.freeUrlStack = [NSMutableArray new];
        for (int i = 1; i <= size; i++){
            NSURL *url = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/track%d.m4a", path, i]];
            [self.freeUrlStack addObject:url];
        }
        self.allUrls = [NSArray arrayWithArray:(NSArray *) self.freeUrlStack];
        return self;
    }
    else{
        return nil;
    }
};

-(NSURL *)writeToAvailableUrl:(NSData *)data {
    if (self.freeUrlStack == nil){
        [NSException raise:@"WritingToURLException" format:@"Uninitialized object"];
        return nil;
    }
    if ([self.freeUrlStack count] == 0){
        [NSException raise:@"WritingToURLException" format:@"No free urls to write to"];
    }
    // pop url off of freeUrlStack
    NSURL *url = [self.freeUrlStack lastObject];
    [self.freeUrlStack removeLastObject];
    NSError *writingError = nil;
    [data writeToURL:url options:NSDataWritingAtomic error:&writingError];
    if (writingError != nil){
        NSLog(@"%@", writingError.localizedDescription);
        // undo the popping
        [self.freeUrlStack addObject:url];
        return nil;
    }
    return url;
}

-(void)freeUrl:(NSURL *)url {
    if ([self.freeUrlStack containsObject:url]){
        [NSException raise:@"FreeURLException" format:@"Double free"];
    }
    if (![self.allUrls containsObject:url]){
        [NSException raise:@"FreeURLException" format:@"Trying to free a non-allocated url"];
    }
    [self.freeUrlStack addObject:url];
}



@end
