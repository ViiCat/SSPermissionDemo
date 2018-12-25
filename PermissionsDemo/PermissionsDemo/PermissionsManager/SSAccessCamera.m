//
//  SSAccessCamera.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/23.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "SSAccessCamera.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SSAccessCamera()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, copy) TakingPicturesCompletionBlock completionBlock;
@end

@implementation SSAccessCamera

+ (instancetype)shareInstance {
    static SSAccessCamera *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SSAccessCamera alloc] init];
    });
    return _instance;
}

- (void)getPhotoWithController:(UIViewController *)controller completion:(TakingPicturesCompletionBlock)completion {
    
#if TARGET_IPHONE_SIMULATOR //模拟器
    NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打开相机失败" message:@"模拟器中无法打开照相机,请在真机中使用" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:cancelAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
    
#elif TARGET_OS_IPHONE //真机
    if ([[SSAccessCamera shareInstance] judgeVideoInputAvailableWithController:controller]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = [SSAccessCamera shareInstance];
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [controller presentViewController:picker animated:YES completion:nil];
    }
#endif

}


#pragma mark 判断相机和摄像头授权情况
- (BOOL)judgeVideoInputAvailableWithController:(UIViewController *)controller {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    [[SSAccessCamera shareInstance] openSystemAuthorizeSetting:@"App获取相机权限被拒，请手动开启" withController:controller];
                }
            }];
            return NO;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [[SSAccessCamera shareInstance] openSystemAuthorizeSetting:@"App获取相机权限被拒，请手动开启" withController:controller];
            return NO;
        case AVAuthorizationStatusAuthorized:
            return YES;
        default:
            return YES;
    }
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
        
        if ([SSAccessCamera shareInstance].completionBlock) {
            [SSAccessCamera shareInstance].completionBlock(image);
        }
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
