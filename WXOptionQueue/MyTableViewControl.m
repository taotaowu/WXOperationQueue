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


- (PendingOptions *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOptions alloc] init];
    }
    return _pendingOperations;
}

#pragma mark view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.tableView.rowHeight = 80.0;
}

- (void)viewDidUnload
{
    [self setPhotos:nil];
    [super viewDidUnload];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    NSInteger numberOfData = self.photos.count;
    return  numberOfData;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 8
    NSString *rowKey = [[self.photos allKeys] objectAtIndex:indexPath.row];
    NSURL *imageURL = [NSURL URLWithString:[self.photos objectForKey:rowKey]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = nil;
    
    // 9
    if (imageData) {
        UIImage *unfiltered_image = [UIImage imageWithData:imageData];
        image = [self applySepiaFilterToImage:unfiltered_image];
    }
    
    cell.textLabel.text = rowKey;
    cell.imageView.image = image;
    
    return cell;
}

//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *kCellIdentifier = @"cellIdentifier";
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
//    if (!cell)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//    //8
//    NSString *rowKey = [[self.photos allKeys] objectAtIndex:indexPath.row];
//    NSURL *imageUrl = [NSURL URLWithString:[self.photos objectForKey:rowKey]];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
//    UIImage *image = nil;
//    
//    //9
//    if(imageData)
//    {
//        UIImage *unfilteredImage = [UIImage imageWithData:imageData];
//        image = [self applyFilterToImage:unfilteredImage];
//    }
//    cell.textLabel.text = rowKey;
//    cell.imageView.image = image;
//    
//    return cell;
//}
#pragma mark - image filteration
//10
- (UIImage*) applySepiaFilterToImage:(UIImage*)unfilterImage
{
    CIImage *inputImage = [CIImage imageWithData:UIImagePNGRepresentation(unfilterImage)];
    UIImage *sepiaImage = nil;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,inputImage,@"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef outputImageRef = [context createCGImage:outputImage fromRect:[outputImage extent]];
    sepiaImage = [UIImage imageWithCGImage:outputImageRef];
    CGImageRelease(outputImageRef);
    return sepiaImage;
    
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSLog(@"change status bar style");
    return UIStatusBarStyleLightContent;
}

@end
