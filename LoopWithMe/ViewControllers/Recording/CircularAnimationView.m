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
@property CABasicAnimation *progressAnimation;

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
    float radius = (0.9 * self.frame.size.height)/2.0;
    UIBezierPath *circularPath = [UIBezierPath bezierPath];
    [circularPath addArcWithCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:radius startAngle:startPoint endAngle:endPoint clockwise:YES];
    
    [self.circleLayer setPath:circularPath.CGPath];
    self.circleLayer.fillColor = [[UIColor clearColor] CGColor];
    self.circleLayer.lineCap = kCALineCapRound;
    self.circleLayer.lineWidth = 0.1 * self.frame.size.height;
    self.circleLayer.strokeEnd = 1.0;
    self.circleLayer.strokeColor = [[UIColor colorNamed:@"animation-color"] CGColor];
    [self.layer addSublayer:self.circleLayer];
    
    [self.progressLayer setPath:circularPath.CGPath];
    self.progressLayer.fillColor = [[UIColor clearColor] CGColor];
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.lineWidth = 0.075 * self.frame.size.height;
    self.progressLayer.strokeEnd = 0;
    self.progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
    [self.layer addSublayer:self.progressLayer];
}

- (void)createAnimationWithDuration:(float)duration {
    self.progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    self.progressAnimation.duration = duration;
    self.progressAnimation.toValue = @1.0;
    self.progressAnimation.fillMode = kCAFillModeForwards;
    [self.progressAnimation setRemovedOnCompletion:NO];
}

- (void)startAnimation {
    if (!self.progressAnimation) {
        [NSException raise:@"AnimationException" format:@"No animation has been created"];
    }
    [self.progressLayer addAnimation:self.progressAnimation forKey:@"progressAnim"];
}

- (void)resetAnimation {
    [self.progressLayer removeAllAnimations];
}

- (void)deleteAnimation {
    [self.progressLayer removeAllAnimations];
    self.progressAnimation = nil;
}

- (void)setCirleLayerColor:(UIColor *)color {
    self.circleLayer.strokeColor = [color CGColor];
}

@end
