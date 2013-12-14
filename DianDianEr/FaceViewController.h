

#import <UIKit/UIKit.h>

@class ChartViewController;


@interface FaceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
	NSMutableArray            *_phraseArray;
	ChartViewController        *_chartViewController;
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *faceScrollView;
@property (nonatomic, retain) NSMutableArray            *phraseArray;
@property (nonatomic, retain) ChartViewController        *chartViewController;

-(IBAction)dismissMyselfAction:(id)sender;
- (void)showEmojiView;
@end
