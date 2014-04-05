//
//  ViewController.h
//  MaskedExample
//
//  Created by Kevin Donnelly on 4/1/14.
//
//

#import <UIKit/UIKit.h>
#import "KVNMaskedPageControl.h"


@interface ViewController : UIViewController <UIScrollViewDelegate, KVNMaskedPageControlDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) KVNMaskedPageControl *pageControl;
@property (weak, nonatomic) IBOutlet KVNMaskedPageControl *nibPageControl;

@end
