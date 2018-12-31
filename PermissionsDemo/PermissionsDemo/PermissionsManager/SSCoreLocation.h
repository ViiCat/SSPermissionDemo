//
//  SSCoreLocation.h
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/30.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  位置信息
 */
NS_ASSUME_NONNULL_BEGIN

@interface SSCoreLocation : NSObject
@property (nonatomic, weak) id<CLLocationManagerDelegate>delegate;
+ (instancetype)shareInstance;

- (void)startUpdateLocaiton;
- (void)stopUpdatingLocation;
- (void)requestLocation;

#pragma mark - Convert
// 用经纬度获取城市街道地址
- (void)convertLocation:(CLLocation *)location completionHandler:(void(^)(NSArray<CLPlacemark *> *placemarks))completion;

// 用城市街道获取经纬度
- (void)convertAddress:(NSString *)address competionHandler:(void(^)(NSArray<CLPlacemark *> *placemarks))completion;
@end

NS_ASSUME_NONNULL_END
