//
//  UILabel+WQCounter.m
//  WQCocoaPodsTest
//
//  Created by 王强 on 2018/6/1.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import "UILabel+WQCounter.h"
#import <objc/runtime.h>
#import "WQCounterEngine.h"

@implementation UILabel (WQCounter)

#pragma mark - normal font
- (void)animationFromNumber:(CGFloat)numberA
                   toNumber:(CGFloat)numberB
                   duration:(CFTimeInterval)duration
           animationOptions:(WQCounterAnimationOptions)animationOptions
                     format:(WQFormatBlock)format
                 completion:(WQCompletionBlock)completion {

    if (self.animationOptions) {animationOptions = self.animationOptions;}
    __weak __typeof(self)weakSelf = self;
    [[WQCounterEngine shareEngine] animationFromNumber:numberA toNumber:numberB duration:duration animationOptions:animationOptions currentNumber:^(CGFloat number) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        format ? strongSelf.text = format(number) : nil ;
    } completion:completion];
}


#pragma mark - setter/getter

- (void)setAnimationOptions:(WQCounterAnimationOptions)animationOptions {
    objc_setAssociatedObject(self, &kWQCounterAnimationOptions, @(animationOptions), OBJC_ASSOCIATION_ASSIGN);
}

- (WQCounterAnimationOptions)animationOptions {
    return [objc_getAssociatedObject(self, &kWQCounterAnimationOptions) integerValue];
}

@end
