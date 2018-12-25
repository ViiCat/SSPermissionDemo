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
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation CalendarReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (IBAction)addReminder:(id)sender {
//    [[SSCalendarReminder shareInstance] createEventCalendarTitle:@"提醒标题" location:@"提醒内容" startDate:date endDate:self.datePicker.date allDay:YES alarmArray:@[@"1",@"2",@"3"]];

    __weak typeof(self) weakSelf = self;
    [[SSCalendarReminder shareInstance] addEvent:^(SSEventItem * _Nonnull item) {
        item.title = @"去健身";
        item.startDate = [NSDate date];
        item.endDate = weakSelf.datePicker.date;
    } completion:^{
        NSLog(@"completed");
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
