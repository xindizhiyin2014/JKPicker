//
//  JKDatePicker.h
//
//
//  Created by Jack on 15/4/30.
//  Copyright (c) 2015年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKDateCommon.h"

typedef enum : NSUInteger {
    PAFFDateModeOnlyYear,
    PAFFDateModeOnlyMonth,
    PAFFDateModeOnlyDay,
    PAFFDateModeYearAndMonth,
    PAFFDateModeMonthAndDay,
    PAFFDateModeHourAndMinute,
    PAFFDateModeWeekDayAndTime,
    PAFFDateModeCompleteDate,//default is JKDateModeCompleteDate
} JKDatePickerMode;


@interface JKDatePicker : UIView

/**
 * 选择日期
 * @param options
 * @param options.format: 日期格式['Y', 'Y-m', 'm-d', 'Y-m-d']
 * @param startValue  如果需要显示开始默认时间，请设置startValue
 * @param leftBtnCallback  取消按钮回调
 * @param rightBtnCallback 选择回调，传递选择的日期
 */
@property(strong , nonatomic)NSString *format;
@property(strong , nonatomic)NSString *startDateLimit;
@property(strong , nonatomic)NSString *endDateLimit;
@property(strong , nonatomic)NSString *startValue;
@property(copy , nonatomic)JKLeftBtnCallBack leftBtnCallback;
@property(copy , nonatomic)JKRightBtnCallBack rightBtnCallback;

+ (id)showPickerInView:(UIView *)view window:(UIWindow *)targetWindow;

@end
