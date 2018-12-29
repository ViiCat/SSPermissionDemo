//
//  CalendarReminderViewController.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/25.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "CalendarReminderViewController.h"
#import "SSCalendarReminder.h"

@interface CalendarReminderViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@end

@implementation CalendarReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (IBAction)addCalendar:(id)sender {

    __weak typeof(self) weakSelf = self;
    [[SSCalendarReminder shareInstance] addCalendarEvent:^(SSEventItem * _Nonnull eventItem) {
        eventItem.title = @"去健身";
        eventItem.startDate = weakSelf.startDatePicker.date;//[NSDate date];
        eventItem.endDate = weakSelf.endDatePicker.date;
    } completion:^(EKEvent * _Nonnull event) {
        
    }];
}

- (IBAction)getCalendar:(id)sender {
    
    [[SSCalendarReminder shareInstance] getCalendarEventWithStartDate:self.startDatePicker.date endDate:self.endDatePicker.date completion:^(NSArray<EKEvent *> * _Nonnull eventList) {
        
        [eventList enumerateObjectsUsingBlock:^(EKEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Event Title:%@",obj.title);
        }];
    }];
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
