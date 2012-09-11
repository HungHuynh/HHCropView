//
//  ViewController.m
//  cropper
//
//  Created by Showyou Friends on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define     PATH_DOCUMENT_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    imgOrig = [UIImage imageNamed:@"image.png"];
    cropperView = [[CropperView alloc] initWithImage:imgOrig andMaxSize:CGSizeMake(uvViewImage.frame.size.width,uvViewImage.frame.size.height)];
    [uvViewImage addSubview:cropperView];
    
    //Pan Gesture :
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [uvViewImage addGestureRecognizer:panGesture];
    
    //Pinch Gesture :
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePincheGesture:)];
    pinchGesture.delegate = self;
    [uvViewImage addGestureRecognizer:pinchGesture];
    
    //Rotate gesture :
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    [uvViewImage addGestureRecognizer:rotateGesture];
    
    //Int value :
    scale = 1.0;
    lastScale = 1.0;
    currDegree = 0.0;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([gestureRecognizer.view isKindOfClass:[UIView class]]) {
        return YES;
    }
    
    return YES;
}

-(void)handlePanGesture:(UIPanGestureRecognizer *) recognizer { 
    NSLog(@"pan");
    CGPoint newCenter = [recognizer translationInView:self.view];
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        beginX = cropperView.imageView.center.x;
        beginY = cropperView.imageView.center.y;
    }
    
    newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
    [cropperView.imageView setCenter:newCenter];
}

-(void)handlePincheGesture:(UIPinchGestureRecognizer *) recognizer {
    NSLog(@"pinch");
    
    scale += recognizer.scale - lastScale;
    lastScale = recognizer.scale;
    
    if (scale < 1.0) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        lastScale = 1.0;
    }
    
    //CGAffineTransform currentTransform = CGAffineTransformIdentity;
    CGAffineTransform newTransform = CGAffineTransformMakeScale( scale, scale);
    cropperView.imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(currDegree), newTransform); 
    
}

-(void)handleRotateGesture:(UIRotationGestureRecognizer *) recognizer {
    
}

- (void)viewDidUnload
{
    [ubToolBar release];
    ubToolBar = nil;
    [uvViewImage release];
    uvViewImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)doCancel:(id)sender {
    [cropperView setImage:imgOrig];
}

- (IBAction)doSave:(id)sender {
    imgCrop = [cropperView getCroppedImage];
    [cropperView setImage:imgCrop];
    
    [UIImagePNGRepresentation(imgCrop) writeToFile:[NSString stringWithFormat:@"%@/temp.png",PATH_DOCUMENT_FOLDER] atomically:YES];
}
- (void)dealloc {
    [ubToolBar release];
    [uvViewImage release];
    [super dealloc];
}
@end
