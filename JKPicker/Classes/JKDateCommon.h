//
//  JKDateCommon.h
//  
//
//  Created by Jack on 16/12/9.
//  Copyright © 2016年 localadmin. All rights reserved.
//

#ifndef JKDateCommon_h
#define JKDateCommon_h

typedef void(^JKLeftBtnCallBack)();
typedef void(^JKRightBtnCallBack)(NSString *selectedDateStr);

#define date_kScreenWidth                [[UIScreen mainScreen] bounds].size.width
#define date_kScreenHeight               [[UIScreen mainScreen] bounds].size.height
#define date_UIColorFromRGB(rgbValue)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define date_ColorWithRGBA(r,g,b,a)     [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define date_ColorWithRGB(r,g,b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define date_kNavBarColor                date_UIColorFromRGB(0x35c7fa)
#define date_kKeyBoardWidthScale         [[UIScreen mainScreen] bounds].size.width/320.0f
#define date_kKeyBoardHeightScale        [[UIScreen mainScreen] bounds].size.height/480.0f

#endif /* JKDateCommon_h */
