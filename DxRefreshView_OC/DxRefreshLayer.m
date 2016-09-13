//
//  DxRefreshLayer.m
//  DxRefreshView_OC
//
//  Created by dx on 2016/9/13.
//  Copyright © 2016 dx. All rights reserved.
//

#import "DxRefreshLayer.h"

const static CGFloat MAX_ANGLE = 150.0f;
const static CGFloat ARROW_LENGTH = 3.0f;

@interface DxRefreshLayer()

@property(nonatomic,assign) CGFloat lineLength;
@property(nonatomic,assign) CGFloat left,top,right,moveDistance;
@property(nonatomic,assign) CGFloat centerX,centerY;
@property(nonatomic,assign) CGFloat angle;
@property(nonatomic,assign) CGFloat pullDownAngle;

@end

@implementation DxRefreshLayer

-(instancetype)init
{
    self = [super init];
    if(self){
        _lineWidth = 1.3f;
        _arcRadius = 6.0f;
        _pullDownAngle = 0;
    }
    return self;
}

+(BOOL)needsDisplayForKey:(NSString *)key {
    if ([@"progress" isEqualToString:key] || [@"color" isEqualToString:key] ||[@"lineWidth" isEqualToString:key] || [@"arcRadius" isEqualToString:key]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextSetLineWidth(ctx, _lineWidth);
    
    if(_state == PULL_TO_TRANSITION){
        [self drawPullDownArrowWithContext:ctx];
    }
    
    if(_state == PULL_TO_ARC){
        [self drawLineToArcWithContext:ctx];
    }
    
    if(_state == PULL_TO_ROTATE || _state == RELEASED || _state == LOADING){
        [self drawReleaseStateWithContext:ctx];
    }
    CGContextDrawPath(ctx,kCGPathStroke);
    CGContextRestoreGState(ctx);
}


#pragma mark ----- public

-(void)startLoaingAnimation
{
    if(_state == PULL_TO_ROTATE){
        _state = RELEASED;
    }
    
    if(_state != RELEASED || _state == LOADING){
        return;
    }
    [self playRotateAnimation];
    _state = LOADING;
}

-(void)beginRefreshing
{
    [self initData];
    _state = LOADING;
    [self setNeedsDisplay];
    [self playRotateAnimation];
}

-(void)reset
{
    self.contentOffsetY = 0;
    _angle = 0;
    _state = PULL_TO_TRANSITION;
    [self setNeedsDisplay];
}

#pragma mark ----- private
-(void)initData
{
    if(_lineLength == 0){
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        _centerX = self.bounds.size.width/2;
        _centerY = self.bounds.size.height/2;
        
        _lineLength = _arcRadius*2;
        
        _left = (width - _lineLength)/2.0;
        _top = (height - _lineLength)/2.0;
        _right = _left + _lineLength;
        _moveDistance = _lineLength/2+_top+2;
    }
}

-(void)setContentOffsetY:(CGFloat)contentOffsetY
{
    _contentOffsetY = contentOffsetY;
    CGFloat progress = _contentOffsetY/48.0;
    if(_state == PULL_TO_TRANSITION && _contentOffsetY > 0.5){
        _state = PULL_TO_ARC;
    }
    
    if(_state == PULL_TO_ARC && progress <= 0.5){
        _state = PULL_TO_TRANSITION;
    }
    
    if(_state == PULL_TO_ARC){
        _angle = (progress-0.5)*2*MAX_ANGLE;
        if(_angle >= MAX_ANGLE){
            _state = PULL_TO_ROTATE;
        }
    }
    
    if(_state == PULL_TO_ROTATE){
        if(progress <= 1){
            return;
        }
        _pullDownAngle = (progress-1.0)*180;
    }
    
    [self setNeedsDisplay];
}

-(void)playRotateAnimation
{
    CABasicAnimation *rotateAnimation = [[CABasicAnimation alloc] init];
    rotateAnimation.keyPath = @"transform.rotation.z";
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.duration = 0.8;
    rotateAnimation.repeatCount = CGFLOAT_MAX;
    rotateAnimation.fillMode = kCAFillModeRemoved;
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    [self addAnimation:rotateAnimation forKey:nil];
}


-(void)drawPullDownArrowWithContext:(CGContextRef)ctx
{
    [self initData];
    
    CGFloat leftLineY = self.bounds.size.height+2.0f-_moveDistance*_contentOffsetY/48.0*2;
    CGFloat rightLineY = -_lineLength-2+_moveDistance*_contentOffsetY/48.0*2;
    
    CGContextMoveToPoint(ctx, _left, leftLineY);
    CGContextAddLineToPoint(ctx, _left, leftLineY+_lineLength);
    
    CGContextMoveToPoint(ctx, _right, rightLineY);
    CGContextAddLineToPoint(ctx, _right, rightLineY+_lineLength);
    
    CGContextMoveToPoint(ctx, _left-2, leftLineY+2);
    CGContextAddLineToPoint(ctx,_left,leftLineY);
    
    CGContextMoveToPoint(ctx, _right+2, rightLineY+_lineLength-2);
    CGContextAddLineToPoint(ctx,_right,rightLineY+_lineLength);
    
}

-(void)drawLineToArcWithContext:(CGContextRef)ctx
{
    CGFloat radian = M_PI/180.0*(180+_angle);
    CGFloat rx = cos(radian)*_arcRadius;
    CGFloat ry = sin(radian)*_arcRadius;
    
    CGFloat lx = _centerX + rx - ARROW_LENGTH*sin((_angle+30)/180.0 * M_PI);
    CGFloat ty = _centerY + ry + ARROW_LENGTH*cos((_angle+30)/180.0 * M_PI);
    
    CGFloat radian2 = M_PI/180.0*_angle;
    CGFloat rx2 = cos(radian2)*_arcRadius;
    CGFloat ry2 = sin(radian2)*_arcRadius;
    
    CGFloat ra2x = _centerX + rx2 + ARROW_LENGTH*cos((_angle-60)/180.0 * M_PI);
    CGFloat ra2y = _centerY + ry2 + ARROW_LENGTH*sin((_angle-60)/180.0 * M_PI);
    
    //left line
    CGFloat bottom = self.bounds.size.height-_top+_arcRadius;
    CGContextMoveToPoint(ctx,_left,bottom-(_angle/MAX_ANGLE*_lineLength));
    CGContextAddLineToPoint(ctx,_left,bottom-_lineLength);
    
    //right line
    CGContextMoveToPoint(ctx,_right,_top-_arcRadius+(_angle/MAX_ANGLE*_lineLength));
    CGContextAddLineToPoint(ctx,_right,_top-_arcRadius+_lineLength);
    
    //lef arrow
    CGContextMoveToPoint(ctx,lx,ty);
    CGContextAddLineToPoint(ctx,_centerX + rx,_centerY + ry);
    
    //right arrow
    CGContextMoveToPoint(ctx,ra2x,ra2y);
    CGContextAddLineToPoint(ctx,_centerX + rx2,_centerY+ry2);
    
    //bottom arc
    CGContextMoveToPoint(ctx,_centerX+_arcRadius,_centerY);
    CGContextAddArc(ctx,_centerX, _centerY, _arcRadius, 0, _angle/180.0*M_PI, false);
    //top arc
    CGContextMoveToPoint(ctx,_left,_centerY);
    CGContextAddArc(ctx,_centerX, _centerY, _arcRadius,M_PI,_angle/180.0*M_PI-M_PI,false);
}

-(void)drawReleaseStateWithContext:(CGContextRef)ctx
{
    
    CGFloat startRadian = M_PI+[self angleToRadian:_pullDownAngle];
    CGFloat endRadian = MAX_ANGLE/180.0*M_PI-M_PI+[self angleToRadian:_pullDownAngle];
    
    CGFloat startRadian2 = [self angleToRadian:_pullDownAngle];
    CGFloat endRadian2 = MAX_ANGLE/180.0*M_PI+startRadian2;
    
    CGFloat rax = [self getRadianX:endRadian] - ARROW_LENGTH*sin([self angleToRadian:MAX_ANGLE+_pullDownAngle+30]);
    CGFloat ray = [self getRadianY:endRadian] + ARROW_LENGTH*cos([self angleToRadian:MAX_ANGLE+_pullDownAngle+30]);
    
    
    CGFloat ra2x = [self getRadianX:endRadian2] + ARROW_LENGTH*cos([self angleToRadian:MAX_ANGLE+_pullDownAngle-60]);
    CGFloat ra2y = [self getRadianY:endRadian2] + ARROW_LENGTH*sin([self angleToRadian:MAX_ANGLE+_pullDownAngle-60]);
    
    CGContextMoveToPoint(ctx,rax,ray);
    CGContextAddLineToPoint(ctx,[self getRadianX:endRadian],[self getRadianY:endRadian]);
    
    CGContextMoveToPoint(ctx,ra2x,ra2y);
    CGContextAddLineToPoint(ctx,[self getRadianX:endRadian2],[self getRadianY:endRadian2]);
    
    CGContextMoveToPoint(ctx,[self getRadianX:startRadian],[self getRadianY:startRadian]);
    CGContextAddArc(ctx,_centerX,_centerY,_arcRadius,startRadian,endRadian,false);
    
    CGContextMoveToPoint(ctx,[self getRadianX:startRadian2],[self getRadianY:startRadian2]);
    CGContextAddArc(ctx,_centerX,_centerY,_arcRadius, startRadian2, endRadian2,false);
}

-(CGFloat)angleToRadian:(CGFloat)angle
{
    return angle / 180.0 * M_PI;
}

-(CGFloat)getRadianX:(CGFloat)radian
{
    return _centerX + cos(radian)*_arcRadius;
}

-(CGFloat)getRadianY:(CGFloat)radian
{
    return _centerY + sin(radian)*_arcRadius;
}


@end
