//
//  UIView+XYRoundedCornerAndShadow.h
//  WangPingYuan
//
//  Created by 王强 on 2018/3/13.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import <UIKit/UIKit.h>

struct XYRadius {
    CGFloat topLeftRadius;
    CGFloat topRightRadius;
    CGFloat bottomLeftRadius;
    CGFloat bottomRightRadius;
};
typedef struct XYRadius XYRadius;

static inline XYRadius XYRadiusMake(CGFloat topLeftRadius, CGFloat topRightRadius, CGFloat bottomLeftRadius, CGFloat bottomRightRadius) {
    XYRadius radius;
    radius.topLeftRadius = topLeftRadius;
    radius.topRightRadius = topRightRadius;
    radius.bottomLeftRadius = bottomLeftRadius;
    radius.bottomRightRadius = bottomRightRadius;
    return radius;
}

@interface UIView (XYRoundedCornerAndShadow)

/**
 设置控件的阴影

 @param color    阴影颜色
 @param offset   阴影的偏移量
 @param opacity  阴影的透明度
 @param radius   阴影的半径
 @param height   阴影的高度
 */
- (void)xyShadowColor:(UIColor *)color shadowOffset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius shadowHeight:(CGFloat)height;

/**
 设置圆角

 @param radius 圆角大小
 */
- (void)xySetCornerRadius:(CGFloat)radius;

/**
 设置圆角

 @param radius 圆角大小
 */
- (void)xySetCornerXYRadius:(XYRadius)radius;

/**
 设置一个圆角边框

 @param radius       圆角大小
 @param borderColor  边框颜色
 @param width        边框宽度
 */
- (void)xySetCornerRadius:(CGFloat)radius withBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)width;

/**
 设置一个圆角边框

 @param radius       圆角大小
 @param borderColor  边框颜色
 @param width        边框宽度
 */
- (void)xySetCornerXYRadius:(XYRadius)radius withBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)width;

@end
