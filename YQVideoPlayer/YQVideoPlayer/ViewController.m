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


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSURL *string = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];//@"https://image.52doushi.com/hiweixiu/1_20170401.mp4";
    YQPlayerController *playerController = [[YQPlayerController alloc] initWithURL: string];
    [self presentViewController:playerController animated:YES completion:nil];
}


@end
