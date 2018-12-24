//
//  ImagePickerViewController.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/23.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "SSAccessAlbum.h"

@interface ImagePickerViewController ()

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)imagePickerAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    [[SSAccessAlbum shareInstance] getPhotoWithController:self completion:^(UIImage * _Nonnull image) {
        weakSelf.img.image = image;
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
