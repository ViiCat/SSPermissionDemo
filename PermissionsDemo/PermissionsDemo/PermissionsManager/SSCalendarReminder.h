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

typedef void(^CompletionBlock)(void);

@interface SSCalendarReminder : NSObject
+ (instancetype)shareInstance;

- (EKEvent *)addEvent:(void(^)(SSEventItem *eventItem))eventItem completion:(CompletionBlock)completion;
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

@end

NS_ASSUME_NONNULL_END
