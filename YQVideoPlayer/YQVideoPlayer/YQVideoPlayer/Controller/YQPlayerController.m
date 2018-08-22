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

- (void)addPlayerItemTimeObserver {
    
    // Create 0.5 second refresh interval - REFRESH_INTERVAL == 0.5
    CMTime interval =
    CMTimeMakeWithSeconds(REFRESH_INTERVAL, NSEC_PER_SEC);              // 1
    
    // Main dispatch queue
    dispatch_queue_t queue = dispatch_get_main_queue();                     // 2
    
    // Create callback block for time observer
    __weak YQPlayerController *weakSelf = self;                             // 3
    void (^callback)(CMTime time) = ^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        [weakSelf.transport setCurrentTime:currentTime duration:duration];  // 4
    };
    
    // Add observer and store pointer for future use
    self.timeObserver =                                                     // 5
    [self.player addPeriodicTimeObserverForInterval:interval
                                              queue:queue
                                         usingBlock:callback];
}

- (void)addItemEndObserverForPlayerItem {
    
    NSString *name = AVPlayerItemDidPlayToEndTimeNotification;
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    __weak YQPlayerController *weakSelf = self;                             // 1
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        [weakSelf.player seekToTime:kCMTimeZero                             // 2
                  completionHandler:^(BOOL finished) {
                      [weakSelf.transport playbackComplete];                          // 3
                  }];
    };
    
    self.itemEndObserver =                                                  // 4
    [[NSNotificationCenter defaultCenter] addObserverForName:name
                                                      object:self.playerItem
                                                       queue:queue
                                                  usingBlock:callback];
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
