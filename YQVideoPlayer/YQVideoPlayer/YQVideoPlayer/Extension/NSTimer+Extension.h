//
//  NSTimer+Extension.h
//  YQVideoPlayer
//
//  Created by admin on 22/8/18.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimerFireBlock)(void);

@interface NSTimer (Extension)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval firing:(TimerFireBlock)fireBlock;

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval repeating:(BOOL)repeat firing:(TimerFireBlock)fireBlock;


@end
