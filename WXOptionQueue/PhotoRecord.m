//
//  PhotoRecord.m
//  WXOptionQueue
//
//  Created by 吴海涛 on 14-6-12.
//  Copyright (c) 2014年 吴海涛. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord

- (BOOL)hasImage
{
    return _image != nil;
}

- (BOOL)isFailed
{
    return _failed;
}

- (BOOL)isFiltered
{
    return _filtered;
}

@end
