//
//  CircularAnimationView.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 8/1/22.
//

#import "CircularAnimationView.h"

static float const startPoint = -M_PI/2;
static float const endPoint = 3 * M_PI / 2;

@interface CircularAnimationView()

@property CAShapeLayer *circleLayer;
@property CAShapeLayer *progressLayer;

@end

@implementation CircularAnimationView

- (instancetype)init {
    self = [super init];
    if (self){
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self){
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        [self customInit];
    }
    return self;
}

- (void)customInit {
    self.backgroundColor = [UIColor clearColor];
    self.circleLayer = [[CAShapeLayer alloc] init];
    self.progressLayer = [[CAShapeLayer alloc] init];
    [self createCircularPath];
}

- (void)createCircularPath {
    UIBezierPath *circularPath = [UIBezierPath bezierPath];
    [circularPath addArcWithCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:40 startAngle:startPoint endAngle:endPoint clockwise:YES];
    
    [self.circleLayer setPath:circularPath.CGPath];
    self.circleLayer.fillColor = [[UIColor clearColor] CGColor];
    self.circleLayer.lineCap = kCALineCapRound;
    self.circleLayer.lineWidth = 20;
    self.circleLayer.strokeEnd = 1.0;
    self.circleLayer.strokeColor = [[UIColor blueColor] CGColor];
    [self.layer addSublayer:self.circleLayer];
    
    [self.progressLayer setPath:circularPath.CGPath];
    self.progressLayer.fillColor = [[UIColor clearColor] CGColor];
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.lineWidth = 10;
    self.progressLayer.strokeEnd = 0;
    self.progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
    [self.layer addSublayer:self.progressLayer];
}



@end
