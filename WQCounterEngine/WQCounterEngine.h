//
//  WQCounterEngine.h
//  WQCocoaPodsTest
//
//  Created by 王强 on 2018/5/31.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WQCounterAnimationOptions) {
    /** 由慢到快,再由快到慢*/
    WQCounterAnimationOptionCurveEaseInOut = 1,
    /** 由慢到快*/
    WQCounterAnimationOptionCurveEaseIn,
    /** 由快到慢*/
    WQCounterAnimationOptionCurveEaseOut,
    /** 匀速*/
    WQCounterAnimationOptionCurveLinear
};

typedef NSString *(^WQFormatBlock)(CGFloat currentNumber);
typedef void (^WQCurrentNumberBlock)(CGFloat currentNumber);
typedef void (^WQCompletionBlock)(void);

extern NSString *const kWQCounterAnimationOptions;

@interface WQCounterEngine : NSObject

/**
 类方法创建一个计数器的实例
 */
+ (instancetype)shareEngine;

/**
 在指定时间内数字从 numberA -> numberB

 @param starNumer           开始的数字
 @param endNumber           结束的数字
 @param duration            指定的时间
 @param animationOptions    动画类型
 @param currentNumber       当前数字的回调
 @param completion          已完成的回调
 */
- (void)animationFromNumber:(CGFloat)starNumer
                   toNumber:(CGFloat)endNumber
                   duration:(CFTimeInterval)duration
           animationOptions:(WQCounterAnimationOptions)animationOptions
              currentNumber:(WQCurrentNumberBlock)currentNumber
                 completion:(WQCompletionBlock)completion;

@end
