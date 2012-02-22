//
//  RHLayoutScrollView.m
//  LeftMiddleRight
//
//  Created by Richard Heard on 24/01/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "RHLayoutScrollView.h"

@implementation RHLayoutScrollView

@synthesize orderedViews=_orderedViews;
@synthesize scrollView=_scrollView;
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        _scrollView.scrollsToTop = NO; //we dont want to steal this from our friends
    }
    return self;
}

#define RN(x) [x release]; x = nil;

- (void)dealloc{
    RN(_scrollView);
    RN(_orderedViews);
    
    [super dealloc];
}

-(void)setOrderedViews:(NSArray *)orderedViews{
    if (_orderedViews != orderedViews){
        [_orderedViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_orderedViews release];
        _orderedViews = [orderedViews retain];
        
        for (UIView *view in _orderedViews) {
            [_scrollView addSubview:view];
        }
        
        [self layoutIfNeeded];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //keep them the same, always
    if (!CGRectEqualToRect(self.bounds, _scrollView.frame)){
        _scrollView.frame = self.bounds;
    }
    
    //layout our ordered views based on their current dimensions paged horizontally
    CGFloat xOffset = 0.0f;
    for (UIView *view in _orderedViews) {
        CGRect frame = view.frame;
        frame.origin.x = xOffset;
        frame.origin.y = 0.0f;
        view.frame = frame;
        xOffset += frame.size.width;
    }
    
    _scrollView.contentSize = CGSizeMake(xOffset, self.bounds.size.height);    
}


-(NSUInteger)currentIndex{
    return MIN(roundf(_scrollView.contentOffset.x / _scrollView.bounds.size.width), [_orderedViews count]);
}

-(void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated{
    if (currentIndex >= [_orderedViews count]) currentIndex = [_orderedViews count];
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width * currentIndex, 0.0f) animated:animated]; 
    
    //force a delegate call if not animated
    [self scrollViewDidScroll:_scrollView];
}

-(void)setCurrentIndex:(NSUInteger)currentIndex{
    [self setCurrentIndex:currentIndex animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //notify based on scroll update
    if ([_delegate respondsToSelector:@selector(scrollView:updateForPercentagePosition:)]){
        CGFloat position = scrollView.contentOffset.x;
        CGFloat total = scrollView.contentSize.width - scrollView.bounds.size.width;
        [_delegate scrollView:self updateForPercentagePosition:position/total];
    }
    
    //TODO: update based on page index change
    
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    //fwd to the current view
    return NO;
}

@end
