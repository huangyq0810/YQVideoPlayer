//
//  YQPlayerView.h
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQTransport.h"

@class AVPlayer;

@interface YQPlayerView : UIView

- (id)initWithPlayer:(AVPlayer *)player;

@property (nonatomic, readonly) id <YQTransport> transport;


@end
