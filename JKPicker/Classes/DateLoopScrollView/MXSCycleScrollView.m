//
//  MXSCycleScrollView.m
//  xuexin
//  e-mail:rbyyy924805@163.com
//  Created by renbing on 3/7/14.
//  Copyright (c) 2014 renbing. All rights reserved.
//

#import "MXSCycleScrollView.h"
#import "JKDateCommon.h"
@implementation MXSCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.bounds.size.height/5)*7);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(0, (self.bounds.size.height/5));
        
        [self addSubview:_scrollView];
    }
    return self;
}

//设置标识
- (void)setDateType:(DateType)dateType{
    _dateType = dateType;
}

//设置初始化页数
- (void)setCurrentSelectPage:(NSInteger)selectPage
{
    _curPage = selectPage;
}

- (void)setDataource:(id<MXSCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages:self];
    if (_totalPages == 0) {
        return;
    }
    [self loadData];
}

- (void)loadData
{
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 7; i++) {
        UIView *v = [_curViews objectAtIndex:i];
//        v.userInteractionEnabled = YES;
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                    action:@selector(handleTap:)];
//        [v addGestureRecognizer:singleTap];
        v.frame = CGRectOffset(v.frame, 0, v.frame.size.height * i );
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake( 0, (self.bounds.size.height/5) )];
}

- (void)getDisplayImagesWithCurpage:(NSInteger)page {
    NSInteger pre1 =0;
    NSInteger pre2 = 0;
    NSInteger pre3 = 0;
    NSInteger pre4 = 0;
    NSInteger pre5 = 0;
    NSInteger pre = 0;
    NSInteger last = 0;
//    if (_totalPages ==1) {
////        pre1 = [self validPageValue:_curPage-2];
////        pre2 = [self validPageValue:_curPage-1];
////        pre3 = [self validPageValue:_curPage];
////        pre4 = [self validPageValue:_curPage+1];
////        pre5 = [self validPageValue:_curPage+2];
////        pre = [self validPageValue:_curPage+3];
////        last = [self validPageValue:_curPage+4];
//        
//    }else{
        pre1 = [self validPageValue:_curPage-1];
        pre2 = [self validPageValue:_curPage];
        pre3 = [self validPageValue:_curPage+1];
        pre4 = [self validPageValue:_curPage+2];
        pre5 = [self validPageValue:_curPage+3];
        pre = [self validPageValue:_curPage+4];
        last = [self validPageValue:_curPage+5];
    
//    }
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre1 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre2 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre3 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre4 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre5 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:last andScrollView:self]];
    
}

- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value == -1 ) value = _totalPages - 1;
    if(value == _totalPages+1) value = 1;
    if (value == _totalPages+2) value = 2;
    if(value == _totalPages+3) value = 3;
    if (value == _totalPages+4) value = 4;
    if(value == _totalPages) value = 0;
    
    
    if (value >= _totalPages) {
       // value -= _totalPages;
        value = value%_totalPages;
    }else if (value < 0) {
        value += _totalPages;
    }
    
    return value;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 7; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                        action:@selector(handleTap:)];
//            [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, 0, v.frame.size.height * i);
            [_scrollView addSubview:v];
        }
    }
}

- (void)setAfterScrollShowView:(UIScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
   
   
    CGFloat fontSize = 13.0;
    UIColor *textColor = date_ColorWithRGB(186.0, 186.0, 186.0);
    
    UILabel *oneLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [oneLabel setTextColor:textColor];

    UILabel *twoLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [twoLabel setTextColor:textColor];

    UILabel *currentLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:15]];
    [currentLabel setTextColor:[UIColor blackColor]];
    
    UILabel *threeLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [threeLabel setTextColor:textColor];
    
    UILabel *fourLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [fourLabel setTextColor:textColor];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int y = aScrollView.contentOffset.y;
    int h = floorf(self.bounds.size.height/5);
    int page = aScrollView.contentOffset.y/h;
    
    if (y>2*(self.bounds.size.height/5)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
        
    }
    if (y<=0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
        
    }
   
    
//        //往下翻一张
//        if(y >= (4*self.frame.size.width)) {
//            _curPage = [self validPageValue:_curPage+1];
//            [self loadData];
//        }
    //
    //    //往上翻
    //    if(x <= 0) {
    //        
    //    }
    if (page>1 || page <=0) {
        
        [self setAfterScrollShowView:aScrollView andCurrentPage:1];
    }
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber:)]) {
        [_delegate scrollviewDidChangeNumber:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber:)]) {
        [_delegate scrollviewDidChangeNumber:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
    UILabel *currentLabel = [_curViews objectAtIndex:3];
    currentLabel.textColor = [UIColor blackColor];
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber:)]) {
        [_delegate scrollviewDidChangeNumber:self];
    }
}

- (void)dealloc{
    self.delegate = nil;
    self.datasource = nil;
    _scrollView.delegate = nil;
}

@end
