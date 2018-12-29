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



- (void)addCalendarEvent:(void (^)(SSEventItem * _Nonnull))eventItem completion:(void (^)(EKEvent * _Nonnull))completion {
//    NSAssert(!eventItem, @"Event Item is Nil!!");
    
    SSEventItem *item = [[SSEventItem alloc] init];
    eventItem(item);
    
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        //用户允许访问日历
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
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
        });
        
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

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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
