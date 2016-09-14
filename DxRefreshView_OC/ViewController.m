//
//  ViewController.m
//  DxRefreshView_OC
//
//  Created by dx on 2016/9/13.
//  Copyright © 2016年 dx. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+Refresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = [NSMutableArray arrayWithObjects:@"1",@"2",@"3", nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    DxRefreshView *refreshHeader = [[DxRefreshView alloc] init];
    refreshHeader.color = [UIColor blueColor];
    refreshHeader.actionHandler = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [_dataSource addObject:[NSString stringWithFormat:@"%d",(int)_dataSource.count+1]];
            [_tableView reloadData];
            [_tableView.refreshHeader endRefreshing];
        });
    };
    _tableView.refreshHeader = refreshHeader;
    [_tableView.refreshHeader beginRefreshing];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_tableView removeScrollObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

@end
