//
//  LoopFeedVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/27/22.
//

#import "LoopFeedVC.h"
#import "Loop.h"

@interface LoopFeedVC ()

@end

@implementation LoopFeedVC

#define NEW_LOOP_ACTION @" posted a new loop"
#define RELOOP_ACTION @" relooped "
#define RELOOP_BY @" by "

#define FONT_SIZE 12

- (NSAttributedString *)getAuthorDescriptionString:(Loop *)loop {
    // TODO: Can't test with parent loop until relooping is implemented
    NSArray *strings;
    NSArray *bolds;
    UIFont *regularFont = [UIFont systemFontOfSize:FONT_SIZE];
    NSMutableAttributedString *descriptString = [NSMutableAttributedString new];
    if (loop.parentLoop){
        strings = @[loop.postAuthor.username,
                       (NSString *)RELOOP_ACTION,
                       loop.parentLoop.name,
                       (NSString *)RELOOP_BY,
                       loop.parentLoop.postAuthor.username];
        bolds = @[loop.postAuthor.username,
                        loop.parentLoop.name,
                        loop.parentLoop.postAuthor.username];
    }
    else {
        strings = @[loop.postAuthor.username,
                       (NSString *)NEW_LOOP_ACTION];
        bolds = @[loop.postAuthor.username];
    }
    for (NSString *str in strings){
        UIFont *fontToUse;
        int strLen = (int)[str length];
        if ([bolds containsObject:str]){
            fontToUse = [self boldFontWithFont:regularFont];
        }
        else{
            fontToUse = regularFont;
        }
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString: str];
        [attString addAttribute:NSFontAttributeName
                          value:fontToUse
                          range:NSMakeRange(0, strLen)];
        [descriptString appendAttributedString:attString];
    }
    return descriptString;
}

- (UIFont *)boldFontWithFont:(UIFont *)font {
    UIFontDescriptor * fontD = [font.fontDescriptor
                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

@end
