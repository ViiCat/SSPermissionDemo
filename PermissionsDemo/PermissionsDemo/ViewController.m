//
//  ViewController.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/22.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "ViewController.h"
#import "SSAccessAlbum.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSDictionary *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = self.dataSource.allKeys[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (((NSString *)self.dataSource.allValues[indexPath.row]).length > 0) {
       UIStoryboard *sd = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        UIViewController *vc = [sd instantiateViewControllerWithIdentifier:self.dataSource.allValues[indexPath.row]];
        if (!vc) {
            return;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }

}



- (NSDictionary *)dataSource {
    if (!_dataSource) {
        _dataSource = @{@"相册":@"ImagePickerViewController",
                        @"相机":@"TakingPictureViewController",
                        @"麦克风":@"",
                        @"位置":@"",
                        @"日历":@"",
                        @"提醒事项":@"",
                        @"运动与健身":@"",
                        @"健康更新":@"",
                        @"蓝牙":@"",
                        @"媒体资料库":@""
                        };
    }
    return _dataSource;
}

@end
