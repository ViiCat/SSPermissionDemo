//
//  SSCoreLocation.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/30.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "SSCoreLocation.h"

@interface SSCoreLocation()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation SSCoreLocation
+ (instancetype)shareInstance {
    static SSCoreLocation *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[SSCoreLocation alloc] init];
        }

    });
    return _instance;
}

- (void)startUpdateLocaiton {
    [self examinAvailable];
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self examinAvailable];
    [self.locationManager stopUpdatingLocation];
}

- (void)requestLocation {
    [self examinAvailable];
    [self.locationManager requestLocation];
}

- (void)examinAvailable {

    // 请求访问授权
    [self.locationManager requestWhenInUseAuthorization];
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusDenied:
            /// 未选择过
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@">>>>>>>");
            } else {
                NSLog(@"<<<<<<<");
            }
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@">>>>>>>");
            } else {
                NSLog(@"<<<<<<<");
            }
            break;

        default:
            break;
    }
}

#pragma mark - Setter
- (void)setDelegate:(id<CLLocationManagerDelegate>)delegate {
    _delegate = delegate;
    self.locationManager.delegate = delegate;
}

#pragma mark - Convert
- (void)convertLocation:(CLLocation *)location completionHandler:(void (^)(NSArray<CLPlacemark *> * _Nonnull))completion {
    
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        completion(placemarks);
    }];
}

- (void)convertAddress:(NSString *)address competionHandler:(void (^)(NSArray<CLPlacemark *> * _Nonnull))completion {
    
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    [geo geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        completion(placemarks);
    }];
}

#pragma mark - LazyLoad
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = 100;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

@end
