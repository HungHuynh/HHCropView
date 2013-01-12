//
//  FinalOutputView.h.h
//
//  Created by hunghuynh on 12/1/12.
//  Copyright 2012 Catamount Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FinalOutputView : UIViewController {
    
    IBOutlet UIImageView *imageView;
    UIImage* image;
}

@property (nonatomic, retain) UIImage* image;

- (IBAction)doBack:(id)sender;
@end
