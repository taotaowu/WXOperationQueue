//
//  ImageFiltration.h
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//


// 1
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "PhotoRecord.h"

// 2
@protocol ImageFiltrationDelegate;

@interface ImageFiltration : NSOperation

@property (nonatomic, weak) id <ImageFiltrationDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageFiltrationDelegate>)theDelegate;

@end

@protocol ImageFiltrationDelegate <NSObject>
- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration;
@end