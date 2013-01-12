
//  Created by Quan Do

#import "CropViewController.h"
#import "FinalOutputView.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark - Define 

#define MIN_WIDTH   90
#define MIN_HEIGHT  90

#define LINE_COLOR   [UIColor lightGrayColor]

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

//#define pointTopLeft  CGPointMake(cornerTopLeft.frame.origin.x-1, cornerTopLeft.frame.origin.y-1)
//#define pointTopRight  CGPointMake(cornerTopRight.frame.origin.x + cornerTopRight.frame.size.width , cornerTopRight.frame.origin.y ) //+1 -1
//#define pointBottomLeft  CGPointMake(cornerBottomLeft.frame.origin.x +1, cornerBottomLeft.frame.origin.y + cornerBottomLeft.frame.size.height +1)
//#define pointBottomRight  CGPointMake(cornerBottomRight.frame.origin.x + cornerBottomRight.frame.size.width +1, cornerBottomRight.frame.origin.y + cornerBottomRight.frame.size.height + 1)

#define POINT_RANGE     0
#define pointTopLeft  CGPointMake(rectMain.frame.origin.x-1, rectMain.frame.origin.y-2) 
#define pointTopRight  CGPointMake(rectMain.frame.origin.x + rectMain.frame.size.width + POINT_RANGE, rectMain.frame.origin.y - POINT_RANGE -1) //+1 -1
#define pointBottomLeft  CGPointMake(rectMain.frame.origin.x -POINT_RANGE, rectMain.frame.origin.y + rectMain.frame.size.height +POINT_RANGE)
#define pointBottomRight  CGPointMake(rectMain.frame.origin.x + rectMain.frame.size.width +POINT_RANGE, rectMain.frame.origin.y + rectMain.frame.size.height + POINT_RANGE)


@implementation CropViewController
@synthesize previewImage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [previewImage release];
    //[scrollView release];
    //[utBar release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Crop";
    
    //Show the done editing button on right side of the navigation bar
//    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
//    
//    self.navigationItem.rightBarButtonItem = doneButton;
//       
//    [doneButton release];
    
    //The following piece of code makes images fit inside the scrollview
    //by either their width or height, depending on which is smaller.
    //I.e, portrait images will fit horizontally in the scrollview,
    //allowing user to scroll vertically, while landscape images will fit vertically,
    //allowing user to scroll horizontally. 
    CGFloat imageWidth = CGImageGetWidth(previewImage.CGImage);
    CGFloat imageHeight = CGImageGetHeight(previewImage.CGImage);
    
    int scrollWidth = 320;
    int scrollHeight = 416;
    
    //Limit by width or height, depending on which is smaller in relation to
    //the scrollview dimension.
    float scaleX = scrollWidth / imageWidth;
    float scaleY = scrollHeight / imageHeight;
    float scaleScroll =  (scaleX > scaleY ? scaleY : scaleX);
//    scrollView.bounds = CGRectMake(0, 0,imageWidth , imageHeight );
//    scrollView.frame = CGRectMake(10, 10, scrollWidth, scrollHeight);
    
    //Int value :
    scale = scaleScroll;
    lastScale = scaleScroll;
    currDegree = 0.0;
    
    
    imageView = [[UIImageView alloc] initWithImage: previewImage ];
    
    
    CGAffineTransform newTransform = CGAffineTransformMakeScale( scale, scale);
    imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(currDegree), newTransform);
    
    [imageView setCenter:CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2)];
    imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    //[scrollView addSubview:imageView];
    [viewContainer addSubview:imageView];
    
    //Add tool bar :
//    [utBar setFrame:CGRectMake(0, 416, 320, 44)];
//    [viewContainer addSubview:utBar];
    
    //Pan Gesture
    UIPanGestureRecognizer  *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [viewContainer addGestureRecognizer:panGesture];
    
    //Pinch Gesture :
    UIPinchGestureRecognizer *pinchTouch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchTouch.delegate = self;
    [viewContainer addGestureRecognizer:pinchTouch];
    
    //Rotate Gesture
    imageView.userInteractionEnabled = YES;
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    rotateGesture.delegate = self;
    [viewContainer addGestureRecognizer:rotateGesture];
    
    centerX = imageView.center.x;
    centerY = imageView.center.y;
    
    //scrollView.pinchGestureRecognizer.delegate = self;
    [imageView release];
    

    // rect
    rectMain = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
//    rectMain.alpha = 0.5;
//    rectMain.backgroundColor = [UIColor lightGrayColor];
    rectMain.userInteractionEnabled = YES;
    [viewContainer addSubview:rectMain];
    
//    UIPanGestureRecognizer  *panGestureMainRect = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMainRect:)];
//    panGestureMainRect.delegate = self;
//    [rectMain addGestureRecognizer:panGestureMainRect];
    
    //add corner
    cornerTopLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-left.png"]];
    cornerTopRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-right.png"]];
    cornerBottomLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom-left.png"]];
    cornerBottomRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom-right.png"]];
    cornerBottomRight.userInteractionEnabled = YES;
    cornerBottomLeft.userInteractionEnabled = YES;
    cornerTopLeft.userInteractionEnabled = YES;
    cornerTopRight.userInteractionEnabled = YES;
    
//    [viewContainer addSubview:cornerTopRight];
//    [viewContainer addSubview:cornerTopLeft];
//    [viewContainer addSubview:cornerBottomLeft];
//    [viewContainer addSubview:cornerBottomRight];


    [self.view addSubview:cornerTopRight];
    [self.view addSubview:cornerTopLeft];
    [self.view addSubview:cornerBottomLeft];
    [self.view addSubview:cornerBottomRight];
    
    
    // prepare view resize ofr cropper
    
    viewResizeBottom = [[UIView alloc] init];
    viewResizeBottom.userInteractionEnabled = YES;
    
    viewResizeLeft = [[UIView alloc] init];
    viewResizeLeft.userInteractionEnabled = YES;
    viewResizeRight = [[UIView alloc] init];
    viewResizeRight.userInteractionEnabled = YES;
    viewResizeTop = [[UIView alloc] init];
    viewResizeTop.userInteractionEnabled = YES;
    
    //viewResizeBottom.backgroundColor = viewResizeLeft.backgroundColor = viewResizeRight.backgroundColor = viewResizeTop.backgroundColor = [UIColor redColor];
    
    [viewContainer addSubview:viewResizeBottom];
    [viewContainer addSubview:viewResizeLeft];
    [viewContainer addSubview:viewResizeRight];
    [viewContainer addSubview:viewResizeTop];
    
    //[self drawCropArea:CGRectMake(50, 50, 100, 100)];
//    [self drawCropArea:CGRectMake(50, 50, 220, 316)];
//    [imageView setFrame:CGRectMake(30, 30, 260,356)];
    
    // move imageview to center
    
    CGRect  centerRect = CGRectMake((320 - imageView.frame.size.width) / 2, (416 - imageView.frame.size.height) /2, imageView.frame.size.width, imageView.frame.size.height);
    [self drawCropArea:CGRectMake(centerRect.origin.x + centerRect.size.width/4 , centerRect.origin.y + centerRect.size.height / 4, centerRect.size.width /2, centerRect.size.height /2)];
    imageView.frame = centerRect;
    
    
    UIPanGestureRecognizer  *panGestureBottomRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCornerBottomRight:)];
    panGestureBottomRight.delegate = self;
    [cornerBottomRight addGestureRecognizer:panGestureBottomRight];
    
    UIPanGestureRecognizer  *panGestureBottomLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCornerBottomLeft:)];
    panGestureBottomLeft.delegate = self;
    [cornerBottomLeft addGestureRecognizer:panGestureBottomLeft];
    
    UIPanGestureRecognizer  *panGestureTopRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCornerTopRight:)];
    panGestureTopRight.delegate = self;
    [cornerTopRight addGestureRecognizer:panGestureTopRight];
    
    UIPanGestureRecognizer  *panGestureTopLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCornerTopLeft:)];
    panGestureTopLeft.delegate = self;
    [cornerTopLeft addGestureRecognizer:panGestureTopLeft];
    
    // pan for resize view
    //
    //
    UIPanGestureRecognizer  *panGestureTopResize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTopResize:)];
    panGestureTopResize.delegate = self;
    [viewResizeTop addGestureRecognizer:panGestureTopResize];
    
    UIPanGestureRecognizer  *panGestureBottomResize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveBottomResize:)];
    panGestureBottomResize.delegate = self;
    [viewResizeBottom addGestureRecognizer:panGestureBottomResize];
    
    UIPanGestureRecognizer  *panGestureLeftResize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeftResize:)];
    panGestureLeftResize.delegate = self;
    [viewResizeLeft addGestureRecognizer:panGestureLeftResize];
    
    UIPanGestureRecognizer  *panGestureRightResize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveRightResize:)];
    panGestureRightResize.delegate = self;
    [viewResizeRight addGestureRecognizer:panGestureRightResize];
    
    //add line 
    lineTopLeft = [[UIView alloc] initWithFrame:CGRectMake(rectMain.frame.size.width/3, 1, 1, rectMain.frame.size.height - 2)];
    lineTopLeft.backgroundColor = LINE_COLOR;
    
    lineTopRight = [[UIView alloc] initWithFrame:CGRectMake((rectMain.frame.size.width/3)*2, 1, 1, rectMain.frame.size.height -2)];
    lineTopRight.backgroundColor = LINE_COLOR;
    
    lineBottomLeft = [[UIView alloc] initWithFrame:CGRectMake(1, rectMain.frame.size.height/3, rectMain.frame.size.width -2, 1)];
    lineBottomLeft.backgroundColor = LINE_COLOR;
    
    lineBottomRight = [[UIView alloc] initWithFrame:CGRectMake(1, (rectMain.frame.size.height/3)*2, rectMain.frame.size.width - 2, 1)];
    lineBottomRight.backgroundColor = LINE_COLOR;
    
    lineBottomLeft.alpha = lineBottomRight.alpha = lineTopLeft.alpha = lineTopRight.alpha = 0.8f;
    
    [rectMain addSubview:lineTopLeft];
    [rectMain addSubview:lineTopRight];
    [rectMain addSubview:lineBottomLeft];
    [rectMain addSubview:lineBottomRight];
    
    //Add background
    bgTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, rectMain.frame.origin.y )];
    [bgTop setBackgroundColor:[UIColor blackColor]];
    [bgTop setAlpha:0.5];
    
    bgRight = [[UIView alloc] initWithFrame:CGRectMake(rectMain.frame.origin.x + rectMain.frame.size.width , rectMain.frame.origin.y, 320 - rectMain.frame.origin.x - rectMain.frame.size.width, rectMain.frame.size.height)];
    [bgRight setBackgroundColor:[UIColor blackColor]];
    [bgRight setAlpha:0.5];
    
    bgLeft = [[UIView alloc] initWithFrame:CGRectMake(0, rectMain.frame.origin.y, rectMain.frame.origin.x , rectMain.frame.size.height)];
    [bgLeft setBackgroundColor:[UIColor blackColor]];
    [bgLeft setAlpha:0.5];
    
    bgBottom = [[UIView alloc] initWithFrame:CGRectMake(0, rectMain.frame.origin.y + rectMain.frame.size.height , 320, 416 - rectMain.frame.origin.y - rectMain.frame.size.height)];
    [bgBottom setBackgroundColor:[UIColor blackColor]];
    [bgBottom setAlpha:0.5];
    
    [viewContainer addSubview:bgTop];
    [viewContainer addSubview:bgRight];
    [viewContainer addSubview:bgLeft];
    [viewContainer addSubview:bgBottom];
    
    imageOrigi = imageView.image;
    
    //bring tabbar to top
    
    [self.view bringSubviewToFront:toolbar];
    currOrientation = UIInterfaceOrientationPortrait;
}

- (void)viewDidUnload
{
    //[scrollView release];

//    [utBar release];
//    utBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark rotation handler
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    // redraw rect main
//    [self drawCropArea:rectMain.frame];
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // redraw rect main
    currOrientation = toInterfaceOrientation;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    
    // caculate scale for rect
    float scaleWidth;
    float scaleHeight;
    
    if (currOrientation == UIInterfaceOrientationLandscapeLeft) {
        // calculate position of image view
        imageView.frame = CGRectMake((480 - imageView.frame.size.width)/2, (256 - imageView.frame.size.height)/2, imageView.frame.size.width, imageView.frame.size.height);
        // current portrait
        scaleWidth = 320.0f / rectMain.frame.size.width;
        scaleHeight = 416.0f / rectMain.frame.size.height;
        rectMain.frame = CGRectMake(480.0f / (320.0f / rectMain.frame.origin.x), 256.0f/ (416.0f / rectMain.frame.origin.y), 480 / scaleWidth, 256 / scaleHeight);
    }
    else {
        // calculate position of image view
        imageView.frame = CGRectMake((320 - imageView.frame.size.width)/2, (416 - imageView.frame.size.height)/2, imageView.frame.size.width, imageView.frame.size.height);
        // current lanscape right
        scaleWidth = 480.0f / rectMain.frame.size.width;
        scaleHeight = 256.0f / rectMain.frame.size.height;
        rectMain.frame = CGRectMake(320.0f / (480.0f / rectMain.frame.origin.x), 416.0f/ (256.0f / rectMain.frame.origin.y), 320 / scaleWidth, 416 / scaleHeight);
    }
    // recalculate for frame
    
    [self drawCropArea:rectMain.frame];
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIImageView *imgView = (UIImageView*)[gestureRecognizer view];
    if (imgView.tag == 2) {
        return YES;
    }
    else {
        return NO;
    }
    
//    if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        
//        return YES;
//    }
    
    return NO;
}

#pragma mark - Draw line 

- (void)drawRect:(CGRect)rect {
    CGContextRef context    = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);

    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);


    CGContextMoveToPoint(context, 0,0); //start at this point

    CGContextAddLineToPoint(context, 20, 20); //draw to this point

    // and now draw the Path!
    CGContextStrokePath(context);
}

#pragma mark - Crop windown

-(void) drawCropArea:(CGRect) rect {
    // reset minScale
    
    minScale = 0;
    
    float x_ = 45 - 7; //30
    
    rectMain.frame = rect;
    rectMain.layer.borderWidth = 1;
    rectMain.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    //Update corner 
    cornerBottomLeft.frame = CGRectMake(rectMain.frame.origin.x - 7, rectMain.frame.origin.y + rectMain.frame.size.height - x_, 45, 45);
    cornerBottomRight.frame = CGRectMake(rectMain.frame.origin.x + rectMain.frame.size.width - x_, rectMain.frame.origin.y + rectMain.frame.size.height - x_, 45, 45);
    cornerTopLeft.frame = CGRectMake(rectMain.frame.origin.x - 7, rectMain.frame.origin.y - 7, 45, 45);
    cornerTopRight.frame = CGRectMake(rectMain.frame.origin.x + rectMain.frame.size.width - x_, rectMain.frame.origin.y - 7, 45, 45);
    
    //Update line 
    [lineTopLeft setFrame:CGRectMake(rectMain.frame.size.width/3, 1, 1, rectMain.frame.size.height - 2)];
    [lineTopRight setFrame:CGRectMake((rectMain.frame.size.width/3)*2, 1, 1, rectMain.frame.size.height -2)];
    [lineBottomLeft setFrame:CGRectMake(1, rectMain.frame.size.height/3, rectMain.frame.size.width -2, 1)];
    [lineBottomRight setFrame:CGRectMake(1, (rectMain.frame.size.height/3)*2, rectMain.frame.size.width - 2, 1)];
    
    // update viewResize
    viewResizeTop.frame = CGRectMake(rect.origin.x + rect.size.width /3, rect.origin.y, rect.size.width /3, rect.size.height/3);
    viewResizeBottom.frame = CGRectMake(rect.origin.x + rect.size.width /3 , rect.origin.y + rect.size.height /3 *2, rect.size.width /3, rect.size.height/3);
    viewResizeLeft.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height /3, rect.size.width / 3, rect.size.height / 3);
    viewResizeRight.frame = CGRectMake(rect.origin.x + rect.size.width / 3 *2, rect.origin.y + rect.size.height / 3, rect.size.width / 3, rect.size.height/3);
    
    //Update background
    if (currOrientation == UIInterfaceOrientationPortrait) {
        [bgTop setFrame:CGRectMake(0, 0, 320, rectMain.frame.origin.y)];
        [bgRight setFrame:CGRectMake(rectMain.frame.origin.x + rectMain.frame.size.width, rectMain.frame.origin.y, 320 - rectMain.frame.origin.x - rectMain.frame.size.width, rectMain.frame.size.height)];
        [bgLeft setFrame:CGRectMake(0, rectMain.frame.origin.y, rectMain.frame.origin.x, rectMain.frame.size.height)];
        [bgBottom setFrame:CGRectMake(0, rectMain.frame.origin.y + rectMain.frame.size.height, 320, 416 - rectMain.frame.origin.y - rectMain.frame.size.height)];
    }
    else {
        // must be landscape right
        [bgTop setFrame:CGRectMake(0, 0, 480, rectMain.frame.origin.y)];
        [bgRight setFrame:CGRectMake(rectMain.frame.origin.x + rectMain.frame.size.width, rectMain.frame.origin.y, 480 - rectMain.frame.origin.x - rectMain.frame.size.width, rectMain.frame.size.height)];
        [bgLeft setFrame:CGRectMake(0, rectMain.frame.origin.y, rectMain.frame.origin.x, rectMain.frame.size.height)];
        [bgBottom setFrame:CGRectMake(0, rectMain.frame.origin.y + rectMain.frame.size.height, 480, 256 - rectMain.frame.origin.y - rectMain.frame.size.height)];
    }
}

-(void)moveMainRect:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch Main Rect");
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	if([recognizer state] == UIGestureRecognizerStateBegan) {
		centerX = rectMain.center.x;
		centerY = rectMain.center.y;
	}
    
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX + newCenter.x, centerY + newCenter.y);
    [rectMain setCenter:newCenter];
    
    [self drawCropArea:rectMain.frame];
}

-(void)moveCornerBottomRight:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch Bottom Right");
    
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
		centerX = cornerBottomRight.center.x;
		centerY = cornerBottomRight.center.y;
	//}
    
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX + newCenter.x, centerY + newCenter.y);
    lastX = cornerBottomRight.frame.origin.x;
    lastY = cornerBottomRight.frame.origin.y;
    [cornerBottomRight setCenter:newCenter];
    
    lastX = cornerBottomRight.frame.origin.x - lastX;
    lastY = cornerBottomRight.frame.origin.y - lastY;
    
    ////NSLog(@"x = %d y= %d",lastX,lastY);
    ////NSLog(@"frame=> %@",NSStringFromCGRect(cornerBottomRight.frame));
    
    int width = rectMain.frame.size.width + lastX;
    int height = rectMain.frame.size.height + lastY;
    
    int x = rectMain.frame.origin.x;
    int y = rectMain.frame.origin.y;
    
    //Set move inside box : 
    if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
    }
    
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
    }
    
    //Set move outside image :
    
    //set move outside image
    if (![self checkCropViewInRightPosition]) {
        NSLog(@"can not move bottom right");
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(x,y, width, height);
    
    //CGRect newRect = CGRectMake(rectMain.frame.origin.x, rectMain.frame.origin.y, width, height);
    [self drawCropArea:newRect];
    
    lastFrame = newRect;
}

-(void)moveCornerBottomLeft:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch Botton left");
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
		centerX = cornerBottomLeft.center.x;
		centerY = cornerBottomLeft.center.y;
	//}
    
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    lastX = cornerBottomLeft.frame.origin.x;
    lastY = cornerBottomLeft.frame.origin.y;

    newCenter = CGPointMake(centerX + newCenter.x, centerY + newCenter.y);
    [cornerBottomLeft setCenter:newCenter];
    
    lastX = cornerBottomLeft.frame.origin.x - lastX;
    lastY = cornerBottomLeft.frame.origin.y - lastY;
    
    int width = rectMain.frame.size.width + (-1)*lastX;
    int height = rectMain.frame.size.height + lastY;
    
    if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
        lastX = 0;
    }
    
    
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
    }
    
    //Set move outside image :
    
    int x = rectMain.frame.origin.x + lastX;
    int y = rectMain.frame.origin.y;
    
    
    //set move outside image
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(x,y, width, height);
    
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    
    [self drawCropArea:newRect];
    lastFrame = newRect;
}

-(void)moveCornerTopRight:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch top right");
    
    //set move outside image
    
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
		centerX = cornerTopRight.center.x;
		centerY = cornerTopRight.center.y;
	//}
    
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    lastX = cornerTopRight.frame.origin.x;
    lastY = cornerTopRight.frame.origin.y;
    
    newCenter = CGPointMake(centerX + newCenter.x, centerY + newCenter.y);
    [cornerTopRight setCenter:newCenter];
    
    lastX = cornerTopRight.frame.origin.x - lastX;
    lastY = cornerTopRight.frame.origin.y - lastY;
    
    int width = rectMain.frame.size.width + lastX;
    int height = rectMain.frame.size.height + (-1)*lastY;
    
    if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
    }
    
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
        lastY = 0;
    }
    
    //Set move outside image :
    
    //int x = rectMain.frame.origin.x;
    int y = rectMain.frame.origin.y + lastY;
    
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(rectMain.frame.origin.x, y, width, height);
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    [self drawCropArea:newRect];
    lastFrame = newRect;
}

-(void)moveCornerTopLeft:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch top left");
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
		centerX = cornerTopLeft.center.x;
		centerY = cornerTopLeft.center.y;
	//}
    
    lastX = cornerTopLeft.frame.origin.x;
    lastY = cornerTopLeft.frame.origin.y;
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX + newCenter.x, centerY + newCenter.y);
    [cornerTopLeft setCenter:newCenter];
    
    lastX = cornerTopLeft.frame.origin.x - lastX;
    lastY = cornerTopLeft.frame.origin.y - lastY;
    
    int width = rectMain.frame.size.width + (-1)*lastX;
    int height = rectMain.frame.size.height + (-1)*lastY;
    
    if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
        lastX = 0;
    }
    
    
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
        lastY = 0;
    }
    
    //Set move outside image :
    
    int x = rectMain.frame.origin.x +lastX;
    int y = rectMain.frame.origin.y + lastY;
    
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(x, y, width, height);
    
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    [self drawCropArea:newRect];
    lastFrame = newRect;
}

#pragma mark gesture for pan view resize

-(void)moveTopResize:(UIPanGestureRecognizer*)recognizer {
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
    //centerX = cornerTopLeft.center.x;
    centerY = viewResizeTop.center.y;
	//}
    
    //lastX = cornerTopLeft.frame.origin.x;
    lastY = viewResizeTop.frame.origin.y;
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX , centerY + newCenter.y);
    [viewResizeTop setCenter:newCenter];
    
    //lastX = cornerTopLeft.frame.origin.x - lastX;
    lastY = viewResizeTop.frame.origin.y - lastY;
    
    //int width = rectMain.frame.size.width + (-1)*lastX;
    int height = rectMain.frame.size.height + (-1)*lastY;
    
    
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
        lastY = 0;
    }
    
    //Set move outside image :
    
    //int x = rectMain.frame.origin.x +lastX;
    int y = rectMain.frame.origin.y + lastY;
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(rectMain.frame.origin.x, y, rectMain.frame.size.width, height);
    
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    [self drawCropArea:newRect];
    lastFrame = newRect;
}

-(void)moveBottomResize:(UIPanGestureRecognizer*)recognizer {
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
    //centerX = cornerTopLeft.center.x;
    centerY = viewResizeBottom.center.y;
	//}
    
    //lastX = cornerTopLeft.frame.origin.x;
    lastY = viewResizeBottom.frame.origin.y;
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX , centerY + newCenter.y);
    [viewResizeBottom setCenter:newCenter];
    
    //lastX = cornerTopLeft.frame.origin.x - lastX;
    lastY = viewResizeBottom.frame.origin.y - lastY;
    
    //int width = rectMain.frame.size.width + (-1)*lastX;
    int height = rectMain.frame.size.height + lastY;
    
    
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
        lastY = 0;
    }
    
    //Set move outside image :
    
    //int x = rectMain.frame.origin.x +lastX;
    //int y = rectMain.frame.origin.y + lastY;
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(rectMain.frame.origin.x, rectMain.frame.origin.y, rectMain.frame.size.width, height);
    
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    [self drawCropArea:newRect];
    lastFrame = newRect;
}


-(void)moveLeftResize:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch top left");
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
    centerX = viewResizeLeft.center.x;
    //centerY = cornerTopLeft.center.y;
	//}
    
    lastX = viewResizeLeft.frame.origin.x;
    //lastY = cornerTopLeft.frame.origin.y;
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX + newCenter.x, centerY);
    [viewResizeLeft setCenter:newCenter];
    
    lastX = viewResizeLeft.frame.origin.x - lastX;
    //lastY = cornerTopLeft.frame.origin.y - lastY;
    
    int width = rectMain.frame.size.width + (-1)*lastX;
    //int height = rectMain.frame.size.height + (-1)*lastY;
    
    if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
        lastX = 0;
    }
    
    //Set move outside image :
    
    int x = rectMain.frame.origin.x +lastX;
    //int y = rectMain.frame.origin.y + lastY;
    
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(x, rectMain.frame.origin.y, width, rectMain.frame.size.height);
    
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    [self drawCropArea:newRect];
    lastFrame = newRect;
}

-(void)moveRightResize:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"touch top left");
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
	//if([recognizer state] == UIGestureRecognizerStateBegan) {
    centerX = viewResizeRight.center.x;
    //centerY = cornerTopLeft.center.y;
	//}
    
    lastX = viewResizeRight.frame.origin.x;
    //lastY = cornerTopLeft.frame.origin.y;
    [recognizer setTranslation:CGPointZero inView:viewContainer];
    
    newCenter = CGPointMake(centerX + newCenter.x, centerY);
    [viewResizeRight setCenter:newCenter];
    
    lastX = viewResizeRight.frame.origin.x - lastX;
    //lastY = cornerTopLeft.frame.origin.y - lastY;
    
    int width = rectMain.frame.size.width + lastX;
    //int height = rectMain.frame.size.height + (-1)*lastY;
    
    if (width < MIN_WIDTH) {
        width = MIN_WIDTH;
        lastX = 0;
    }
    
    
    //Set move outside image :
    
    //int x = rectMain.frame.origin.x +lastX;
    //int y = rectMain.frame.origin.y + lastY;
    
    
    if (![self checkCropViewInRightPosition]) {
        [self drawCropArea:lastFrame];
        return;
    }
    
    CGRect newRect = CGRectMake(rectMain.frame.origin.x, rectMain.frame.origin.y, width, rectMain.frame.size.height);
    
    //NSLog(@"=> %@",NSStringFromCGRect(newRect));
    [self drawCropArea:newRect];
    lastFrame = newRect;
}
#pragma mark - Gesture 

-(void)handlePanGesture:(UIPanGestureRecognizer*)recognizer {
    NSLog(@"moveImageView");
    
    CGPoint newCenter = [recognizer translationInView:viewContainer];
    
    centerX = imageView.center.x;
    centerY = imageView.center.y;
    [recognizer setTranslation:CGPointZero inView:viewContainer];

    
    newCenter = CGPointMake(centerX + newCenter.x, centerY + newCenter.y);
    [imageView setCenter:newCenter];
    
    //Set outside of image with crop windown 
//    
    if (![self checkCropViewInRightPosition]) {
        if (lastCenter.x == 0 && lastCenter.y == 0) {
            return;
        }
        [imageView setCenter:lastCenter];
        return;
    }
    
    minScale = 0;
    lastCenter = newCenter;
}

-(void)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateChanged && recognizer.state != UIGestureRecognizerStateEnded)
        return;

    NSLog(@"lastScale = %f",lastScale);
    NSLog(@"pinchImage scale = %f",scale);
    NSLog(@"pinchImage recognizer = %f",recognizer.scale);
    //NSLog(@"min zoom = %f",scrollView.minimumZoomScale);
     
    //Set zoom in not small better size cropview : 
    
    float oldScale = scale;
    float oldLastScale = lastScale;
    scale += recognizer.scale - lastScale;
    lastScale = recognizer.scale;
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        lastScale = 1.0;
    }

//
//    // test new transform
//    
    
    CGAffineTransform newTransform = CGAffineTransformMakeScale( scale, scale);
    imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(currDegree), newTransform);
    
    
    if (![self checkCropViewInRightPosition]) {
        // delay for 1 sec
        NSLog(@"could not resize moew");
        CGAffineTransform newTransform = CGAffineTransformMakeScale( oldScale   , oldScale);
        imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(currDegree), newTransform);
        scale = oldScale;
        lastScale = oldLastScale;
        //[imgView removeFromSuperview];
        //sleep(1);
        return;
    }
    //[imgView removeFromSuperview];
}


-(void)handleRotateGesture:(UIRotationGestureRecognizer *) recognizer {
    
    CGFloat rotation = [recognizer rotation];
    
//    if (![self checkCropViewInRightPosition]) {
//        currDegree = lastDegree;
//        return;
//    }
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotation + currDegree);
    imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale( scale, scale),transform);
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        currDegree += rotation;
    }
    
    imageView.layer.borderWidth = 3;
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    NSLog(@"degree = %f",currDegree);
    if (![self checkCropViewInRightPosition]) {
        NSLog(@"not allow to rotate");
        CGAffineTransform transform = CGAffineTransformMakeRotation(lastDegree);
        imageView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale( scale, scale),transform);
        recognizer.rotation = lastDegree;
        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {

            currDegree = lastDegree;
        }
        return;
    }

    lastDegree = rotation;
    NSLog(@"Last degree = %.3f",lastDegree);
}

#pragma mark - Function private

//This function performs the actual cropping, given a rectangle to serve as the bounds.
-(UIImage*) imageFromView:(UIImage*) inImage andRect:(CGRect*) rect
{
    //NSLog(@"=> frame %@=",NSStringFromCGRect(*rect));
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, inImage.size.width, inImage.size.height)];
    rotatedViewBox.transform = CGAffineTransformMakeRotation(currDegree);
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0f, rotatedSize.height / 2.0f);
    CGContextRotateCTM(bitmap, currDegree);
    CGContextScaleCTM(bitmap, 1.0f, -1.0f);
    CGContextDrawImage(bitmap, CGRectMake(-inImage.size.width / 2.0f,
                                          -inImage.size.height / 2.0f,
                                          inImage.size.width,
                                          inImage.size.height),inImage.CGImage);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGImageRef cr = CGImageCreateWithImageInRect(resultImage.CGImage, *rect);
    UIImage* cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);

    
    UIGraphicsEndImageContext();
    
    
    return cropped;
}

/****** UIScrollView delegate for zooming **********/
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // turn off auto zoom
    return nil;
}
/**************************************************/

#pragma mark - Action button 

-(IBAction) doneEditing
{
    //Calculate the required area from the scrollview
    CGRect visibleRect;
    float _scale = 1.0f/scale;
    visibleRect.origin.x = ( rectMain.frame.origin.x - imageView.frame.origin.x) * _scale;
    visibleRect.origin.y = ( rectMain.frame.origin.y - imageView.frame.origin.y) * _scale;
//    visibleRect.size.width = (scrollView.bounds.size.width * _scale;
//    visibleRect.size.height = (scrollView.bounds.size.height * _scale;
    visibleRect.size.width = rectMain.frame.size.width * _scale;
    visibleRect.size.height = rectMain.frame.size.height * _scale;

        
    FinalOutputView* outputView = [[FinalOutputView alloc] initWithNibName:@"FinalOutputView" bundle:[NSBundle mainBundle]];
    
    
    outputView.image = [self imageFromView:[UIImage imageNamed:@"image.png"] andRect:&visibleRect];
    
    //outputView.image = [self cropImage];

    [self presentModalViewController:outputView animated:YES];
    [outputView release];
}

-(IBAction) doCancel {
    
}

#pragma mark - Function Crop image 

-(UIImage*)cropImage {
    
    //Way 1 :
    //NSLog(@"imageView frame size = %@",NSStringFromCGSize(imageView.frame.size));
    //NSLog(@"imageView bounds size = %@",NSStringFromCGSize(imageView.bounds.size));
    //NSLog(@"imageView bounds point = %@",NSStringFromCGPoint(imageView.bounds.origin));
    
    //Get value scale :
    float scale_X = imageOrigi.size.width/(imageView.bounds.size.width/2);
    float scale_Y = imageOrigi.size.height/(imageView.bounds.size.height/2);

    
    float scale_X1 = imageOrigi.size.width/(imageView.frame.size.width);
    float scale_Y1 = imageOrigi.size.height/(imageView.frame.size.height);
    
    //Get frame crop 320x416 with 640x960 : 
    CGRect frameCrop = CGRectMake((rectMain.frame.origin.x - imageView.frame.origin.x)*scale_X, (rectMain.frame.origin.y - imageView.frame.origin.y)*scale_Y, rectMain.frame.size.width*scale_X1, rectMain.frame.size.height*scale_Y1);
    NSLog(@"frameCrop frame = %@",NSStringFromCGRect(frameCrop));
    
    //Rotate UIImage with degree 
    UIImage *imgSave = [imageView.image imageRotatedByRadians:currDegree];
    
    //Get UIImage from frame 
    CGImageRef imageRef = CGImageCreateWithImageInRect([imgSave CGImage],CGRectMake(frameCrop.origin.x, frameCrop.origin.y, frameCrop.size.width, frameCrop.size.height)); //frameCrop
    
    //Log :
    NSLog(@"imageView frame = %@",NSStringFromCGRect(imageView.frame));
    NSLog(@"rectMain frame = %@",NSStringFromCGRect(rectMain.frame));
    NSLog(@"frameCrop frame = %@",NSStringFromCGRect(frameCrop));
    NSLog(@"================================= \n");
    
    //Convert CGImage to UIImage : 
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    
    return croppedImage;
}

-(BOOL) checkPositionWithTopLeft:(CGPoint)_pointTopLeft withTopRight:(CGPoint)_pointTopRight withBottomLeft:(CGPoint)_pointBottomLeft withBottomRight:(CGPoint)_pointBottomRight {

    BOOL result = [self checkPointColorForDict:[viewContainer colorOfPoint:_pointTopLeft]] & [self checkPointColorForDict:[viewContainer colorOfPoint:_pointTopRight]] & [self checkPointColorForDict:[viewContainer colorOfPoint:_pointBottomLeft]] & [self checkPointColorForDict:[viewContainer colorOfPoint:_pointBottomRight]];
    
    ////NSLog(@"result = %@", (result)?@"YES":@"NO");
    return result;
}

-(BOOL) checkCropViewInRightPosition {
    
    // transition in
//    CGPoint pointTopLeft = CGPointMake(cornerTopLeft.frame.origin.x-1, cornerTopLeft.frame.origin.y-1);
//    CGPoint pointTopRight = CGPointMake(cornerTopRight.frame.origin.x + cornerTopRight.frame.size.width + 1, cornerTopRight.frame.origin.y -1);
//    CGPoint pointBottomLeft = CGPointMake(cornerBottomLeft.frame.origin.x +1, cornerBottomLeft.frame.origin.y + cornerBottomLeft.frame.size.height +1);
//    CGPoint pointBottomRight = CGPointMake(cornerBottomRight.frame.origin.x + cornerBottomRight.frame.size.width +1, cornerBottomRight.frame.origin.y + cornerBottomRight.frame.size.height + 1);
    
    
    BOOL result = [self checkPointColorForDict:[viewContainer colorOfPoint:pointTopLeft]] & [self checkPointColorForDict:[viewContainer colorOfPoint:pointTopRight]] & [self checkPointColorForDict:[viewContainer colorOfPoint:pointBottomLeft]] & [self checkPointColorForDict:[viewContainer colorOfPoint:pointBottomRight]];
    
    ////NSLog(@"result = %@", (result)?@"YES":@"NO");
    return result;
}

-(BOOL) checkPointColorForDict:(NSDictionary*) dict {
    if ([[dict objectForKey:@"red"] intValue] == 0 && [[dict objectForKey:@"green"] intValue] == 0 && [[dict objectForKey:@"blue"] intValue] == 0 && [[dict objectForKey:@"a"] intValue] == 255) {
        return NO;
        }
    return YES;
}

@end
