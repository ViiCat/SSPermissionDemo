//
//  SSCalendarReminder.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/25.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "SSCalendarReminder.h"

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



- (EKEvent *)addEvent:(void (^)(SSEventItem * _Nonnull))eventItem completion:(CompletionBlock)completion {
//    NSAssert(!eventItem, @"Event Item is Nil!!");
    
    SSEventItem *item = [[SSEventItem alloc] init];
    eventItem(item);
    
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        //用户允许访问日历
//        startDate = [self convertDate:startDate];
//        endDate = [self convertDate:endDate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Identityfier:%@", event.eventIdentifier);
            
            //设置当前的 Event 属于 系统的日历
            event.calendar = [eventStore defaultCalendarForNewEvents];
            
            NSLog(@"Start:%@\n",item.startDate);
            NSLog(@"End:%@\n",item.endDate);
            
            event.startDate = item.startDate;
            event.endDate   = item.endDate;
            
            event.title = item.title;
            //地址(点击可跳转到AppleMap导航)
            event.location = item.location ?: @"湖南省长沙市华天酒店";
            //可跳转到设置的链接
            event.URL = item.url ?: [NSURL URLWithString:@"http://www.viicat.com"];
            //日记(事件的详情内容)
            event.notes = item.notes ?: @"今天计划从120 瘦到 119！！";
            
            [event refresh];
            
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
            
            
            if (!err) {
                [self showAlert:@"已添加到系统日历"];
            } else {
                [self showAlert:err.description];
            }
        });
        
        return event;
        
    } else if (authorizationStatus == EKAuthorizationStatusDenied) {
        //用户拒绝授权
    } else if (authorizationStatus == EKAuthorizationStatusNotDetermined) {
        //用户还没有决定app是否可以访问该服务
    } else if (authorizationStatus == EKAuthorizationStatusRestricted) {
        //应用程序未被授权访问该服务
    }
    
    return event;
}

- (void)createEventCalendarTitle:(NSString *)title
                        location:(NSString *)location
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate
                          allDay:(BOOL)allDay
                      alarmArray:(NSArray *)alarmArray{
    
    __weak typeof(self) weakSelf = self;
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (error)
                {
                    [strongSelf showAlert:@"添加失败，请稍后重试"];
                    
                }else if (!granted){
                    [strongSelf showAlert:@"不允许使用日历,请在设置中允许此App使用日历"];
                    
                }else{
                    
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    NSLog(@"event.startDate1:%@\n",event.startDate);
                    NSLog(@"event.endDate1:%@",event.endDate);
                    
                    event.title     = title;
//                    event.location = location;
                    
//                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
//                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    
                    event.timeZone = [NSTimeZone defaultTimeZone];
                    NSLog(@"Start1:%@\n",startDate);
                    NSLog(@"End1:%@\n",endDate);
                    
                    
                    event.startDate = startDate;
                    event.endDate   = [startDate dateByAddingTimeInterval:30];//endDate;
                    event.allDay = allDay;
                    
                    NSLog(@"Start2:%@\n",startDate);
                    NSLog(@"End2:%@\n",endDate);
                    
                    NSLog(@"event.startDate:%@\n",event.startDate);
                    NSLog(@"event.endDate:%@",event.endDate);
                    
                    //添加提醒
//                    if (alarmArray && alarmArray.count > 0) {
//
//                        for (NSString *timeString in alarmArray) {
//                            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:[[NSDate date] dateByAddingTimeInterval:30]];//现在开始30秒后提醒
//                            [event addAlarm:alarm];
////                            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[timeString integerValue]]];
//                        }
//                    }
//                    
//                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
//                    NSError *err;
//                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
//                    [strongSelf showAlert:@"已添加到系统日历中"];
                    
                }
            });
        }];
    }
}

- (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end

@implementation SSEventItem

@end
