//
//  SSAccessAlbum.h
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/22.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/*
 *  相册选取图片
 */

NS_ASSUME_NONNULL_BEGIN
typedef void(^ImagePickerCompletionBlock)(UIImage *image);

@interface SSAccessAlbum : NSObject
+ (instancetype)shareInstance;

- (void)getPhotoWithController:(UIViewController *)controller completion:(ImagePickerCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
