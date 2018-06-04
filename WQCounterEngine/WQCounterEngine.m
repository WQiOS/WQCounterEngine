//
//  WQCounterEngine.m
//  WQCocoaPodsTest
//
//  Created by 王强 on 2018/5/31.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import "WQCounterEngine.h"
#import <CoreGraphics/CoreGraphics.h>

NSString *const kWQCounterAnimationOptions = @"kWQCounterAnimationOptions";

/** 函数指针*/
typedef CGFloat (*WQCurrentBufferFunction)(CGFloat);

@interface WQCounterEngine ()

/** 定时器*/
@property (nonatomic, strong) CADisplayLink *timer;
/** 开始的数字*/
@property (nonatomic, assign) CGFloat starNumber;
/** 结束的数字*/
@property (nonatomic, assign) CGFloat endNumber;
/** 动画的总持续时间*/
@property (nonatomic, assign) CFTimeInterval durationTime;
/** 记录上一帧动画的时间*/
@property (nonatomic, assign) CFTimeInterval lastTime;
/** 记录动画已持续的时间*/
@property (nonatomic, assign) CFTimeInterval progressTime;
/** 动画函数*/
@property WQCurrentBufferFunction currentBufferFunction;
/** 计数完成的Block*/
@property (nonatomic, copy) WQCompletionBlock completion;
/** 获取当前数字的Block*/
@property (nonatomic, copy) WQCurrentNumberBlock currentNumber;

@end

@implementation WQCounterEngine

+ (instancetype)shareEngine {
    static dispatch_once_t onceToken;
    static WQCounterEngine *shareEngine = nil;
    dispatch_once(&onceToken, ^{
        shareEngine = [[self alloc] init];
    });
    return shareEngine;
}

- (void)animationFromNumber:(CGFloat)starNumer
                   toNumber:(CGFloat)endNumber
                   duration:(CFTimeInterval)duration
           animationOptions:(WQCounterAnimationOptions)animationOptions
              currentNumber:(WQCurrentNumberBlock)currentNumber
                 completion:(WQCompletionBlock)completion {
    // 开始前清空定时器
    [self cleanTimer];

    // 如果开始数字与结束数字相等
    if (starNumer == endNumber) {
        currentNumber ? currentNumber(endNumber) : nil ;
        completion ? completion() : nil;
        return;
    }

    // 初始化相关变量
    _starNumber = starNumer;
    _endNumber = endNumber;
    _durationTime = duration;

    // 设置缓冲动画类型
    [self setAnimationOptions:animationOptions];

    // 设置block回调函数
    currentNumber ? _currentNumber = currentNumber : nil ;
    completion ? _completion = completion : nil ;

    // 记录定时器运行前的时间
    _lastTime = CACurrentMediaTime();

    // 实例化定时器
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeNumber)];
    _timer.frameInterval = 2;
    [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
}

- (void)changeNumber {
    // 1.记录当前动画开始的时间
    CFTimeInterval thisTime = CACurrentMediaTime();
    // 2.计算动画已持续的时间量
    _progressTime = _progressTime + (thisTime - _lastTime);
    // 3.准备下一次的计算
    _lastTime = thisTime;

    if (_progressTime >= _durationTime) {
        [self cleanTimer];
        _currentNumber ? _currentNumber(_endNumber) : nil ;
        _completion ? _completion() : nil ;
        return;
    }
    _currentNumber ? _currentNumber([self computeNumber]) : nil ;
}

- (void)setAnimationOptions:(WQCounterAnimationOptions)animationOptions {
    switch (animationOptions) {
        case WQCounterAnimationOptionCurveEaseInOut:
            _currentBufferFunction = WQBufferFunctionEaseInOut;
            break;
        case WQCounterAnimationOptionCurveEaseIn:
            _currentBufferFunction = WQBufferFunctionEaseIn;
            break;
        case WQCounterAnimationOptionCurveEaseOut:
            _currentBufferFunction = WQBufferFunctionEaseOut;
            break;
        case WQCounterAnimationOptionCurveLinear:
            _currentBufferFunction = WQBufferFunctionLinear;
            break;
        default:
            break;
    }
}

/**
 计算数字
 */
- (CGFloat)computeNumber {
    CGFloat percent = _progressTime / _durationTime;
    return _starNumber + (_currentBufferFunction(percent) * (_endNumber - _starNumber));
}

/**
 清除定时器
 */
- (void)cleanTimer {
    if (!_timer) {return;}
    [_timer invalidate];
    _timer = nil;
    _progressTime = 0;
}

#pragma mark - 缓冲动画函数

CGFloat WQBufferFunctionEaseOut(CGFloat p) {
    return (p == 1.0) ? p : 1 - pow(2, -10 * p);
}

CGFloat WQBufferFunctionEaseIn(CGFloat p) {
    return (p == 0.0) ? p : pow(2, 10 * (p - 1));
}

CGFloat WQBufferFunctionEaseInOut(CGFloat p) {
    if(p == 0.0 || p == 1.0) return p;

    if(p < 0.5) {
        return 0.5 * pow(2, (20 * p) - 10);
    } else {
        return -0.5 * pow(2, (-20 * p) + 10) + 1;
    }
}

CGFloat WQBufferFunctionLinear(CGFloat p) {
    return p;
}


@end
