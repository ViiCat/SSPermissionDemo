//
//  SSAccessAlbum.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/22.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "SSAccessAlbum.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SSAccessAlbum()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, copy) ImagePickerCompletionBlock completionBlock;
@end

@implementation SSAccessAlbum
+ (instancetype)shareInstance {
    static SSAccessAlbum *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SSAccessAlbum alloc] init];
    });
    return _instance;
}

- (void)getPhotoWithController:(UIViewController *)controller completion:(ImagePickerCompletionBlock)completion {
    
    [SSAccessAlbum shareInstance].completionBlock = completion;

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = [SSAccessAlbum shareInstance];
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [controller presentViewController:picker animated:YES completion:nil];
}


#pragma mark 跳转系统设置
- (void)openSystemAuthorizeSetting:(NSString *)showText withController:(UIViewController *)controller {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:showText message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *set = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:set];
    [alertVC addAction:cancel];
    [controller presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark 判断相机和摄像头授权情况
- (BOOL)judgeVideoInputAvailableWithController:(UIViewController *)controller {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    [[SSAccessAlbum shareInstance] openSystemAuthorizeSetting:@"App获取相机权限被拒，请手动开启" withController:controller];
                }
            }];
            return NO;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [[SSAccessAlbum shareInstance] openSystemAuthorizeSetting:@"App获取相机权限被拒，请手动开启" withController:controller];
            return NO;
        case AVAuthorizationStatusAuthorized:
            return YES;
        default:
            return YES;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转成NSData
        UIImage *image = [info
                          objectForKey:
                          @"UIImagePickerControllerEditedImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1.0);
        } else {
            data = UIImagePNGRepresentation(image);
        }
        
        if ([SSAccessAlbum shareInstance].completionBlock) {
            [SSAccessAlbum shareInstance].completionBlock(image);
        }
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
