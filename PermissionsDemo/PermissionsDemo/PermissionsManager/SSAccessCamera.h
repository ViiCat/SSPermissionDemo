//
//  SSAccessCamera.h
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/23.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/*
 * 相机拍摄获取图片
 */

NS_ASSUME_NONNULL_BEGIN
typedef void(^TakingPicturesCompletionBlock)(UIImage *image);

@interface SSAccessCamera : NSObject
+ (instancetype)shareInstance;

- (void)getPhotoWithController:(UIViewController *)controller completion:(TakingPicturesCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
