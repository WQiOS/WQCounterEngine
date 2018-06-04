//
//  UILabel+WQCounter.h
//  WQCocoaPodsTest
//
//  Created by 王强 on 2018/6/1.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WQCounterEngine.h"

@interface UILabel (WQCounter)

/** 动画类型*/
@property (nonatomic, assign) WQCounterAnimationOptions animationOptions;

/**
 1.正常字体属性UILabel中的数字在指定时间从 numberA -> numberB,
 2.可设置动画类型,
 3.有结束回调

 @param numberA             开始的数字
 @param numberB             结束的数字
 @param duration            持续时间
 @param animationOptions    动画类型
 @param format              设置字体一般属性的block
 @param completion          完成的block
 */
- (void)animationFromNumber:(CGFloat)numberA
                   toNumber:(CGFloat)numberB
                   duration:(CFTimeInterval)duration
           animationOptions:(WQCounterAnimationOptions)animationOptions
                     format:(WQFormatBlock)format
                 completion:(WQCompletionBlock)completion;

@end
