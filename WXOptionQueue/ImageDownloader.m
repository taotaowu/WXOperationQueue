//
//  ImageDownloader.m
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import "ImageDownloader.h"

// 1
@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@end


@implementation ImageDownloader


#pragma mark -
#pragma mark - Life Cycle
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        // 2
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image
- (void)main
{
    //4
    @autoreleasepool {
        if(self.isCancelled)
            return;
        NSData *imageData  = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        if (self.isCancelled)
        {
            imageData = nil;
            return;
        }
        if(imageData)
        {
            UIImage *downloadImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadImage;
        }else
        {
            self.photoRecord.failed = YES;
        }
        imageData = nil;
        if(self.isCancelled)
            return;
        //5
        [((NSObject*)self.delegate) performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
    }
}



@end
