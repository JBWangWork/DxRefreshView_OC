//
//  DxRefreshView.m
//  DxRefreshView_OC
//
//  Created by dx on 2016/9/13.
//  Copyright © 2016年 dx. All rights reserved.
//

#import "DxRefreshView.h"

@interface DxRefreshView()

@property(nonatomic,strong) UILabel *textLabel;
@property(nonatomic,assign) CGFloat defaultHeaderHeight;

@end


@implementation DxRefreshView

-(instancetype)init
{
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
    self = [super initWithFrame:frame];
    if(self){
        _color = [UIColor darkGrayColor];
        _defaultHeaderHeight = 48;
        [self initSubViews];
    }
    return self;
}

-(void)beginRefreshing
{
    [_refreshLayer beginRefreshing];
    [self setRefreshingStateText];
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 0, self.frame.size.width, 48);
        _textLabel.layer.opacity = 1.0;
    }];
    if(_actionHandler){
        _actionHandler();
    }
}


-(void)endRefreshing
{
    if(_refreshLayer.state != LOADING){
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -48);
        _textLabel.layer.opacity = 0.0;
    }completion:^(BOOL finished) {
        [_refreshLayer removeAllAnimations];
        [_refreshLayer reset];
        [self setPullStateText];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.transform = CGAffineTransformMakeTranslation(0, 0);
            self.frame = CGRectMake(0, 0,self.frame.size.width, 0);
        });
    }];
}


-(void)initSubViews
{
    _refreshLayer = [DxRefreshLayer layer];
    _refreshLayer.contentsScale = [UIScreen mainScreen].scale;
    _refreshLayer.color = _color;
    [self.layer addSublayer:_refreshLayer];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont systemFontOfSize:13];
    _textLabel.layer.opacity = 0.0;
    _textLabel.textColor = _color;
    [self addSubview:_textLabel];
    
    [self setPullStateText];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:_textLabel.font forKey:NSFontAttributeName];
    CGFloat textWidth = [_textLabel.text boundingRectWithSize:CGSizeMake(0, 48) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size.width;
    CGFloat left = (self.frame.size.width-26-textWidth)/2;
    _refreshLayer.frame = CGRectMake(left, 0, 24, 48);
    _textLabel.frame = CGRectMake(left+26, 0, textWidth, 48);
}

-(void)setPullStateText
{
    _textLabel.text = @"下拉刷新数据...";
}

-(void)setRefreshingStateText
{
    _textLabel.text = @"正在刷新数据...";
}

-(void)setReleaseStateText
{
    _textLabel.text = @"释放刷新数据...";
}

-(void)setColor:(UIColor *)color
{
    _refreshLayer.color = color;
    _textLabel.textColor = color;
}

-(void)startLoadingAniamtion
{
    [_refreshLayer startLoaingAnimation];
    [self setRefreshingStateText];
    if(_actionHandler){
        _actionHandler();
    }
}

- (void)DidScrollWithScrollView:(UIScrollView*)scollView
{
    if(_refreshLayer.state == LOADING){
        return;
    }
    if(scollView.contentOffset.y < 0){
        CGFloat progress = -scollView.contentOffset.y/48.0;
        if(self.frame.size.height < 48){
            self.frame = CGRectMake(0, 0, CGRectGetMaxX(scollView.bounds), -scollView.contentOffset.y);
            _textLabel.layer.opacity = progress;
        }
        if(progress > 1){
            progress = 1;
            _textLabel.layer.opacity = progress;
            self.frame = CGRectMake(0, 0, CGRectGetMaxX(scollView.bounds), 48);
            [self setReleaseStateText];
        }
        _refreshLayer.progress = progress;
    }
    
    if(scollView.contentOffset.y == 0){
        [self startLoadingAniamtion];
    }
}

#pragma mark -----observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"contentOffset"]){
        [self DidScrollWithScrollView:(UIScrollView*)object];
    }
}

@end
