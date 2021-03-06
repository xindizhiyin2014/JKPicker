//
//  MXSCycleScrollView.h
//  xuexin
//  e-mail:rbyyy924805@163.com
//  Created by renbing on 3/7/14.
//  Copyright (c) 2014 renbing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MXSCycleScrollViewDelegate;
@protocol MXSCycleScrollViewDatasource;

typedef enum : NSUInteger {
    DateTypeYear,
    DateTypeMonth,
    DateTypeDay,
    DateTypeHour,
    DateTypeMinute,
    DateTypeSecond,
    DateTypeWeekDay,
    DateTypeDate,
} DateType;

@interface MXSCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic, assign) DateType dateType;

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<MXSCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:) id<MXSCycleScrollViewDelegate> delegate;

- (void)setCurrentSelectPage:(NSInteger)selectPage; //设置初始化页数
- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;

@end

@protocol MXSCycleScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(MXSCycleScrollView *)csView atIndex:(NSInteger)index;
- (void)scrollviewDidChangeNumber:(MXSCycleScrollView *)scrollView;

@end

@protocol MXSCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView;
- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView*)scrollView;

@end
