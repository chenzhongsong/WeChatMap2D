//
//  MyWeChatViewController.m
//  officialDemo2D
//
//  Created by eliteall on 16/8/2.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MyWeChatViewController.h"


@interface MyWeChatViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) CGFloat mapView_height;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *centerPointImgView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@end

@implementation MyWeChatViewController

#pragma mark - create
/**
 *  方法名不能和父类.m文件里的方法名一样  否则会产生影响 如：[self initMapView];
 */
- (void)createMapView_frame {
    self.mapView_height = CGRectGetHeight(self.view.frame)/2;
    self.mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.mapView_height);
    
}
- (void)createTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-64, self.view.bounds.size.width, self.mapView_height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)createMapViewCenterPoint {
    self.centerPointImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    self.centerPointImgView.center = CGPointMake(CGRectGetWidth(self.mapView.frame)/2, CGRectGetHeight(self.mapView.frame)/2-32);
    self.centerPointImgView.alpha = 0.5;
    self.centerPointImgView.clipsToBounds = YES;
    self.centerPointImgView.layer.cornerRadius = 10;
    self.centerPointImgView.backgroundColor = [UIColor redColor];
    [self.mapView addSubview:self.centerPointImgView];
    
}

- (void)createReGeoCodeSearch {
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:self.location.latitude longitude:self.location.longitude];
    regeo.radius = 10000;
    regeo.requireExtension = YES;
    
    //发起逆地理编码
    [self.search AMapReGoecodeSearch: regeo];
}

/**
 *  不用了 要清除
 */
-(void)returnAction {
    [super returnAction];
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    [self.centerPointImgView removeFromSuperview];
}

#pragma mark - MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        //NSLog(@"latitude : %f,longitude : %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        //latitude : 31.183884,longitude : 121.585403
    }
}
//地图移动结束后调用此接口
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        CLLocationCoordinate2D location = [self.mapView convertPoint:self.centerPointImgView.center toCoordinateFromView:self.mapView];
        NSLog(@"move_latitude : %f,move_longitude : %f",location.latitude,location.longitude);
        self.location = location;
    }
}
//地图区域改变完成后会调用此接口
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (animated) {
        CLLocationCoordinate2D location = [self.mapView convertPoint:self.centerPointImgView.center toCoordinateFromView:self.mapView];
        NSLog(@"region_latitude : %f,region_longitude : %f",location.latitude,location.longitude);
        self.location = location;
    }
}
//地图缩放结束后调用此接口
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
    if (wasUserAction) {
        CLLocationCoordinate2D location = [self.mapView convertPoint:self.centerPointImgView.center toCoordinateFromView:self.mapView];
        NSLog(@"Zoom_latitude : %f,Zoom_longitude : %f",location.latitude,location.longitude);
        self.location = location;
        
    }
}


#pragma mark - AMapSearchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    
    
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"mapViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createMapView_frame];
    [self createTableView];
    
    [self addUserLocation:self.mapView];
    
    [self createMapViewCenterPoint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self.mapView setZoomLevel:16.1 animated:YES];
    
    
    CLLocationCoordinate2D location = [self.mapView convertPoint:self.centerPointImgView.center toCoordinateFromView:self.mapView];
    NSLog(@"center_latitude : %f,center_longitude : %f",location.latitude,location.longitude);
    //40.100516,longitude:116.405272
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
