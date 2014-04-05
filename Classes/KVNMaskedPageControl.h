//Copyright (c) 2014 Kevin <kevin@kvnd.me>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import <UIKit/UIKit.h>


@protocol KVNMaskedPageControlDataSource;
@interface KVNMaskedPageControl : UIControl

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) BOOL hidesForSinglePage;
@property (nonatomic) BOOL defersCurrentPageDisplay;
@property (nonatomic, weak) IBOutlet
id<KVNMaskedPageControlDataSource> dataSource;

- (void)updateCurrentPageDisplay;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

/**
 *  Forces data source methods to be called for current and next pages.
 */
- (void)refreshCurrentPageColors;

/**
 *  Updates mask between the two color sets for the page control. Usually called from `UIScrollViewDelegate` didScroll events.
 *
 *  @param offset The offset to calculate the mask from. Used to calculate the intersection with the KVNMaskedPageControl's frame and percentage the mask should cover/uncover.
 *  @param frame  The frame for the view the offset is based off of. Used to calculate what page the scroll view is on, but that calculation is used internally only. Does not update the `currentPage`
 *
 *  @discussion If the above seems a little unintuitive: as long as the `UIScrollView` and the `KVNMaskedPageControl` share a superview, just sending `scrollView.contentOffset.x` and `scrollView.frame` will be sufficient. If they don't, calculating what the scrollview values would be in superview of the `KVNMaskedPageControl` should also work.
 */
- (void)maskEventWithOffset:(CGFloat)offset frame:(CGRect)frame;

/**
 *  Calculates and applies the frames of the masking layers of the two internal UIPageControls that make up this component, creating the masking effect.
 *
 *  @param percentage The percentage of the next page color to be revealed.
 *
 *  @discussion It is unadvised to call this method directly, doing so will bypass the data source methods and colors will be ones last set. It is public to allow subclasses to take advantage of it.
 */
- (void)updateMaskWithPercentage:(CGFloat)percentage;
@end


@protocol KVNMaskedPageControlDataSource <NSObject>

@required

/**
 *  @param control The control requesting the color
 *  @param index   The page index of the requested color
 *
 *  @discussion The implementation of this method should be able to handle indices ranging from -1 to N+1, to account for over-scrolling and bouncing of a UIScrollView. Returning nil will just set the default UIPageControl color or whatever is defined through UIAppearance
 *
 *  @return Page Control Indicator Tint UIColor or nil
 */
- (UIColor *)pageControl:(KVNMaskedPageControl *)control pageIndicatorTintColorForIndex:(NSInteger)index;

/**
 *  @param control The control requesting the color
 *  @param index   The page index the color of the requested color
 *
 *  @discussion The implementation of this method should be able to handle indices ranging from -1 to N+1, to account for over-scrolling and bouncing of a UIScrollView. Returning nil will just set the default UIPageControl color or whatever is defined through UIAppearance
 *
 *  @return Page Control Indicator Tint UIColor or nil
 */
- (UIColor *)pageControl:(KVNMaskedPageControl *)control currentPageIndicatorTintColorForIndex:(NSInteger)index;
@end