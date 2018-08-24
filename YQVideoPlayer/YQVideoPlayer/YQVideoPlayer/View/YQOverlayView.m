//
//  YQOverlayView.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "YQOverlayView.h"
#import "NSTimer+Extension.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YQOverlayView ()

@property (nonatomic) BOOL controlsHidden;
@property (nonatomic) BOOL filmstripHidden;
@property (strong, nonatomic) NSArray *excludedViews;
//@property (nonatomic, assign) CGFloat sliderOffset;
@property (nonatomic, assign) CGFloat infoViewOffset;
@property (strong, nonatomic) NSTimer *timer;
@property (assign) BOOL scrubbing;
@property (assign) CGFloat lastPlaybackRate;
@property (strong, nonatomic) MPVolumeView *volumeView;

//
@property (strong, nonatomic) UIButton *playButton;

@end


@implementation YQOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.filmstripHidden = YES;
    self.excludedViews = @[self.navigationBar, self.toolbar];
    
    UIImage *thumbNormalImage = [UIImage imageNamed:@"knob"];
    UIImage *thumbHighlightedImage = [UIImage imageNamed:@"knob_highlighted"];
    [self.scrubberSlider setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    [self.scrubberSlider setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];
    
    self.infoView.hidden = YES;
    
    [self calculateInfoViewOffset];
    
    // Set up actions
    [self.scrubberSlider addTarget:self action:@selector(showPopupUI) forControlEvents:UIControlEventValueChanged];
//    [self.scrubberSlider addTarget:self action:@selector(hidePopupUI) forControlEvents:UIControlEventTouchUpInside];
//    [self.scrubberSlider addTarget:self action:@selector(unhidePopupUI) forControlEvents:UIControlEventTouchDown];
    
    [self resetTimer];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100,100)];
    self.playButton.backgroundColor = [UIColor purpleColor];
    [self.playButton setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"pause_button"] forState:UIControlStateSelected];
    
    [self addSubview:self.playButton];
    [self.playButton addTarget:self action:@selector(clickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.playButton.hidden = YES;
}

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playButton.center = self.center;
}

- (void)calculateInfoViewOffset {
    [self.infoView sizeToFit];
    self.infoViewOffset = ceilf(CGRectGetWidth(self.infoView.frame) / 2);
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

- (void)setScrubbingTime:(NSTimeInterval)time {
    self.scrubbingTimeLabel.text = [self formatSeconds:time];
}

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (UILabel *)createTransportLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:15.0f];
    label.text = @"00:00";
    label.userInteractionEnabled = YES;
    [label sizeToFit];
    return label;
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
    [self.timer invalidate];
    self.timer = nil;
    [self.delegate stop];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPopupUI {
    self.infoView.hidden = NO;
    CGRect trackRect = [self.scrubberSlider convertRect:self.scrubberSlider.bounds toView:nil];
    CGRect thumbRect = [self.scrubberSlider thumbRectForBounds:self.scrubberSlider.bounds trackRect:trackRect value:self.scrubberSlider.value];
    
    CGRect rect = self.infoView.frame;
    rect.origin.x = (thumbRect.origin.x) - self.infoViewOffset + 16;
    rect.origin.y = self.bounds.size.height - 80;
    self.infoView.frame = rect;
    
    self.currentTimeLabel.text = @"-- : --";
    self.remainingTimeLabel.text = @"-- : --";
    
    [self setScrubbingTime:self.scrubberSlider.value];
    [self.delegate scrubbedToTime:self.scrubberSlider.value];
}

- (void)unhidePopupUI {
    self.infoView.hidden = NO;
    self.infoView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        self.infoView.alpha = 1.0f;
    }];
    self.scrubbing = YES;
    [self resetTimer];
    [self.delegate scrubbingDidStart];
}

- (void)hidePopupUI {
    [UIView animateWithDuration:0.3f animations:^{
        self.infoView.alpha = 0.0f;
    } completion:^(BOOL complete) {
        self.infoView.alpha = 1.0f;
        self.infoView.hidden = YES;
    }];
    self.scrubbing = NO;
    [self.delegate scrubbingDidEnd];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [self.delegate jumpedToTime:currentTime];
}

- (void)playbackComplete {
    self.scrubberSlider.value = 0.0f;
    self.togglePlaybackButton.selected = NO;
}

- (void)resetTimer {
    [self.timer invalidate];
    if (!self.scrubbing) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 firing:^{
//            if (self.timer.isValid && !self.controlsHidden) {
//                [self toggleControls:nil];
//            }
        }];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"-----touch-----");
}

@end
