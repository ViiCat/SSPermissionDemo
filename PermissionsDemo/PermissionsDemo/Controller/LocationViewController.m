//
//  LocationViewController.m
//  PermissionsDemo
//
//  Created by Liu Jie on 2018/12/30.
//  Copyright © 2018 JasonMark. All rights reserved.
//

#import "LocationViewController.h"
#import <MapKit/MapKit.h>

@interface LocationViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbLatitude;
@property (weak, nonatomic) IBOutlet UILabel *lbLongitude;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocation *userLocation;
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [SSCoreLocation shareInstance].delegate = self;
    self.mapView.delegate = self;
}

- (IBAction)startUpdateLocation:(id)sender {
    [[SSCoreLocation shareInstance] startUpdateLocaiton];
}

- (IBAction)stopUpdateLocation:(id)sender {
    [[SSCoreLocation shareInstance] stopUpdatingLocation];
}

- (IBAction)requestUpdateLocation:(id)sender {
    
    [[SSCoreLocation shareInstance] requestLocation];
}

#pragma mark - 自定义地址
bool isCustomLation = NO;
- (IBAction)customLocation:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"自定义地址" message:@"输入将要定位的地址" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入地址";
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[SSCoreLocation shareInstance] convertAddress:[alert.textFields firstObject].text competionHandler:^(NSArray<CLPlacemark *> * _Nonnull placemarks) {
            [self specifiedLocation:[placemarks lastObject].location];
        }];
    }];
    
    isCustomLation = YES;
    [alert addAction:action];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)specifiedLocation:(CLLocation *)location {
    
    self.userLocation = location;
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];

#if TARGET_IPHONE_SIMULATOR
    //模拟器
    if (!isCustomLation) {
        // http://www.gpsspg.com/maps.htm
        CLLocationDegrees latitude = 29.1230960000;
        CLLocationDegrees longitude = 110.4838220000;
        location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
#else
    //
#endif

    //街道地址信息
    [[SSCoreLocation shareInstance] convertLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nonnull placemarks) {
        
        [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            annotation.title = [NSString stringWithFormat:@"%@  %@  %@", obj.administrativeArea, obj.locality, obj.subLocality];
            annotation.subtitle = [NSString stringWithFormat:@"%@ %@", obj.thoroughfare, obj.subThoroughfare];
        }];
    }];
    

    [annotation setCoordinate:location.coordinate];
    //移除所有大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    //添加大头针
    [self.mapView addAnnotation:annotation];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, span);
    [self.mapView setRegion:region animated:YES];
    

    
    //更新界面经纬度
    self.lbLatitude.text = [NSString stringWithFormat:@"Latitude:%f", location.coordinate.latitude];
    self.lbLongitude.text = [NSString stringWithFormat:@"Longitude:%f", location.coordinate.longitude];
    
    isCustomLation = NO;
}

#pragma mark - 跳Apple导航
- (IBAction)navigator:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导航" message:@"message" preferredStyle:UIAlertControllerStyleActionSheet];
  
    UIAlertAction *appleMap = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //起点
        CLLocationCoordinate2D startCorrdinate = CLLocationCoordinate2DMake(29.1230960000, 110.4838220000);
        MKMapItem *startLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:startCorrdinate addressDictionary:nil]];

        //终点
        CLLocationCoordinate2D endCorrdinate = CLLocationCoordinate2DMake(self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude);
        MKMapItem *endLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCorrdinate addressDictionary:nil]];
        
        //默认驾车
        [MKMapItem openMapsWithItems:@[startLocation, endLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsMapTypeKey:[NSNumber numberWithInteger:MKMapTypeStandard],
                                       MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
    }];
    
    [alert addAction:appleMap];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - LocationDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //显示范围
    [self specifiedLocation:self.userLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error:%@", error.description);
}

#pragma mark - MapViewDelegate


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
