//
//  MyTableViewControl.m
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import "MyTableViewControl.h"

@interface MyTableViewControl ()

@end

@implementation MyTableViewControl

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lazy instantiation 
// 2 
- (NSDictionary *)photos
{
    if(!_photos) 
    {
        NSURL *dataSourceURL = [NSURL URLWithString:kDatasourceURLString];
        _photos = [NSDictionary dictionaryWithContentsOfURL:dataSourceURL];
    }
    return _photos;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationController *navControl = self.navigationController;
//    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSLog(@"change status bar style");
    return UIStatusBarStyleLightContent;
}

@end
