//
//  UIView+XYRoundedCornerAndShadow.m
//  WangPingYuan
//
//  Created by 王强 on 2018/3/13.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import "UIView+XYRoundedCornerAndShadow.h"
#import <objc/runtime.h>

static NSOperationQueue *operationQueue;
static char operationKey;

@implementation UIView (XYRoundedCornerAndShadow)

- (void)xyShadowColor:(UIColor *)color shadowOffset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius shadowHeight:(CGFloat)height {
    //shadowColor阴影颜色
    self.layer.shadowColor = color.CGColor;
    //shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    self.layer.shadowOffset = offset;
    //阴影透明度，默认0
    self.layer.shadowOpacity = opacity;
    //阴影半径，默认3
    self.layer.shadowRadius = radius;
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    float allWidth = self.bounds.size.width;
    float allHeight = self.bounds.size.height;
    float x = self.bounds.origin.x;
    float y = self.bounds.origin.y;
    float addShadowHeight = height;

    CGPoint topLeft = self.bounds.origin;
    CGPoint topMiddle = CGPointMake(x + (allWidth / 2.0),y - addShadowHeight);
    CGPoint topRight  = CGPointMake(x+allWidth,y);
    CGPoint rightMiddle = CGPointMake(x + allWidth + addShadowHeight,y + (allHeight / 2.0));
    CGPoint bottomRight  = CGPointMake(x + allWidth,y + allHeight);
    CGPoint bottomMiddle = CGPointMake(x + (allWidth / 2.0),y + allHeight + addShadowHeight);
    CGPoint bottomLeft   = CGPointMake(x,y + allHeight);
    CGPoint leftMiddle = CGPointMake(x - addShadowHeight,y + (allHeight / 2.0));
    [path moveToPoint:topLeft];
    //添加四个二元曲线
    [path addQuadCurveToPoint:topRight controlPoint:topMiddle];
    [path addQuadCurveToPoint:bottomRight controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft controlPoint:bottomMiddle];
    [path addQuadCurveToPoint:topLeft controlPoint:leftMiddle];
    //设置阴影路径
    self.layer.shadowPath = path.CGPath;
}

+ (void)load {
    operationQueue = [[NSOperationQueue alloc] init];
}

- (NSOperation *)getOperation {
    id operation = objc_getAssociatedObject(self, &operationKey);
    return operation;
}

- (void)setOperation:(NSOperation *)operation {
    objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelOperation {
    NSOperation *operation = [self getOperation];
    [operation cancel];
    [self setOperation:nil];
}

- (void)xySetCornerRadius:(CGFloat)radius withBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)width {
    [self cancelOperation];
    [self xySetXYRadius:XYRadiusMake(radius, radius, radius, radius) withBorderColor:borderColor borderWidth:width backgroundColor:nil backgroundImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero];
}

- (void)xySetCornerXYRadius:(XYRadius)radius withBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)width {
    [self cancelOperation];
    [self xySetXYRadius:radius withBorderColor:borderColor borderWidth:width backgroundColor:nil backgroundImage:nil contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero];
}

- (void)xySetXYRadius:(XYRadius)radius withBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)backgroundColor backgroundImage:(UIImage *)backgroundImage contentMode:(UIViewContentMode)contentMode size:(CGSize)size {
    
    __block CGSize _size = size;

    __weak typeof(self) wself = self;
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{

        if ([[wself getOperation] isCancelled]) return;

        if (CGSizeEqualToSize(_size, CGSizeZero)) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _size = wself.bounds.size;
            });
        }

        CGSize size2 = CGSizeMake(pixel(_size.width), pixel(_size.height));

        UIImage *image = [self XY_imageWithRoundedCornersAndSize:size2 XYRadius:radius borderColor:borderColor borderWidth:borderWidth backgroundColor:backgroundColor backgroundImage:backgroundImage withContentMode:contentMode];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            __strong typeof(wself) self = wself;
            if ([[self getOperation] isCancelled]) return;

            self.frame = CGRectMake(pixel(self.frame.origin.x), pixel(self.frame.origin.y), size2.width, size2.height);
            if ([self isKindOfClass:[UIImageView class]]) {
                ((UIImageView *)self).image = image;
            } else if ([self isKindOfClass:[UIButton class]] && backgroundImage) {
                [((UIButton *)self) setBackgroundImage:image forState:UIControlStateNormal];
            } else if ([self isKindOfClass:[UILabel class]]) {
                self.layer.backgroundColor = [UIColor colorWithPatternImage:image].CGColor;
            } else {
                self.layer.contents = (__bridge id _Nullable)(image.CGImage);
            }
        }];
    }];

    [self setOperation:blockOperation];
    [operationQueue addOperation:blockOperation];
}

- (UIImage *)XY_imageWithRoundedCornersAndSize:(CGSize)sizeToFit XYRadius:(XYRadius)radius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)backgroundColor backgroundImage:(UIImage *)backgroundImage withContentMode:(UIViewContentMode)contentMode {
    if (backgroundImage) {
        backgroundImage = [self scaleToSize:CGSizeMake(sizeToFit.width, sizeToFit.height) withContentMode:contentMode backgroundColor:backgroundColor];
        backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    } else if (!backgroundColor){
        backgroundColor = [UIColor whiteColor];
    }

    UIGraphicsBeginImageContextWithOptions(sizeToFit, NO, UIScreen.mainScreen.scale);

    CGFloat halfBorderWidth = borderWidth / 2;
    //设置上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //边框大小
    CGContextSetLineWidth(context, borderWidth);
    //边框颜色
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    //矩形填充颜色
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGFloat height = sizeToFit.height;
    CGFloat width = sizeToFit.width;
    radius = [self transformationXYRadius:radius size:sizeToFit borderWidth:borderWidth];

    CGFloat startPointY;
    if (radius.topRightRadius >= height - borderWidth) {
        startPointY = height;
    } else if (radius.topRightRadius > 0){
        startPointY = halfBorderWidth + radius.topRightRadius;
    } else {
        startPointY = 0;
    }
    CGContextMoveToPoint(context, width - halfBorderWidth, startPointY);  // 开始坐标右边开始
    CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width / 2, height - halfBorderWidth, radius.bottomRightRadius);  // 右下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height / 2, radius.bottomLeftRadius); // 左下角角度
    CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width / 2, halfBorderWidth, radius.topLeftRadius); // 左上角
    CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, height / 2, radius.topRightRadius); // 右上角
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径

    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

- (XYRadius)transformationXYRadius:(XYRadius)radius size:(CGSize)size borderWidth:(CGFloat)borderWidth {
    radius.topLeftRadius = minimum(size.width - borderWidth, size.height - borderWidth, radius.topLeftRadius - borderWidth / 2);
    radius.topRightRadius = minimum(size.width - borderWidth - radius.topLeftRadius, size.height - borderWidth, radius.topRightRadius - borderWidth / 2);
    radius.bottomLeftRadius = minimum(size.width - borderWidth, size.height - borderWidth - radius.topLeftRadius, radius.bottomLeftRadius - borderWidth / 2);
    radius.bottomRightRadius = minimum(size.width - borderWidth - radius.bottomLeftRadius, size.height - borderWidth - radius.topRightRadius, radius.bottomRightRadius - borderWidth / 2);
    return radius;
}

- (UIImage *)scaleToSize:(CGSize)size withContentMode:(UIViewContentMode)contentMode backgroundColor:(UIColor *)backgroundColor {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);

    if (backgroundColor) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextAddRect(context, rect);
        CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    }
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) withContentMode:contentMode];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

static inline CGFloat minimum(CGFloat a, CGFloat b, CGFloat c) {
    CGFloat minimum = MIN(MIN(a, b), c);
    return MAX(minimum, 0);
}

static inline float pixel(float num) {
    float unit = 1.0 / [UIScreen mainScreen].scale;
    double remain = fmod(num, unit);
    return num - remain + (remain >= unit / 2.0? unit: 0);
}

@end
