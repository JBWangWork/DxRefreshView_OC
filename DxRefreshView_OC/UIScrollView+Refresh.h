//
//  UIScrollView+Refresh.h
//  DxRefreshView_OC
//
//  Created by dx on 2016/9/13.
//  Copyright © 2016年 dx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DxRefreshView.h"

@interface UIScrollView(Refresh)

@property (nonatomic,strong) DxRefreshView *refreshHeader;

-(void)removeScrollObserver;

@end
