//
//  SSCalendarReminder.h
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/25.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>

/**
 * 日历提醒
 */
@class SSEventItem;

NS_ASSUME_NONNULL_BEGIN

@interface SSCalendarReminder : NSObject
+ (instancetype)shareInstance;

// 添加日历事件
- (void)addCalendarEvent:(void(^)(SSEventItem *eventItem))eventItem completion:(void(^)(EKEvent * event))completion;

// 获取时间范围里的所有日历事件
- (void)getCalendarEventWithStartDate:(NSDate *)startDate
                              endDate:(NSDate *)endDate
                           completion:(void(^)(NSArray<EKEvent *> * eventList))completion;
@end


@interface SSEventItem : NSObject
@property (nonatomic, strong) NSString *title;
//开始时间
@property (nonatomic, strong) NSDate *startDate;
//结束时间
@property (nonatomic, strong) NSDate *endDate;
//设置街道地址(点击可跳转到AppleMap导航)
@property (nonatomic, strong) NSString *location;
//可跳转到设置的链接
@property (nonatomic, strong) NSURL *url;
//日记(事件的详情内容)
@property (nonatomic, strong) NSString *notes;
//All-Day
@property (nonatomic, assign) BOOL allDay;
//Alerm 闹钟提醒
@property (nonatomic, assign) NSTimeInterval triggerInterval; // 例如-10则开始日期前10秒

@end

NS_ASSUME_NONNULL_END
