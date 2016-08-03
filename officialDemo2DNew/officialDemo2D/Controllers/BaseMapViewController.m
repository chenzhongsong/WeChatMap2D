//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"

@interface BaseMapViewController()

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, weak) UIButton *userLocationBtn;
@end

@implementation BaseMapViewController
@synthesize mapView = _mapView;
@synthesize search  = _search;

#pragma mark - Utility
-(void)dealloc {
//    [super dealloc];
    
//    NSLog(@"dealloc_self.userLocationBtn:%@",self.userLocationBtn);
}
- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
    
    [self.userLocationBtn removeFromSuperview];
//    NSLog(@"self.userLocationBtn:%@",self.userLocationBtn);
}

- (void)clearSearch
{
    self.search.delegate = nil;
}

/**
 *  hook,子类覆盖它,实现想要在viewDidAppear中执行一次的方法,搜索中有用到
 */
- (void)hookAction
{
    
}

#pragma mark - Handle Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearSearch];
}

#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%s: ,errInfo= %@", __func__, error);
}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
}

- (void)initSearch
{
    self.search.delegate = self;
}

- (void)initBaseNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(returnAction)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Handle URL Scheme

- (NSString *)getApplicationName
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo valueForKey:@"CFBundleDisplayName"] ?: [bundleInfo valueForKey:@"CFBundleName"];
}

- (NSString *)getApplicationScheme
{
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *URLTypes           = [bundleInfo valueForKey:@"CFBundleURLTypes"];
    
    NSString *scheme;
    for (NSDictionary *dic in URLTypes)
    {
        NSString *URLName = [dic valueForKey:@"CFBundleURLName"];
        if ([URLName isEqualToString:bundleIdentifier])
        {
            scheme = [[dic valueForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            break;
        }
    }
    
    return scheme;
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstAppear)
    {
        self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
        _isFirstAppear = NO;
        
        [self hookAction];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isFirstAppear = YES;
    
    [self initTitle:self.title];
    
    [self initBaseNavigationBar];
    
    [self initMapView];
    
    [self initSearch];
}


- (void)addUserLocation:(UIView *)parentView {
    
    if (_userLocationBtn == nil) {
        UIButton *userLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        userLocationBtn.frame = CGRectMake(self.mapView.bounds.size.width-54, self.mapView.bounds.size.height-54-64, 44, 44);
        userLocationBtn.backgroundColor = [UIColor blackColor];
        userLocationBtn.alpha = 0.5;
        //    userLocationBtn.clipsToBounds = YES;
        userLocationBtn.layer.masksToBounds = YES;
        userLocationBtn.layer.cornerRadius = 8;
        userLocationBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [userLocationBtn setTitle:@"定位" forState:UIControlStateNormal];
        [userLocationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [userLocationBtn setTitle:@"定位" forState:UIControlStateHighlighted];
        [userLocationBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [userLocationBtn addTarget:self action:@selector(userLocationAction:) forControlEvents:UIControlEventTouchUpInside];
        [parentView addSubview:userLocationBtn];
        self.userLocationBtn = userLocationBtn;
    }
    
}

- (void)userLocationAction:(id)seder {
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
}


@end
