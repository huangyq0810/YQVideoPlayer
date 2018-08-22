//
//  YQPlayerController.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "YQPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "YQTransport.h"
#import "YQPlayerView.h"
#import "AVAsset+Extension.h"

// AVPlayerItem's status property
#define STATUS_KEYPATH @"status"

// Refresh interval for timed observations of AVPlayer
#define REFRESH_INTERVAL 0.5f

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;

@interface YQPlayerController () <YQTransportDelegate>

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) YQPlayerView *playerView;

@property (weak, nonatomic) id <YQTransport> transport;

@property (strong, nonatomic) id timeObserver;
@property (strong, nonatomic) id itemEndObserver;
@property (assign, nonatomic) float lastPlaybackRate;

@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@end

@implementation YQPlayerController

- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        _asset = [AVAsset assetWithURL:assetURL];                           // 1
        [self prepareToPlay];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self prepareToPlay];
}

- (void)prepareToPlay {
    NSArray *keys = @[@"tracks",
                      @"duration",
                      @"commonMetadata",
                      @"availableMediaCharacteristicsWithMediaSelectionOptions"];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset automaticallyLoadedAssetKeys:keys];
    [self.playerItem addObserver: self forKeyPath:STATUS_KEYPATH options:0 context: &PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerView = [[YQPlayerView alloc] initWithPlayer:self.player];
    self.transport = self.playerView.transport;
    self.transport.delegate = self;
}

// 监听状态改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                // Set up time observers
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                CMTime duration = self.playerItem.duration;
                
                // Synchronize the timw display
                [self.transport setCurrentTime:CMTimeGetSeconds(kCMTimeZero) duration:CMTimeGetSeconds(duration)];
                
                // Set the video title.
                [self.transport setTitle:self.asset.title];
                
                [self.player play];
                
//                [self loadMediaOptions];
//                [self g];
            } else {
                NSLog(@"Fail to load video");
            }
        });
    }
}

- (void)loadMediaOptions {
    NSString *mc = AVMediaCharacteristicLegible;                            // 1
    AVMediaSelectionGroup *group =
    [self.asset mediaSelectionGroupForMediaCharacteristic:mc];          // 2
    if (group) {
        NSMutableArray *subtitles = [NSMutableArray array];                 // 3
        for (AVMediaSelectionOption *option in group.options) {
            [subtitles addObject:option.displayName];
        }
        [self.transport setSubtitles:subtitles];                            // 4
    } else {
        [self.transport setSubtitles:nil];
    }
}

- (void)subtitleSelected:(NSString *)subtitle {
    NSString *mc = AVMediaCharacteristicLegible;
    AVMediaSelectionGroup *group =
    [self.asset mediaSelectionGroupForMediaCharacteristic:mc];          // 1
    BOOL selected = NO;
    for (AVMediaSelectionOption *option in group.options) {
        if ([option.displayName isEqualToString:subtitle]) {
            [self.playerItem selectMediaOption:option                       // 2
                         inMediaSelectionGroup:group];
            selected = YES;
        }
    }
    if (!selected) {
        [self.playerItem selectMediaOption:nil                              // 3
                     inMediaSelectionGroup:group];
    }
}


#pragma mark - Time Observers

// 定期监听 (还有一种是边界时间监听)
- (void)addPlayerItemTimeObserver {
    
    // 设置定期时间间隔为0.5秒
    CMTime interval = CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);
    
    // 定义发送回调通知的调度队列，大多数情况下，由于我们所要更新的用户界面处于主线程，所以一般使用主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 定义一个回调块，在前面定义的时间周期内会调用该代码块
    __weak YQPlayerController *weakSelf = self;
    void (^callback)(CMTime time) = ^(CMTime time) {
        NSTimeInterval currentTime =CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];
    };
    
    // 调用定期监听的方法，返回的id类型指针会用于移除监听器
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:callback];
}

// 条目结束监听
- (void)addItemEndObserverForPlayerItem {
    
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak YQPlayerController *weakSelf = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notificaiton) {
        // 播放完毕，通过seekToTime方法重新定位播放头光标回到0位置
        [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            // 通知播放栏播放已经完成了，这样就可以重新设置展示时间和进度条
            [weakSelf.transport playbackComplete];
        }];
    };
    
    // 添加监听
    self.itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:name object:self.playerItem queue:queue usingBlock:callback];

}

// 当控制器被释放时移除作为监听器的itemEndObserver
- (void)dealloc {
    if (self.itemEndObserver) {
        NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
        [[NSNotificationCenter defaultCenter] removeObserver:self.itemEndObserver name:name object:self.playerItem];
        self.itemEndObserver = nil;
    }
}

#pragma mark - YQTransportDelegate

- (void)jumpedToTime:(NSTimeInterval)time {
    
}

- (void)pause {
    
}

- (void)play {
    
}

- (void)scrubbedToTime:(NSTimeInterval)time {
    
}

- (void)scrubbingDidEnd {
    
}

- (void)scrubbingDidStart {
    
}

- (void)stop {
    
}


#pragma mark - 1

- (UIView *)view {
    return self.playerView;
}

@end
