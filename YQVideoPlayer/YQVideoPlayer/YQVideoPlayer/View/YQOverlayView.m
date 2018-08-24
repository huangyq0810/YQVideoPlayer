//
//  YQOverlayView.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "YQOverlayView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YQOverlayView()

// 是否显示进度条等
@property (nonatomic, assign) BOOL showInfo;

@end

@implementation YQOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage *thumbNormalImage = [UIImage imageNamed:@"knob"];
    UIImage *thumbHighlightedImage = [UIImage imageNamed:@"knob_highlighted"];
    [self.scrubberSlider setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    [self.scrubberSlider setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];
    
    // Set up actions
    [self.scrubberSlider addTarget:self action:@selector(showPopupUI) forControlEvents:UIControlEventValueChanged];
    
    self.showInfo = NO;
    self.togglePlaybackButton.selected = YES;
    [self setupInfoShow];
}

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    NSInteger currentSeconds = ceilf(time);
    double remainingTime = duration - time;
    self.currentTimeLabel.text = [self formatSeconds:currentSeconds];
    self.remainingTimeLabel.text = [self formatSeconds:remainingTime];
    self.scrubberSlider.minimumValue = 0.0f;
    self.scrubberSlider.maximumValue = duration;
    self.scrubberSlider.value = time;
}

// 拖动圆点时更新时间
- (void)setScrubbingTime:(NSTimeInterval)time {
    NSInteger currentSeconds = ceilf(time);
    double remainingTime = self.scrubberSlider.maximumValue - time;
    self.currentTimeLabel.text = [self formatSeconds:currentSeconds];
    self.remainingTimeLabel.text = [self formatSeconds:remainingTime];
}

// 转换成时间显示形式
- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [self.delegate jumpedToTime:currentTime];
}

- (void)playbackComplete {
    self.scrubberSlider.value = 0.0f;
    self.togglePlaybackButton.selected = NO;
}

- (void)showPopupUI {
    self.currentTimeLabel.text = @"-- : --";
    self.remainingTimeLabel.text = @"-- : --";
    
    [self setScrubbingTime:self.scrubberSlider.value];
    [self.delegate scrubbedToTime:self.scrubberSlider.value];
}

// 设置是否显示进度条等
- (void)setupInfoShow {
    self.holderView.hidden = !self.showInfo;
    self.togglePlaybackButton.hidden = !self.showInfo;
    self.dismissButton.hidden = !self.showInfo;
}

#pragma mark - 事件响应

- (IBAction)togglePlayback:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate) {
        if (sender.selected) {
            [self.delegate performSelector:@selector(play)];
        } else {
            [self.delegate performSelector:@selector(pause)];
        }
    }
}

- (IBAction)closeWindow:(id)sender {
    [self.delegate stop];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.showInfo = !self.showInfo;
    [self setupInfoShow];
}

@end
