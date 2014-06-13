//
//  MyTableViewControl.h
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "ImageDownloader.h"
#import "ImageFiltration.h"
#import "PendingOptions.h"

//2.
//#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"
#define kDatasourceURLString @"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"


@interface MyTableViewControl : UITableViewController<ImageDownloaderDelegate,ImageFiltrationDelegate>

@property (nonatomic, strong)NSDictionary *photos;
//5
@property (nonatomic, strong) PendingOptions *pendingOperations;

@end
