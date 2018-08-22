//
//  YQPlayerView.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "YQPlayerView.h"
#import "YQOverlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface YQPlayerView ()

// 视图实例
@property (nonatomic, strong) YQOverlayView *overlayView;

@end

@implementation YQPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (id)initWithPlayer:(AVPlayer *)player {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //将从AVPlayer输出的视频指向AVPlayerLayer实例
        [(AVPlayerLayer *)[self layer] setPlayer:player];
        
        [[NSBundle mainBundle] loadNibNamed:@"YQOverlayView" owner:self options:nil];
    
        [self addSubview:_overlayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

- (id<YQTransport>)transport {
    return self.overlayView;
}

@end
