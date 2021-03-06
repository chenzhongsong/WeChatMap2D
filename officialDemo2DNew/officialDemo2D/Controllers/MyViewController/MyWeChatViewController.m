//
//  MyWeChatViewController.m
//  officialDemo2D
//
//  Created by eliteall on 16/8/2.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MyWeChatViewController.h"
#import "GeocodeAnnotation.h"
#import "MyAddressInfoCell.h"

@interface MyWeChatViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) CGFloat mapView_height;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *centerPointImgView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) AMapReGeocode *regeocode; //!< 逆地理编码结果   用strong还是weak
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong)UITableViewCell *frontClickCell;//前面点击的cell
@property (nonatomic, copy)   NSString     *uid;
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
    
    self.centerPointImgView.image = [UIImage imageNamed:@"locate"];
}

- (void)createReGeocodeSearch {
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:self.location.latitude longitude:self.location.longitude];
    regeo.radius = 3000;
    regeo.requireExtension = YES;
    
    //发起逆地理编码
    [self.search AMapReGoecodeSearch: regeo];
}

- (void)createGeocodeSearch {
    //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = self.address;
    
    //发起正向地理编码
    [self.search AMapGeocodeSearch: geo];
}

- (void)initObservers
{
    /* Add observer for location. */
    [self addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - NSKeyValueObservering

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"location"])
    {
        [self createReGeocodeSearch];
    }
}


#pragma mark - 重写方法
#pragma mark - 不用了，要清除。在这里，任何添加在mapView上的对象都要清除
/**
 *  不用了 要清除
 */
-(void)returnAction {
    [super returnAction];
    
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
    [self.centerPointImgView removeFromSuperview];
    
    [self removeObserver:self forKeyPath:@"location"];
    
}

//- (void)hookAction {
//    [self createReGeoCodeSearch];
//}

#pragma mark - MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude : %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        //latitude : 31.183884,longitude : 121.585403//公司
        //latitude : 31.051420,longitude : 121.759865//家
        //self.location = userLocation.coordinate;
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

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
//        NSLog(@"ReGeo: %@", result);
        
        AMapReGeocode *reGeocode = response.regeocode;
//        NSLog(@"reGeocode: %@", reGeocode);
        self.regeocode = reGeocode;
        
        NSString *formattedAddress = reGeocode.formattedAddress;
        NSLog(@"formattedAddress: %@", formattedAddress);
        NSLog(@"district:%@,township:%@,neighborhood:%@,building:%@,citycode:%@,adcode:%@",reGeocode.addressComponent.district,reGeocode.addressComponent.township,reGeocode.addressComponent.neighborhood,reGeocode.addressComponent.building,reGeocode.addressComponent.citycode,reGeocode.addressComponent.adcode);
        NSArray *pois = reGeocode.pois;
        NSArray *aois = reGeocode.aois;
//        NSLog(@"pois:%@",pois);
//        NSLog(@"aois:%@",aois);
        
        
        
        [self.tableView reloadData];
    }
    
}

//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0)
    {
        return;
    }
    
//    NSLog(@"%lu",(unsigned long)response.geocodes.count);
    
    if (response.geocodes.count == 1) {
        AMapGeocode *geocode = [response.geocodes firstObject];
        NSLog(@"%f,%f",geocode.location.latitude,geocode.location.longitude);
        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:geocode];
        NSLog(@"%f,%f",geocodeAnnotation.coordinate.latitude,geocodeAnnotation.coordinate.longitude);
        [self.mapView setCenterCoordinate:geocodeAnnotation.coordinate animated:YES];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"response.geocodes.count ！= 1" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}


#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.regeocode.pois.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"mapViewCellId";
    MyAddressInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell= [[[NSBundle mainBundle] loadNibNamed:@"MyAddressInfoCell" owner:nil options:nil] firstObject];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = self.regeocode.formattedAddress;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.numberOfLines = 0;
        cell.titleLab.text = @"";
        cell.subTitleLab.text = @"";
    } else {
        AMapPOI *POI = self.regeocode.pois[indexPath.row-1];
        cell.titleLab.text = POI.name;
        cell.subTitleLab.text = POI.address;
    }
    
    
    /**
     *  解决cell复用 用POI.address == self.address判断时不准确，address可能出现一样的情况
     */
//    if (self.frontClickCell && self.address && self.uid) {
////        NSLog(@"\nself.uid:%@\nPOI.uid:%@",self.uid,POI.uid);
//        if (cell == self.frontClickCell && POI.uid == self.uid) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.frontClickCell) {
        self.frontClickCell.accessoryType = UITableViewCellAccessoryNone;
    }
    AMapPOI *POI = self.regeocode.pois[indexPath.row];
    self.address = POI.address;
    self.uid = POI.uid;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.frontClickCell = cell;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self createGeocodeSearch];
    NSLog(@"geocode:%f,%f",POI.location.latitude,POI.location.longitude);
     
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
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
    
    [self initObservers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self.mapView setZoomLevel:16.10 animated:YES];
    
    
    CLLocationCoordinate2D location = [self.mapView convertPoint:self.centerPointImgView.center toCoordinateFromView:self.mapView];
    NSLog(@"center_latitude : %f,center_longitude : %f",location.latitude,location.longitude);
    //40.100516,longitude:116.405272
    self.location = location;
    
//    [self hookAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
