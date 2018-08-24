//
//  YQOverlayView.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "YQOverlayView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YQOverlayView ()

@property (strong, nonatomic) UIButton *playButton;

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
    
    // Set up playButton
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50,50)];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];

//    [self addSubview:self.playButton];
    self.playButton.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playButton.center = self.center;
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

- (void)showPopupUI {
    self.currentTimeLabel.text = @"-- : --";
    self.remainingTimeLabel.text = @"-- : --";
    
    [self setScrubbingTime:self.scrubberSlider.value];
    [self.delegate scrubbedToTime:self.scrubberSlider.value];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [self.delegate jumpedToTime:currentTime];
}

- (void)playbackComplete {
    self.scrubberSlider.value = 0.0f;
    self.togglePlaybackButton.selected = NO;
}

#pragma mark - 事件响应

- (void)clickPlayButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    sender.hidden = sender.selected;
    if (self.delegate) {
        if (sender.selected) {
            [self.delegate performSelector:@selector(play)];
        } else {
            [self.delegate performSelector:@selector(pause)];
        }
    }
    self.togglePlaybackButton.selected = sender.selected;
}

- (IBAction)togglePlayback:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.playButton.hidden = sender.selected;
    if (self.delegate) {
        if (sender.selected) {
            [self.delegate performSelector:@selector(play)];
        } else {
            [self.delegate performSelector:@selector(pause)];
        }
    }
    self.playButton.selected = sender.selected;
}

- (IBAction)closeWindow:(id)sender {
    [self.delegate stop];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"-----touch-----");

}

@end
