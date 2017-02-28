//
//  JKDatePicker.m
//
//
//  Created by Jack on 15/4/30.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "JKDatePicker.h"
#import "MXSCycleScrollView.h"


#define TOOLBAR_HEIGHT 40
#define TITLEBAR_HEIGHT 35
#define SCROLLVIEW_HEIGHT 216
#define kLINECOLOR date_ColorWithRGB(220, 220, 220);
@interface JKDatePicker ()
<UIGestureRecognizerDelegate,MXSCycleScrollViewDelegate,MXSCycleScrollViewDatasource>
{
    UILabel          *_titleLabel;
    UIView          *_toolBar;
    UIButton        *_leftBtn;
    UIButton        *_rightBtn;
    
    UIView          *_pickerBgView;
    
    UIView          *_datePicker;
    NSCalendar      *_calendar;
    
    JKDatePickerMode _datePickerMode;

    NSDateFormatter *_dateFormatter;
    
    MXSCycleScrollView          *yearScrollView;//年份滚动视图
    MXSCycleScrollView          *monthScrollView;//月份滚动视图
    MXSCycleScrollView          *dayScrollView;//日滚动视图
    MXSCycleScrollView          *hourScrollView;//时滚动视图
    MXSCycleScrollView          *minuteScrollView;//分滚动视图
    MXSCycleScrollView          *secondScrollView;//秒滚动视图
    MXSCycleScrollView          *weekDayScrollView;//周滚动视图
    MXSCycleScrollView          *dateScrollView;//年月日滚动视图
    
    
    NSInteger _yearInt,_monthInt,_dayInt,_hourInt,_minuteInt,_secondInt,_weekInt,_dateInt,_startYearInt,_endYearInt;
}

@property(strong , nonatomic)UIView *fatherView;

@end

@implementation JKDatePicker
static JKDatePicker *jkDatePicker = nil;
static int cellNum =0;

+ (id)showPickerInView:(UIView *)view window:(UIWindow *)targetWindow{
    jkDatePicker = nil;
    
    if (jkDatePicker == nil) {
        CGFloat w = date_kScreenWidth;
        CGFloat h = date_kScreenHeight;
        CGFloat x = 0;
        CGFloat y = 0;
        
        jkDatePicker = [[JKDatePicker alloc] initWithFrame:CGRectMake(x, y, w, h)];
        jkDatePicker.backgroundColor = date_ColorWithRGBA(0, 0, 0, 0.25);
        jkDatePicker.fatherView = view;
        [view addSubview:jkDatePicker];
        [view bringSubviewToFront:jkDatePicker];
    }
    [targetWindow endEditing:YES];
    return jkDatePicker;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initCalendar];

        CGFloat w = self.frame.size.width;
        //CGFloat h = SCROLLVIEW_HEIGHT+TOOLBAR_HEIGHT+TITLEBAR_HEIGHT;//216:pickerView 高, TOOLBAR_HEIGHT：toolbar高
        
        //取消时间空间顶部时间显示栏 - UI负责人要求与安卓统一，取消了TITLEBAR--20161207
        CGFloat h = SCROLLVIEW_HEIGHT+TOOLBAR_HEIGHT;

        CGFloat x = 0;
        CGFloat y = self.frame.size.height;
        _pickerBgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _pickerBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerBgView];
        
        //取消时间空间顶部时间显示栏 - UI负责人要求与安卓统一，所以取消--20161207
        //[self initTitleBar];
        
        [self initToolBar];
        [self initPickerView];
        
        
        [UIView animateWithDuration:0.35 animations:^{
            CGRect frame = _pickerBgView.frame;
            if (frame.origin.y == self.frame.size.height) {
                frame.origin.y -= frame.size.height;
                _pickerBgView.frame = frame;
            }
        } completion:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHidden)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}


/**
 设置标题栏 - 20161207要求与安卓统一，取消了标题栏，这里未调用
 */
-(void)initTitleBar{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , _pickerBgView.frame.size.width, TITLEBAR_HEIGHT-1)];
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = date_kNavBarColor;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, TITLEBAR_HEIGHT-1, _pickerBgView.frame.size.width, 1)];
    lineView.backgroundColor = kLINECOLOR;
    [_pickerBgView addSubview:lineView];
    [_pickerBgView addSubview:_titleLabel];
    

}


/**
 设置工具栏（确认和取消按钮）
 */
- (void)initToolBar{
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, SCROLLVIEW_HEIGHT, _pickerBgView.frame.size.width, TOOLBAR_HEIGHT)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [_pickerBgView addSubview:_toolBar];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(0, 0, _pickerBgView.frame.size.width/2, _toolBar.frame.size.height);
    _leftBtn.backgroundColor = [UIColor clearColor];
    [_leftBtn setTitleColor:date_ColorWithRGB(150, 150, 150) forState:UIControlStateNormal];
    _leftBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_leftBtn];

    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(_pickerBgView.frame.size.width/2, 0, _pickerBgView.frame.size.width/2, _toolBar.frame.size.height);
    [_rightBtn setTitleColor:date_kNavBarColor forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [_rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    _rightBtn.backgroundColor = [UIColor clearColor];
    [_rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_rightBtn];
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _pickerBgView.frame.size.width, 2)];
    lineView1.backgroundColor = kLINECOLOR;
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(_pickerBgView.frame.size.width/2-0.5, 0, 1, TOOLBAR_HEIGHT)];
    lineView2.backgroundColor = kLINECOLOR;
    [_toolBar addSubview:lineView1];
    [_toolBar addSubview:lineView2];
}

- (void)initPickerView{
    //取消时间空间顶部时间显示栏 - UI负责人要求与安卓统一，所以取消--20161207
    //_datePicker = [[UIView alloc] initWithFrame:CGRectMake(0, TITLEBAR_HEIGHT, _pickerBgView.frame.size.width, SCROLLVIEW_HEIGHT)];
    _datePicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pickerBgView.frame.size.width, SCROLLVIEW_HEIGHT)];
    _datePicker.backgroundColor = [UIColor whiteColor];
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, SCROLLVIEW_HEIGHT/2-18, _pickerBgView.frame.size.width, 1)];
    lineView1.backgroundColor = kLINECOLOR;
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, SCROLLVIEW_HEIGHT/2+18, _pickerBgView.frame.size.width, 1)];
    lineView2.backgroundColor = kLINECOLOR;
    [_pickerBgView addSubview:_datePicker];
    [_pickerBgView addSubview:lineView1];
    [_pickerBgView addSubview:lineView2];
}

- (void)initCalendar{
    _calendar = [NSCalendar autoupdatingCurrentCalendar];
    //设置本地时区
    _calendar.timeZone = [NSTimeZone localTimeZone];
    _calendar.locale = [NSLocale autoupdatingCurrentLocale];
    
    _yearInt = 0;
    _monthInt = 0;
    _dayInt = 0;
    _hourInt = 0;
    _minuteInt = 0;
    _secondInt = 0;
    _weekInt = 0;
    _dateInt = 0;
    _startYearInt = 0;
    _endYearInt = 0;
}

#pragma mark获取日历中的年月日
- (NSArray *)years{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = _startYearInt; i <= _endYearInt; i++) {
        NSString *year = [NSString stringWithFormat:@"%ld",(long)i];
        [array addObject:year];
    }
    
    return array;
}

- (NSArray *)months{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < _calendar.monthSymbols.count; i++) {
        NSString *month = [NSString stringWithFormat:@"%02d",i+1];
        [array addObject:month];
    }

    return array;
}

- (NSArray *)days{
    NSInteger yearIndex = _yearInt-_startYearInt;
    NSInteger monthIndex = _monthInt-1;
    
    NSString *curYear = [[self years] objectAtIndex:yearIndex];
    NSString *curMonth = [[self months] objectAtIndex:monthIndex];
    NSArray *days = [self daysFromMonth:curMonth ofYear:curYear];
    return days;
}

- (NSArray *)daysFromMonth:(NSString *)month ofYear:(NSString *)year{
    NSString *curYear = year;
    NSString *curMonth = month;
    
    NSMutableArray *array = [NSMutableArray array];
    //将时间字符串转换date
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyyMM";
    NSDate *date = [format dateFromString:[curYear stringByAppendingString:curMonth]];

    //从date获取天数,range.location,当月第一天,range.length，天数
    NSRange range = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    for (NSInteger i = range.location; i <= range.length; i++) {
        NSString *day = [NSString stringWithFormat:@"%02ld",(long)i];
        [array addObject:day];
    }
    
    return array;
}

- (NSArray *)hours{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:24];
    
    for (int i = 0; i < 24; i++) {
        NSString *hour = [NSString stringWithFormat:@"%02d",i];
        [array addObject:hour];
    }
    return array;
}

- (NSArray *)minutes{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:60];
    
    for (int i = 0; i < 60; i++) {
        NSString *minute = [NSString stringWithFormat:@"%02d",i];
        [array addObject:minute];
    }
    return array;
}

- (NSArray *)dateFromYear:(NSString *)year{
    NSString *curYear = year;
    
    NSMutableArray *array = [NSMutableArray array];
    //将时间字符串转换date
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy";
    NSDate *date = [format dateFromString:curYear];
    
    NSDateComponents *comps =[_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSWeekCalendarUnit)fromDate:date];
    int count = 0;
    for (int i = 0; i < 12; i++) {
        [comps setMonth:i];
        NSRange range = [_calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[_calendar dateFromComponents:comps]];
            count += range.length;
    }
    for (int i = 1; i < count+1 ; i++) {
        NSString *day = [NSString stringWithFormat:@"%d",i];
        [array addObject:day];
    }
    return array;
}

-(NSArray *)weekDays{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:24];
    
    for (int i = 1; i < 8; i++) {
        NSString *week = [NSString stringWithFormat:@"%d",i];
        [array addObject:week];
    }
    return array;
}

#pragma mark 设置属性
-(void)setStartDateLimit:(NSString *)startDateLimit {
    BOOL isValue = startDateLimit && ![startDateLimit isEqualToString:@""];
    if (isValue) {
        _startYearInt = [startDateLimit integerValue];
    }
    else {
        _startYearInt = 2000;
    }
    
}

-(void)setEndDateLimit:(NSString *)endDateLimit {
    BOOL isValue = endDateLimit && ![endDateLimit isEqualToString:@""];
    if (isValue) {
        _endYearInt = [endDateLimit integerValue];
    }
    else {
        _endYearInt = 2050;
    }
}

- (void)setFormat:(NSString *)format{
    [self getCorrectFormat:format];
    [self setDateWithValue:_startValue];
    [self setTitleBarText];
    
}

- (void)setStartValue:(NSString *)startValue{
    if (startValue.length) {
        _startValue = startValue;//后台指定时间
    }else{
        //如果未指定，默认为当前系统时间
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        NSString *curDate = [dateFormatter stringFromDate:date];
        _startValue = curDate;
    }
    [self setDateWithValue:_startValue];
}

-(NSDateComponents *)getComponents:(NSDate *)date {
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *components = [_calendar components:unitFlags fromDate:date];
    return components;
}

-(NSInteger)getLocalInYear:(NSInteger)year :(NSInteger)month :(NSInteger)day{
    NSString *curYear = [NSString stringWithFormat:@"%ld",(long)year];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy";
    NSDate *date = [format dateFromString:curYear];
    
    NSDateComponents *comps =[_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSWeekCalendarUnit)fromDate:date];
    NSInteger localDate = day ;
    for (int i = 1; i < month+1; i++) {
        if (i != 1) {
            [comps setMonth:i];
            
            NSRange range = [_calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[_calendar dateFromComponents:comps]];
            localDate += range.length;
        }
        
    }
    
    return localDate;

}
-(NSDate *)getDateByLocal:(NSInteger)local {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-01-01",(long)_yearInt]];
    NSDate *date = [startDate dateByAddingTimeInterval:60 * 60 * 24 * (local-1)];
    return  date;
}
#pragma mark 设置时间
- (void)setDateWithValue:(NSString *)value{

    if (_format) {
        [self getCorrectFormat:_format];
    }
    NSDate *date = [_dateFormatter dateFromString:value];
    
    if (!date) {
        date = [NSDate date];
    }
    NSDateComponents *components;
    if (_endYearInt <[[self getComponents:date] year]) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [NSString stringWithFormat:@"%ld-01-01",(long)_endYearInt];
        NSDate *date1 = [formatter dateFromString:dateString];
        components = [self getComponents:date1];
    }
    else {
        components = [self getComponents:date];
    }
    
    
    NSInteger curYear = [components year];
    NSInteger curMonth = [components month];
    NSInteger curDay = [components day];
    NSInteger curHour = [components hour];
    NSInteger curMinute = [components minute];
    NSInteger curWeekDay = [components weekday];
    NSInteger curDate =  [self getLocalInYear:curYear :curMonth :curDay];
    
    NSArray *days = [self daysFromMonth:[NSString stringWithFormat:@"%02ld",(long)curMonth] ofYear:[NSString stringWithFormat:@"%ld",(long)curYear]];
    NSArray *dates = [self dateFromYear:[NSString stringWithFormat:@"%ld",(long)curYear]];
    
    NSArray * yearArray =  [self years];
    
    for (int i = 0; i < yearArray.count; i++) {
        NSString *year = yearArray[i];
        if ([year integerValue] == curYear) {
            _yearInt = i+_startYearInt;
            break;
        }
    }
    NSArray * monthArray =  [self months];
    for (int i = 0; i < monthArray.count; i++) {
        NSString *month = monthArray[i];
        if ([month integerValue] == curMonth) {
            _monthInt = i+1;
            break;
        }
    }
    
    for (int i = 0; i < days.count; i++) {
        NSString *day = days[i];
        if ([day integerValue] == curDay) {
            _dayInt = i+1;
            break;
        }
    }
    NSArray * hourArray =  [self hours];
    for (int i = 0; i < hourArray.count; i++) {
        NSString *hour = hourArray[i];
        if ([hour integerValue] == curHour) {
            _hourInt = i;
            break;
        }
    }
    NSArray * minuteArray =  [self minutes];
    for (int i = 0; i < minuteArray.count; i++) {
        NSString *minute = [self minutes][i];
        if ([minute integerValue] == curMinute) {
            _minuteInt = i;
            break;
        }
    }
    
    for (int i = 0; i < [self weekDays].count; i++) {
        NSString *weekDay = [self weekDays][i];
        if ([weekDay integerValue] == curWeekDay) {
            _weekInt = i+1;
            break;
        }
    }
    for (int i = 0; i < dates.count; i++) {
        NSString *date = dates[i];
        if ([date integerValue] == curDate) {
            _dateInt = i+1;
            break;
        }
    }
    
    [self setViewForPicker];
    [self reloadPickerData];
}

- (void)reloadPickerData{
    if (yearScrollView) {
        if (_yearInt ==_startYearInt) {
            [yearScrollView setCurrentSelectPage:(_yearInt-_startYearInt-1)];
        }else{
        [yearScrollView setCurrentSelectPage:(_yearInt-_startYearInt-2)];
        }
        
        yearScrollView.datasource = self;
    }
    if (monthScrollView) {
        [monthScrollView setCurrentSelectPage:(_monthInt-3)];
        monthScrollView.datasource = self;
    }
    if (dayScrollView) {
        [dayScrollView setCurrentSelectPage:(_dayInt-3)];
        dayScrollView.datasource = self;
    }
    if (hourScrollView) {
        [hourScrollView setCurrentSelectPage:(_hourInt-2)];
        hourScrollView.datasource = self;
    }
    if (minuteScrollView) {
        [minuteScrollView setCurrentSelectPage:(_minuteInt-2)];
        minuteScrollView.datasource = self;
    }
    if (secondScrollView) {
        [secondScrollView setCurrentSelectPage:(_secondInt-2)];
        secondScrollView.datasource = self;
    }
    if (weekDayScrollView) {
        [weekDayScrollView setCurrentSelectPage:(_weekInt-2)];
        weekDayScrollView.datasource = self;
    }
    if (dateScrollView) {
        [dateScrollView setCurrentSelectPage:(_dateInt-2)];
        dateScrollView.datasource = self;
    }
}

#pragma mark 隐藏picker
- (void)hiddenPicker{
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _pickerBgView.frame;
        
        if (frame.origin.y == self.frame.size.height-frame.size.height) {
            frame.origin.y += frame.size.height;
            _pickerBgView.frame = frame;
        }
    } completion:^(BOOL finished) {
        jkDatePicker.hidden = YES;
        [jkDatePicker.fatherView sendSubviewToBack:self];
        [jkDatePicker removeFromSuperview];
        jkDatePicker = nil;
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
//    NSLog(@"touchview  %@",NSStringFromClass([touch.view class]));
    
    if ([NSStringFromClass([gestureRecognizer class]) isEqualToString:@"UITapGestureRecognizer"]) {
        if ([NSStringFromClass([touch.view class]) isEqualToString:@"UINavigationBar"]) {
            return NO;
        }
        
        CGPoint touchPoint = [touch locationInView:jkDatePicker];
        if (touchPoint.y < _pickerBgView.frame.origin.y) {
            return YES;
        }
        return NO;
    }
    return YES;
}

#pragma mark scrollView  and delegate  and datasource
//设置年月日时分的滚动视图
- (void)setYearScrollViewWithFrame:(CGRect)frame
{
    if (yearScrollView) {
        return;
    }
    
    yearScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger yearint = _yearInt;
    [yearScrollView setCurrentSelectPage:(yearint-_startYearInt-2)];
    yearScrollView.dateType = DateTypeYear;
    yearScrollView.delegate = self;
    yearScrollView.datasource = self;
    [self setAfterScrollShowView:yearScrollView andCurrentPage:1];
    
    [_datePicker addSubview:yearScrollView];
}
//设置年月日时分的滚动视图
- (void)setMonthScrollViewWithFrame:(CGRect)frame
{
    if (monthScrollView) {
        return;
    }
    
    monthScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger monthint = _monthInt;
    [monthScrollView setCurrentSelectPage:(monthint-3)];
    monthScrollView.dateType = DateTypeMonth;
    monthScrollView.delegate = self;
    monthScrollView.datasource = self;
    [self setAfterScrollShowView:monthScrollView andCurrentPage:1];
    
    [_datePicker addSubview:monthScrollView];
}
//设置年月日时分的滚动视图
- (void)setDayScrollViewWithFrame:(CGRect)frame
{
    if (dayScrollView) {
        return;
    }
    
    dayScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger dayint = _dayInt;
    [dayScrollView setCurrentSelectPage:(dayint-3)];
    dayScrollView.dateType = DateTypeDay;
    dayScrollView.delegate = self;
    dayScrollView.datasource = self;
    [self setAfterScrollShowView:dayScrollView andCurrentPage:1];
    
    [_datePicker addSubview:dayScrollView];
}
//设置年月日时分的滚动视图
- (void)setDateScrollViewWithFrame:(CGRect)frame
{
    if (dateScrollView) {
        return;
    }
    
    dateScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger date = _dateInt;
    [dateScrollView setCurrentSelectPage:(date-3)];
    dateScrollView.dateType = DateTypeDate;
    dateScrollView.delegate = self;
    dateScrollView.datasource = self;
    [self setAfterScrollShowView:dateScrollView andCurrentPage:1];
    
    [_datePicker addSubview:dateScrollView];
}
//设置年月日时分的滚动视图
- (void)setWeekDayScrollViewWithFrame:(CGRect)frame
{
    if (weekDayScrollView) {
        return;
    }
    
    weekDayScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger weekDay = _weekInt;
    [weekDayScrollView setCurrentSelectPage:(weekDay-3)];
    weekDayScrollView.dateType = DateTypeWeekDay;
    weekDayScrollView.delegate = self;
    weekDayScrollView.datasource = self;
    [self setAfterScrollShowView:weekDayScrollView andCurrentPage:1];
    
    [_datePicker addSubview:weekDayScrollView];
}
//设置年月日时分的滚动视图
- (void)setHourScrollViewWithFrame:(CGRect)frame
{
    if (hourScrollView) {
        return;
    }
    
    hourScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger hourint = _hourInt;
    [hourScrollView setCurrentSelectPage:(hourint-2)];
    hourScrollView.dateType = DateTypeHour;
    hourScrollView.delegate = self;
    hourScrollView.datasource = self;
    [self setAfterScrollShowView:hourScrollView andCurrentPage:1];
    
    [_datePicker addSubview:hourScrollView];
}
//设置年月日时分的滚动视图
- (void)setMinuteScrollViewWithFrame:(CGRect)frame
{
    if (minuteScrollView) {
        return;
    }
    
    minuteScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger minuteint = _minuteInt;
    [minuteScrollView setCurrentSelectPage:(minuteint-2)];
    minuteScrollView.dateType = DateTypeMinute;
    minuteScrollView.delegate = self;
    minuteScrollView.datasource = self;
    [self setAfterScrollShowView:minuteScrollView andCurrentPage:1];
    
    [_datePicker addSubview:minuteScrollView];
}
//设置年月日时分的滚动视图
- (void)setSecondScrollViewWithFrame:(CGRect)frame
{
    if (secondScrollView) {
        return;
    }
    
    secondScrollView = [[MXSCycleScrollView alloc] initWithFrame:frame];
    NSInteger secondint = _secondInt;
    [secondScrollView setCurrentSelectPage:(secondint-2)];
    secondScrollView.dateType = DateTypeSecond;
    secondScrollView.delegate = self;
    secondScrollView.datasource = self;
    [self setAfterScrollShowView:secondScrollView andCurrentPage:1];
    
    [_datePicker addSubview:secondScrollView];
}

- (void)setAfterScrollShowView:(MXSCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    CGFloat fontSize = 13.0;
    UIColor *textColor = date_ColorWithRGB(186.0, 186.0, 186.0);
    
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [oneLabel setTextColor:textColor];

    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [twoLabel setTextColor:textColor];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:15]];
    [currentLabel setTextColor:[UIColor blackColor]];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [threeLabel setTextColor:textColor];

    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [fourLabel setTextColor:textColor];
}

#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView
{
    NSInteger number = 0;
    
    switch (scrollView.dateType) {
        case DateTypeYear:
            number = [self years].count;
            break;
        case DateTypeMonth:
            number = [self months].count;
            break;
        case DateTypeDay:
            number = [self days].count;
            break;
        case DateTypeHour:
            number = [self hours].count;
            break;
        case DateTypeMinute:
            number = [self minutes].count;
            break;
        case DateTypeSecond:
            number = [self minutes].count;
            break;
        case DateTypeWeekDay:{
            number =  7;
            break;
        }
            
        case DateTypeDate:{
            NSString *yearString = [NSString stringWithFormat:@"%ld",(long)_yearInt];
            number = [self dateFromYear:yearString].count;
            break;
        }
            
        default:
            break;
    }
    
    return number;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView *)scrollView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height/5)];
    label.tag = index+1;

    CGFloat fontSize = 13;
    UIColor *textColor = date_ColorWithRGB(186.0, 186.0, 186.0);
    
    switch (scrollView.dateType) {
        case DateTypeYear:
        {
            

            
            label.text = [NSString stringWithFormat:@"%ld年",(long)(_startYearInt+index)];
            if (_startYearInt == _endYearInt) {
                label.text = [NSString stringWithFormat:@"%ld年",_startYearInt];
            }
            
            cellNum++;
            if (cellNum%7==4) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }

        }
            break;
        case DateTypeMonth:
        {
            label.text = [NSString stringWithFormat:@"%02ld月",(long)(1+index)];
            if (index == _monthInt-1) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        case DateTypeDay:
        {
            label.text = [NSString stringWithFormat:@"%02ld日",(long)(1+index)];
            if (index == _dayInt-1) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        case DateTypeHour:
        {
            label.text = [NSString stringWithFormat:@"%02ld",(long)index];
            if (index == _hourInt) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        case DateTypeMinute:
        {
            label.text = [NSString stringWithFormat:@"%02ld",(long)index];
            if (index == _minuteInt) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        case DateTypeSecond:
        {
            label.text = [NSString stringWithFormat:@"%02ld",(long)index];
            if (index == _secondInt) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        case DateTypeWeekDay:
        {
            label.text = [self weekdayStringFromWeekIndex:index];
            if (index == _weekInt) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        case DateTypeDate:
        {
            NSDate *date = [self getDateByLocal:index];
            NSDateFormatter *format = [NSDateFormatter new];
            [format setDateFormat:@"MM月dd日"];
            NSString *labelText = [format stringFromDate:date];
            label.text = labelText;
            if (index == _dateInt) {
                fontSize = 15;
                textColor = [UIColor blackColor];
            }
        }
            break;
        default:
            break;
    }

    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

//监听滚动
- (void)scrollviewDidChangeNumber:(MXSCycleScrollView *)scrollView{
    UILabel *label = [[(UILabel*)[[scrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    
    switch (scrollView.dateType) {
        case DateTypeYear:
        {
            
            
            _yearInt = label.tag+_startYearInt-1;
            if (_yearInt > _endYearInt) {
                _yearInt =_endYearInt;
            }
            
            [dayScrollView setCurrentSelectPage:(_dayInt-3)];
            dayScrollView.datasource = self;
        }
            break;
        case DateTypeMonth:
        {
            _monthInt = label.tag;
            [dayScrollView setCurrentSelectPage:(_dayInt-3)];
            dayScrollView.datasource = self;
            
            //重置_dayInt的时间
            [self resetDayTimeValueWithMonth:[NSString stringWithFormat:@"%02ld",(long)_monthInt]];
            
        }
            break;
        case DateTypeDay:
            _dayInt = label.tag;
            break;
        case DateTypeHour:
            _hourInt = label.tag-1;
            break;
        case DateTypeMinute:
            _minuteInt = label.tag-1;
            break;
        case DateTypeSecond:
            _secondInt = label.tag-1;
            break;
        case DateTypeWeekDay:
            _weekInt = label.tag-1;
            break;
        case DateTypeDate:
            _dateInt = label.tag-1;
            break;
        default:
            break;
    }
    [self setTitleBarText];
}
#pragma mark 设置titleBar的text
-(void)setTitleBarText {
    NSString *dateString = [self getCurDateString:@"0"];
    _titleLabel.text = [NSString stringWithFormat:@"    %@",dateString];
}
#pragma mark UIPicker delegate and datasource
- (NSInteger)numberOfPickerComponents{
    NSInteger number = 0;
    
    switch (_datePickerMode) {
        case PAFFDateModeOnlyYear:
            number = 1;
            break;
        case PAFFDateModeOnlyMonth:
            number = 1;
            break;
        case PAFFDateModeOnlyDay:
            number = 1;
            break;
        case PAFFDateModeYearAndMonth:
            number = 2;
            break;
        case PAFFDateModeMonthAndDay:
            number = 2;
            break;
        case PAFFDateModeHourAndMinute:
            number = 2;
            break;
        case PAFFDateModeWeekDayAndTime:
            number = 5;
            break;
        case PAFFDateModeCompleteDate:
            number = 3;
            break;
        default:
            break;
    }
    return number;
}

- (CGFloat)widthForPickerComponent{
    NSInteger number = [self numberOfPickerComponents];
    CGFloat width = _datePicker.frame.size.width/number;
    return width;
}

- (CGFloat)heightForPickerComponent{
    return _datePicker.frame.size.height;
}

- (void)setViewForPicker{
    CGSize size = CGSizeMake([self widthForPickerComponent], [self heightForPickerComponent]);
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    switch (_datePickerMode) {
        case PAFFDateModeOnlyYear:
            [self setYearScrollViewWithFrame:frame];
            break;
        case PAFFDateModeOnlyMonth:
            [self setMonthScrollViewWithFrame:frame];
            break;
        case PAFFDateModeOnlyDay:
            [self setDayScrollViewWithFrame:frame];
            break;
        case PAFFDateModeYearAndMonth:
        {
            frame.origin.x = 0;
            [self setYearScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width;
            [self setMonthScrollViewWithFrame:frame];
        }
            break;
        case PAFFDateModeMonthAndDay:
        {
            frame.origin.x = 0;
            [self setMonthScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width;
            [self setDayScrollViewWithFrame:frame];
        }
            break;
        case PAFFDateModeHourAndMinute:
        {
            frame.origin.x = 0;
            [self setHourScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width;
            [self setMinuteScrollViewWithFrame:frame];
        }
            break;
        case PAFFDateModeWeekDayAndTime:
        {
            frame.origin.x = 0;
            [self setYearScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width;
            [self setMonthScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width*2;
            [self setDayScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width*3;
            [self setHourScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width*4;
            [self setMinuteScrollViewWithFrame:frame];
        }
            break;
        case PAFFDateModeCompleteDate:
        {
            frame.origin.x = 0;
            [self setYearScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width;
            [self setMonthScrollViewWithFrame:frame];
            frame.origin.x = frame.size.width*2;
            [self setDayScrollViewWithFrame:frame];
        }
            break;
        default:
            break;
    }
}

#pragma mark 点击空白隐藏
- (void)tapHidden{
    [self hiddenPicker];
    if (_leftBtnCallback) {
        _leftBtnCallback();
    }
}

#pragma mark CallBack回调
- (void)leftBtnClick{
    [self hiddenPicker];
    if (_leftBtnCallback) {
        _leftBtnCallback();
    }
}

- (void)rightBtnClick{
    NSString *dateString = [NSString stringWithFormat:@"'%@'", [self getCurDateString:@"1"]];

    if (_rightBtnCallback) {
        _rightBtnCallback(dateString);
    }
    [self hiddenPicker];
}

-(NSString *)getCurDateString:(NSString *)tag {
    NSString * string = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld",(long)_yearInt,(long)_monthInt,(long)_dayInt,(long)_hourInt,(long)_minuteInt];
    NSDateFormatter *format = [NSDateFormatter new];
    format.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [format dateFromString:string];
    
    NSString *dateString ;
    NSString *showInToolString ;
    
    switch (_datePickerMode) {
        case PAFFDateModeOnlyYear:
        {
            format.dateFormat = @"yyyy";
            dateString =  [format stringFromDate:date];
            format.dateFormat = @"yyyy年";
            showInToolString = [format stringFromDate:date];
            
        }
            break;
        case PAFFDateModeOnlyMonth:
        {
            format.dateFormat = @"MM";
            dateString =  [format stringFromDate:date];
            format.dateFormat = @"MM月";
            showInToolString = [format stringFromDate:date];
        }
            break;
        case PAFFDateModeOnlyDay:
        {
            format.dateFormat = @"dd";
            dateString =  [format stringFromDate:date];
            format.dateFormat = @"dd日";
            showInToolString = [format stringFromDate:date];
        }
            break;
        case PAFFDateModeYearAndMonth:
        {
            format.dateFormat = @"yyyy-MM";
            dateString =  [format stringFromDate:date];
            format.dateFormat = @"yyyy年MM月";
            showInToolString = [format stringFromDate:date];
        }
            break;
        case PAFFDateModeMonthAndDay:
        {
            format.dateFormat = @"MM-dd";
            dateString =  [format stringFromDate:date];
            format.dateFormat = @"MM月dd日";
            showInToolString = [format stringFromDate:date];
        }
            break;
        case PAFFDateModeHourAndMinute:
        {
            format.dateFormat = @"HH:mm";
            dateString =  [format stringFromDate:date];
            showInToolString = [format stringFromDate:date];
        }
            break;
        case PAFFDateModeCompleteDate:
        {
            format.dateFormat = @"yyyy-MM-dd";
            dateString =  [format stringFromDate:date];
            format.dateFormat = @"yyyy年MM月dd日";
            showInToolString = [format stringFromDate:date];
        }
            break;
        case PAFFDateModeWeekDayAndTime:
        {
            format.dateFormat = @"yyyy-MM-dd HH:mm";
            dateString =  [format stringFromDate:date];
            
            NSString * str1 = [self weekdayStringFromDate:date];
            format.dateFormat = @"yyyy年MM月dd日 HH:mm ";
            NSString *str2  = [format stringFromDate:date];
            NSMutableString *string = [[NSMutableString alloc]initWithString:str2];
            
            [string insertString:[NSString stringWithFormat:@"%@ ",str1] atIndex:12];
            showInToolString = string;
        }
            break;
        default:
            break;
    }
    if ([tag isEqualToString:@"1"]) {
        return dateString;
    }
    return showInToolString;
}
- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    NSDateComponents *theComponents = [_calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

-(NSString*)weekdayStringFromWeekIndex:(NSInteger)index {
    NSString *weekDayString ;
    switch (index) {
        case 1:
            weekDayString = @"周日";
            break;
        case 2:
            weekDayString = @"周一";
            break;
        case 3:
            weekDayString = @"周二";
            break;
        case 4:
            weekDayString = @"周三";
            break;
        case 5:
            weekDayString = @"周四";
            break;
        case 6:
            weekDayString = @"周五";
            break;
        case 7:
            weekDayString = @"周六";
            break;
        default:
            break;
    }
    return weekDayString;
}


- (void)getCorrectFormat:(NSString *)inputFormat{

    _format = [inputFormat lowercaseString];
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    //只显示年
    if ([_format isEqualToString:[@"Y" lowercaseString]]) {
        _datePickerMode = PAFFDateModeOnlyYear;
        _dateFormatter.dateFormat = @"yyyy";
    }
    //只显示月
    else if ([_format isEqualToString:[@"m" lowercaseString]]) {
        
        
        _datePickerMode = PAFFDateModeOnlyMonth;
        _dateFormatter.dateFormat = @"MM";
    }
    //只显示日
    else if ([_format isEqualToString:[@"d" lowercaseString]]) {
        _datePickerMode = PAFFDateModeOnlyDay;
        _dateFormatter.dateFormat = @"dd";
    }
    //只显示年和月
    else if ([_format isEqualToString:[@"Y-m" lowercaseString]]) {
        _datePickerMode = PAFFDateModeYearAndMonth;
        _dateFormatter.dateFormat = @"yyyy-MM";
    }
    //只显示月和日
    else if ([_format isEqualToString:[@"m-d" lowercaseString]]) {
        _datePickerMode = PAFFDateModeMonthAndDay;
        _dateFormatter.dateFormat = @"MM-dd";
    }
    // 显示年月日
    else if ([_format isEqualToString:[@"Y-m-d" lowercaseString]]) {
        _datePickerMode = PAFFDateModeCompleteDate;
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    //显示日时分
    else if ([_format isEqualToString:[@"w-h-m" lowercaseString]]) {
        _datePickerMode = PAFFDateModeWeekDayAndTime;
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    //显示小时和分钟
    else if ([_format isEqualToString:[@"H:M" lowercaseString]]) {
        _datePickerMode = PAFFDateModeHourAndMinute;
        _dateFormatter.dateFormat = @"HH:mm";
        
    }
    //其余的全部默认为显示完整的年月日
    else {
        _datePickerMode = PAFFDateModeCompleteDate;
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
}

/**
 更新当前日的显示时间

 @param dayScrollView 当前显示的月份
 */
- (void)resetDayTimeValueWithMonth:(NSString *)month{
    NSArray *days = [self daysFromMonth:month ofYear:[NSString stringWithFormat:@"%ld",(long)_yearInt]];
    NSString *dayStr = [NSString stringWithFormat:@"%d",_dayInt]; // 显示选中日的字符串
    if (_dayInt<10) {
        dayStr = [NSString stringWithFormat:@"0%d",_dayInt];
    }
    if (days.count && ![days containsObject:dayStr]) {
        _dayInt =  [days[days.count-1] integerValue];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
