//
//  FinalOutputView.h.h
//
//  Created by hunghuynh on 12/1/12.
//  Copyright 2012 Catamount Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage-Extensions.h"
#import "UIView+ColorOfPoint.h"

@interface CropViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    
    //IBOutlet UIToolbar *utBar;
    UIImage* previewImage;
    UIImageView* imageView;
    UIImage* imageOrigi;
    
    CGFloat scale;
    CGFloat lastScale;
    CGFloat currDegree;
    int centerX, centerY;
    
    int lastX, lastY;
    UIView  *rectMain, *rectHor, *rectVer;
    UIView *bgTop, *bgRight, *bgLeft, *bgBottom;
    UIView *lineTopLeft, *lineTopRight, *lineBottomLeft, *lineBottomRight;
    UIImageView *cornerTopLeft, *cornerTopRight, *cornerBottomLeft, *cornerBottomRight;
    
    UIView  *viewResizeTop, *viewResizeBottom, *viewResizeLeft, *viewResizeRight;
    
    CGPoint lastPoint;
    CGRect lastFrame;
    CGPoint lastCenter;
    float lastDegree;
    float lastScaled;
    float minScale;
    
    IBOutlet    UIView  *viewContainer;
    IBOutlet    UIToolbar   *toolbar;
    
    UIInterfaceOrientation      currOrientation;
}

@property (nonatomic, retain) UIImage* previewImage;

-(IBAction) doneEditing;
-(IBAction) doCancel;
@end
