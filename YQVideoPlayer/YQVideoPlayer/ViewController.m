//
//  ViewController.m
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ViewController.h"
#import "YQPlayerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)playVideo:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"222" withExtension:@"mov"]; // 本地
//        NSURL *url = [NSURL URLWithString:@"https://image.52doushi.com/hiweixiu/1_20170401.mp4"]; // 网络
    YQPlayerController *playerController = [[YQPlayerController alloc] initWithURL: url];
    [self presentViewController:playerController animated:YES completion:nil];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"222" withExtension:@"mov"]; // 本地
////    NSURL *url = [NSURL URLWithString:@"https://image.52doushi.com/hiweixiu/1_20170401.mp4"]; // 网络
//    YQPlayerController *playerController = [[YQPlayerController alloc] initWithURL: url];
//    [self presentViewController:playerController animated:YES completion:nil];
//}


@end
