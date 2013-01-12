

#import <UIKit/UIKit.h>


@interface FinalOutputView : UIViewController {
    
    IBOutlet UIImageView *imageView;
    UIImage* image;
}

@property (nonatomic, retain) UIImage* image;

- (IBAction)doBack:(id)sender;
@end
