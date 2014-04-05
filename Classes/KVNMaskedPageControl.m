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


#import "KVNMaskedPageControl.h"

@interface KVNMaskedPageControl()
@property (nonatomic, weak) UIPageControl *primaryPageControl;
@property (nonatomic, weak) UIPageControl *secondaryPageControl;
@property NSInteger currentMaskPage;
@property CGFloat lastMaskedPercentage;

@end

@implementation KVNMaskedPageControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
	
    [self setupPageControls];
	return self;
}

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	[self setupPageControls];
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setupPageControls];
}

- (void)setupPageControls {
	if (!self.primaryPageControl) {
		UIPageControl *primaryPageControl = [[UIPageControl alloc] init];
        [primaryPageControl setUserInteractionEnabled:NO];
		[self addSubview:primaryPageControl];
		self.primaryPageControl = primaryPageControl;
		
		UIPageControl *secondaryPageControl = [[UIPageControl alloc] init];
        [secondaryPageControl setUserInteractionEnabled:NO];
		[self addSubview:secondaryPageControl];
		self.secondaryPageControl = secondaryPageControl;
		
		[self syncPageControl];
        self.currentMaskPage = 0;
        [self refreshCurrentPageColors];
        self.lastMaskedPercentage = 0.0;
	}
}

- (void)syncPageControl {
	self.secondaryPageControl.currentPage = self.primaryPageControl.currentPage = self.currentPage;
	self.secondaryPageControl.numberOfPages = self.primaryPageControl.numberOfPages = self.numberOfPages;
	self.secondaryPageControl.defersCurrentPageDisplay = self.primaryPageControl.defersCurrentPageDisplay = self.defersCurrentPageDisplay;
	self.secondaryPageControl.hidesForSinglePage = self.primaryPageControl.hidesForSinglePage = self.hidesForSinglePage;
	
    self.secondaryPageControl.opaque = self.primaryPageControl.opaque = self.opaque;
	self.secondaryPageControl.backgroundColor = self.primaryPageControl.backgroundColor = self.backgroundColor;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.secondaryPageControl.frame = self.bounds;
	self.primaryPageControl.frame = self.bounds;
    
    [self updateMaskWithPercentage:self.lastMaskedPercentage];
}

#pragma mark - Synthesis Overriding

- (void)setCurrentPage:(NSInteger)currentPage {
	_currentPage = currentPage;
	
	[self syncPageControl];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
	_numberOfPages = MAX(0, numberOfPages);
	self.currentPage = MIN(MAX(0, self.currentPage), numberOfPages);
    
	[self syncPageControl];
	
	self.bounds = (CGRect){.size = [self sizeForNumberOfPages:numberOfPages]};
	self.hidden = self.hidesForSinglePage && self.numberOfPages < 2;
}

- (void)setDefersCurrentPageDisplay:(BOOL)defersCurrentPageDisplay {
	_defersCurrentPageDisplay = defersCurrentPageDisplay;
	
	[self syncPageControl];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
	_hidesForSinglePage = hidesForSinglePage;
	
	[self syncPageControl];
}

- (void)setDataSource:(id<KVNMaskedPageControlDataSource>)dataSource {
    _dataSource = dataSource;
    [self refreshCurrentPageColors];
}

#pragma mark - UIPageControl Methods

- (void)updateCurrentPageDisplay {
	[self.primaryPageControl updateCurrentPageDisplay];
	[self.secondaryPageControl updateCurrentPageDisplay];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
	return [self.primaryPageControl sizeForNumberOfPages:pageCount];
}

#pragma mark - Masking

- (void)refreshCurrentPageColors {
    if (!self.dataSource) {
        return;
    }
    
    UIColor *primaryCurrentIndicatorTint = [self.dataSource pageControl:self currentPageIndicatorTintColorForIndex:self.currentMaskPage];
    UIColor *primaryIndicatorTint = [self.dataSource pageControl:self pageIndicatorTintColorForIndex:self.currentMaskPage];
    UIColor *secondaryCurrentIndicatorTint = [self.dataSource pageControl:self currentPageIndicatorTintColorForIndex:self.currentMaskPage+1];
    UIColor *secondaryIndicatorTint = [self.dataSource pageControl:self pageIndicatorTintColorForIndex:self.currentMaskPage+1];
    
    [self.primaryPageControl setCurrentPageIndicatorTintColor:primaryCurrentIndicatorTint];
    [self.primaryPageControl setPageIndicatorTintColor:primaryIndicatorTint];
    [self.secondaryPageControl setCurrentPageIndicatorTintColor:secondaryCurrentIndicatorTint];
    [self.secondaryPageControl setPageIndicatorTintColor:secondaryIndicatorTint];
}

- (void)maskEventWithOffset:(CGFloat)offset frame:(CGRect)frame {
    int page = floorf(offset / CGRectGetWidth(frame));
    
    CGFloat offsetRemainder = offset - page * CGRectGetWidth(frame);
    CGFloat percentage = MIN(CGRectGetWidth(frame), MAX(0, offsetRemainder - CGRectGetMinX(self.frame))) / CGRectGetWidth(self.bounds);
    
    if (self.currentMaskPage != page) {
        self.currentMaskPage = page;
        [self refreshCurrentPageColors];
    }
    
    [self updateMaskWithPercentage:percentage];
}


- (void)updateMaskWithPercentage:(CGFloat)percentage {
    percentage = MIN(MAX(0, percentage), 1);
    
	if (!self.layer.mask) {
		self.primaryPageControl.layer.mask = [CALayer layer];
		self.primaryPageControl.layer.mask.backgroundColor = [[UIColor blackColor] CGColor];
		
		self.secondaryPageControl.layer.mask = [CALayer layer];
		self.secondaryPageControl.layer.mask.backgroundColor = [[UIColor blackColor] CGColor];
	}
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES]; // Removed implicit animation that was causing delays
	CGRect secondaryMaskFrame = self.secondaryPageControl.layer.bounds;
	secondaryMaskFrame.origin.x = CGRectGetWidth(secondaryMaskFrame) * (1 - percentage);
	secondaryMaskFrame.size.width = CGRectGetWidth(secondaryMaskFrame) * percentage;
	self.secondaryPageControl.layer.mask.frame = secondaryMaskFrame;
	
	CGRect pageControlFrame = self.primaryPageControl.layer.bounds;
    pageControlFrame.origin.x = 0;
	pageControlFrame.size.width = CGRectGetWidth(pageControlFrame) * (1 - percentage);
	self.primaryPageControl.layer.mask.frame = pageControlFrame;
	[CATransaction commit];
    
    self.lastMaskedPercentage = percentage;
}

#pragma mark - UIControl Method

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *tap = [touches anyObject];
	CGPoint location = [tap locationInView:self];
	
	if (location.x < CGRectGetMidX(self.bounds)) {
		self.currentPage = MAX(0, self.currentPage - 1);
	} else {
		self.currentPage = MIN(self.currentPage + 1, self.numberOfPages - 1);
	}
	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
