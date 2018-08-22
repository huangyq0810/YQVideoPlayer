//
//  AVAsset+Extension.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AVAsset+Extension.h"

@implementation AVAsset (Extension)

- (NSString *)title {
    AVKeyValueStatus status = [self statusOfValueForKey:@"commonMetadata" error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items = [AVMetadataItem metadataItemsFromArray:self.commonMetadata
                                                        withKey:AVMetadataCommonKeyTitle
                                                       keySpace:AVMetadataKeySpaceCommon];
        if (items.count > 0) {
            AVMetadataItem *item = [items firstObject];
            return (NSString *)item.value;
        }
    }
    
    return nil;
}


@end
