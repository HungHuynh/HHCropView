//
//  ViewController.h
//  cropper
//
//  Created by Showyou Friends on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropperView.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate> {
    UIImage *imgOrig;
    UIImage *imgCrop;
    CropperView *cropperView;
    IBOutlet UIView *uvViewImage;
    IBOutlet UIToolbar *ubToolBar;
    
    CGFloat beginX;
    CGFloat beginY;
    
    CGFloat scale;
    CGFloat lastScale;
    CGFloat currDegree;
}

- (IBAction)doCancel:(id)sender;
- (IBAction)doSave:(id)sender;

@end
