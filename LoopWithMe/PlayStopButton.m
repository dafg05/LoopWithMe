//
//  PlayStopButton.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/15/22.
//

#import "PlayStopButton.h"

@implementation PlayStopButton

- (void)initWithColor:(UIColor *)color {
    [self setTintColor:color];
    [self setTitle:@"" forState:UIControlStateNormal];
}

-(void)UIPlay {
    [self setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    [self setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateHighlighted];
}

-(void)UIStop {
    [self setImage:[UIImage systemImageNamed:@"stop.fill"] forState:UIControlStateNormal];
    [self setImage:[UIImage systemImageNamed:@"stop.fill"] forState:UIControlStateHighlighted];
}

-(void)disable {
    self.enabled = NO;
    [self setImage:[UIImage systemImageNamed:@"play"] forState:UIControlStateDisabled];
}

@end
