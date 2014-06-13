//
//  ImageDownloader.h
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"
@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation
@property (nonatomic,assign)id<ImageDownloaderDelegate> delegate;
// 3
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

// 4
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate;


@end

@protocol ImageDownloaderDelegate<NSObject>
- (void)imageDownloaderDidFinish:(ImageDownloader*)downloader;
@end
