//
//  cropperView.h
//  cropper
//
//  Created by Showyou Friends on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_CROPPER_OUTSIDE_STILL_TOUCHABLE 0.0f //40.0f
#define IMAGE_CROPPER_INSIDE_STILL_EDGE 20.0f

#ifndef __has_feature
// not LLVM Compiler
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#define ARC
#endif

@interface CropperView : UIView <UIGestureRecognizerDelegate> {
    UIImageView *imageView;
    UIView *cropView;
    
//    UIView *topView;
//    UIView *bottomView;
//    UIView *leftView;
//    UIView *rightView;
    
    UIView *topLeftView;
    UIView *topRightView;
    UIView *bottomLeftView;
    UIView *bottomRightView;
    
    CGFloat imageScale;
    
    BOOL isPanning;
    NSInteger currentTouches;
    CGPoint panTouch;
    CGFloat scaleDistance;
    UIView *currentDragView; // Weak reference 
    
    //Gesture 
//    CGFloat beginX;
//    CGFloat beginY;
//    CGFloat scale;
//    CGFloat lastScale;
//    CGFloat currDegree;
}

@property (nonatomic, assign) CGRect crop;
@property (nonatomic, readonly) CGRect unscaledCrop;

@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain, readonly) UIView *cropView;
@property (nonatomic, retain, readonly) UIImageView* imageView;

+ (UIView *)initialCropViewForImageView:(UIImageView*)imageView;

- (id)initWithImage:(UIImage*)newImage;
- (id)initWithImage:(UIImage*)newImage andMaxSize:(CGSize)maxSize;

- (UIImage*) getCroppedImage;

@end
