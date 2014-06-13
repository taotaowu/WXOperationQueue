//
//  PhotoRecord.h
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoRecord : NSObject

@property (nonatomic, strong) NSString *name;  // To store the name of image
@property (nonatomic, strong) UIImage *image; // To store the actual image
@property (nonatomic, strong) NSURL *URL; // To store the URL of the image
@property (nonatomic, readonly) BOOL hasImage; // Return YES if image is downloaded.
@property (nonatomic, getter = isFiltered) BOOL filtered; // Return YES if image is sepia-filtered
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded

@end
