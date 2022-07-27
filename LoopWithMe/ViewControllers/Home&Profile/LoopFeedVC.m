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

- (NSAttributedString *)getAuthorDescriptionString:(Loop *)loop {
    NSString *postAuthorUsername = loop.postAuthor.username;
    NSString *descriptStr = [NSString stringWithFormat:@"%@ posted a new loop:", loop.postAuthor.username];
    int descriptStrLen = (int) [descriptStr length];
    int usernameStrLen = (int) [postAuthorUsername length];
    int actionStrLen = descriptStrLen - usernameStrLen;
    NSMutableAttributedString *attString;
    UIFont *regularFont = [UIFont systemFontOfSize:14];
    if (loop.parentLoop){
        // TODO: Implement
    }
    else {
        attString = [[NSMutableAttributedString alloc]
                     initWithString: descriptStr];
        [attString addAttribute: NSFontAttributeName
                          value:[self boldFontWithFont:regularFont]
                          range: NSMakeRange(0,usernameStrLen)];
        [attString addAttribute: NSFontAttributeName
                          value:regularFont
                          range: NSMakeRange(usernameStrLen,actionStrLen)];
    }
    return attString;
}

- (UIFont *)boldFontWithFont:(UIFont *)font {
    UIFontDescriptor * fontD = [font.fontDescriptor
                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

@end
