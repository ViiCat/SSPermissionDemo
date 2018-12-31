//
//  SSCalendarReminder.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/25.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "SSCalendarReminder.h"
@interface SSCalendarReminder()
@property (nonatomic, strong) EKEventStore *eventStore;
@end


@implementation SSCalendarReminder
+ (instancetype)shareInstance {
    
    static SSCalendarReminder *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SSCalendarReminder alloc] init];
    });
    return _instance;
}

#pragma mark - 时区转换
- (NSDate *)convertDate:(NSDate *)date {
    
    NSDate *localeDate = date;
    
#if TARGET_IPHONE_SIMULATOR //模拟器
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    localeDate = [date  dateByAddingTimeInterval: interval];
#endif
    
    return localeDate;
}


#pragma mark - CalendarEvent
- (void)addCalendarEvent:(void (^)(SSEventItem * _Nonnull))eventItem completion:(void (^)(EKEvent * _Nonnull))completion {
//    NSAssert(!eventItem, @"Event Item is Nil!!");
    
    SSEventItem *item = [[SSEventItem alloc] init];
    eventItem(item);
    
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            return;
        }
        
        __weak typeof(self) weakSelf = self;
            
        //设置当前的 Event 属于 系统的日历
        event.calendar = [weakSelf.eventStore defaultCalendarForNewEvents];
        
//            NSLog(@"Start:%@\n",item.startDate);
//            NSLog(@"End:%@\n",item.endDate);
        event.startDate = item.startDate;
        event.endDate   = item.endDate;
        
        event.title = item.title;
        //地址(点击可跳转到AppleMap导航)
        event.location = item.location ?: @"湖南省长沙市华天酒店";
        //可跳转到设置的链接
        event.URL = item.url ?: [NSURL URLWithString:@"http://www.viicat.com"];
        //日记(事件的详情内容)
        event.notes = item.notes ?: @"今天计划从120 瘦到 119！！";
        //每天提醒
        event.allDay = item.allDay;
        
        [event addAlarm:[EKAlarm alarmWithRelativeOffset:item.triggerInterval]];
        
        [event refresh];
        
        NSError *err;
        [weakSelf.eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        
        if (!err) {
            [weakSelf showAlert:@"已添加到系统日历"];
        } else {
            [weakSelf showAlert:err.description];
        }
        
        completion(event);

    }];
    
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        //用户允许访问日历
    } else if (authorizationStatus == EKAuthorizationStatusDenied) {
        //用户拒绝授权
    } else if (authorizationStatus == EKAuthorizationStatusNotDetermined) {
        //用户还没有决定app是否可以访问该服务
    } else if (authorizationStatus == EKAuthorizationStatusRestricted) {
        //应用程序未被授权访问该服务
    }
}

- (void)getCalendarEventWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(NSArray<EKEvent *> * _Nonnull))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            return;
        }
        
        NSPredicate *fetchCalendarEvents = [weakSelf.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];

        NSArray<EKEvent *> *eventList = [weakSelf.eventStore eventsMatchingPredicate:fetchCalendarEvents];
        
        completion([eventList copy]);
    }];
}

#pragma mark - Reminder
- (void)addReminder:(void (^)(SSEventItem * _Nonnull))eventItem completion:(void (^)(EKReminder * _Nonnull))completion {
    
    SSEventItem *item = [[SSEventItem alloc] init];
    eventItem(item);
    
    __weak typeof(self) weakSelf = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            return;
        }
        
        EKReminder *reminder = [EKReminder reminderWithEventStore:weakSelf.eventStore];
        reminder.title = item.title ? : @"提醒你哦";
        reminder.calendar = [self.eventStore defaultCalendarForNewReminders];;
        reminder.notes = item.notes ? : @"2018年尾的第一场雪!";
        
        [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:[NSDate dateWithTimeIntervalSinceNow:item.triggerInterval]]];
        
        [self.eventStore saveReminder:reminder commit:YES error:&error];
        
        if (error) {
            NSLog(@"error=%@",error);
            [weakSelf showAlert:error.description];
        }else{
            [weakSelf showAlert:@"保存到提醒事项成功"];
            completion(reminder);
        }
    }];
    

    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        //用户允许访问日程提醒
    } else if (authorizationStatus == EKAuthorizationStatusDenied) {
        //用户拒绝授权
    } else if (authorizationStatus == EKAuthorizationStatusNotDetermined) {
        //用户还没有决定app是否可以访问该服务
    } else if (authorizationStatus == EKAuthorizationStatusRestricted) {
        //应用程序未被授权访问该服务
    }
}

- (void)getReminderCompletion:(void (^)(NSArray<EKReminder *> * _Nonnull))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            return;
        }
        
        // 获取所有的日历
        NSArray *canlendarArray = [weakSelf.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        // 遍历日历的类型
        for (EKCalendar *calendar in canlendarArray) {
            NSLog(@"title：%@ ， type：%ld , calendarIdentifier：%@",calendar.title,(long)calendar.type,calendar.calendarIdentifier);
        }
        
        //来查找所有的reminders
        NSPredicate *predicate =[weakSelf.eventStore predicateForRemindersInCalendars:@[canlendarArray.firstObject]];
        
        //异步方法。
        [weakSelf.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray<EKReminder *> * _Nullable reminders) {
            
            completion(reminders);
        }];
    }];
}

- (void)getReminderStartDate:(NSDate *)startDate
                     endDate:(NSDate *)endDate
                        type:(kRemindarType)type
                  completion:(void (^)(NSArray<EKReminder *> * _Nonnull))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (!granted) {
            return;
        }
        
        // 获取所有的日历
        NSArray *canlendarArray = [weakSelf.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        // 遍历日历的类型
        for (EKCalendar *calendar in canlendarArray) {
            NSLog(@"title：%@ ， type：%ld , calendarIdentifier：%@",calendar.title,(long)calendar.type,calendar.calendarIdentifier);
        }
        
        //来查找所有的reminders
        NSPredicate *predicate = nil;
        if (type == kRemindarTypeCompleted) {
            predicate = [weakSelf.eventStore predicateForCompletedRemindersWithCompletionDateStarting:startDate ending:endDate calendars:canlendarArray];
            
        } else if (type == kRemindarTypeIncomplete) {
            predicate = [weakSelf.eventStore predicateForIncompleteRemindersWithDueDateStarting:startDate ending:endDate calendars:canlendarArray];
        }        
        
        //异步方法。
        [weakSelf.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray<EKReminder *> * _Nullable reminders) {
            
            completion(reminders);
        }];
    }];
}
#pragma mark - Other
- (void)showAlert:(NSString *)message
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

#pragma mark - LazyLoad
- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

@end

@implementation SSEventItem
@end
