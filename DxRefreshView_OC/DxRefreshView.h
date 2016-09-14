//
//  DxRefreshView.h
//  DxRefreshView_OC
//
//  Created by dx on 2016/9/13.
//  Copyright © 2016年 dx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DxRefreshLayer.h"

typedef void(^ActionHandler)(void);

@interface DxRefreshView : UIView

@property(nonatomic,copy) ActionHandler  actionHandler;
@property(nonatomic,strong) UIColor  *color;

-(void)beginRefreshing;
-(void)endRefreshing;

@end
