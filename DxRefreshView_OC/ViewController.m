//
//  ViewController.m
//  DxRefreshView_OC
//
//  Created by dx on 2016/9/13.
//  Copyright © 2016年 dx. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+Refresh.h"

@interface ViewController ()

@property (nonatomic,strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    [self.view addSubview:_scrollView];
    
    DxRefreshView *refreshHeader = [[DxRefreshView alloc] init];
    refreshHeader.color = [UIColor blueColor];
    refreshHeader.actionHandler = ^{
        NSLog(@"refreshing...");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [_scrollView.refreshHeader endRefreshing];
        });
    };
    _scrollView.refreshHeader = refreshHeader;
    [_scrollView.refreshHeader beginRefreshing];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_scrollView removeScrollObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
