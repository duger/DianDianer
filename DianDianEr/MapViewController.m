//
//  MapViewController.m
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PopInfoCell.h"
#import "ShareManager.h"
#import "Singleton.h"


@interface MapViewController ()
{
    PopInfoCell  *popCell;
    NSString *locationName ;

}

@end

@implementation MapViewController
@synthesize aMapView;
@synthesize aLocationManager;
@synthesize aCurrentLocation;
@synthesize selectLocation;
static MapViewController *s_mapViewController = nil;
+(MapViewController *)defaulite
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_mapViewController == nil) {
            s_mapViewController = [[MapViewController alloc]init];
        }
    });
    return s_mapViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"地图";
    if (IS_IPHONE5) {
        self.topView.frame = CGRectMake(0, 20, 320,44);
        aMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 20, 320, ScreenHeight)];
    }else{
    self.topView.frame = CGRectMake(0, 0, 320, 44);
        aMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, ScreenHeight)];
    }
    self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topviewBackground.png"]];
    
    if ([Singleton instance].mapInRight) {
        self.topView.hidden = YES;
         [aMapView setFrame:CGRectMake(0, 0, 320, ScreenHeight)];
    }
    
    
    
    /*
    aLocationManager = [[CLLocationManager alloc] init];
    aLocationManager.desiredAccuracy = kCLLocationAccuracyBest;//精准度
    aLocationManager.distanceFilter = 1000.0f;//移动距离
    aLocationManager.delegate = self;
    [aLocationManager startUpdatingLocation];
     */
    
    
    [self.view insertSubview:aMapView belowSubview:self.topView];
    aMapView.delegate = self;
    aMapView.showsUserLocation = YES;
    [aMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(popViewInfo:)];

    [aMapView addGestureRecognizer:longPress];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setAMapView:nil];
    [self setAMapView:nil];
    [self setTopView:nil];
    [self setBackBtn:nil];
    [super viewDidUnload];
}

- (NSString *)tabImageName
{
	return @"image-3";
}

- (NSString *)tabTitle
{
	return @"地图";
}

/*
#pragma mark CLLocationManagerDelegate代理
- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    */
    //模拟数据
   /*
    NSDictionary *dic1=[NSDictionary dictionaryWithObjectsAndKeys:@"40.181843",@"latitude",@"116.102193",@"longitude",nil];
    NSDictionary *dic2=[NSDictionary dictionaryWithObjectsAndKeys:@"40.290144",@"latitude",@"116.246696‎",@"longitude",nil];
    NSDictionary *dic3=[NSDictionary dictionaryWithObjectsAndKeys:@"40.348076",@"latitude",@"116.364162‎",@"longitude",nil];
    NSDictionary *dic4=[NSDictionary dictionaryWithObjectsAndKeys:@"40.425622",@"latitude",@"116.499605",@"longitude",nil];
    NSDictionary *dic5=[NSDictionary dictionaryWithObjectsAndKeys:@"40.581843",@"latitude",@"116.502193",@"longitude",nil];
    NSDictionary *dic6=[NSDictionary dictionaryWithObjectsAndKeys:@"40.690144",@"latitude",@"116.646696‎",@"longitude",nil];
    NSDictionary *dic7=[NSDictionary dictionaryWithObjectsAndKeys:@"40.748076",@"latitude",@"116.764162‎",@"longitude",nil];
    NSDictionary *dic8=[NSDictionary dictionaryWithObjectsAndKeys:@"40.825622",@"latitude",@"116.899605",@"longitude",nil];
    
    NSArray *array = [NSArray arrayWithObjects:dic1,dic2,dic3,dic4,dic5,dic6,dic7,dic8,nil];
    for (NSDictionary *dic in array) {
        
        CLLocationDegrees latitude = [[dic objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[dic objectForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location,0.005 ,0.005 );
        MKCoordinateRegion adjustedRegion = [aMapView regionThatFits:region];
        [aMapView setRegion:adjustedRegion animated:YES];
        
        DefaultAnnotation *  annotation=[[DefaultAnnotation alloc] initWithLatitude:latitude andLongitude:longitude]  ;
        [aMapView   addAnnotation:annotation];
    }
    */
/*
    aCurrentLocation = [locations lastObject];
    [aMapView setRegion:MKCoordinateRegionMake(aCurrentLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005)) animated:YES];
    
    aMapView.centerCoordinate = aCurrentLocation.coordinate;
  
#pragma mark - 我在 接口1
    NSLog(@"当前经度:%f 纬度:%f",aCurrentLocation.coordinate.latitude,aCurrentLocation.coordinate.longitude);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:aCurrentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       for (CLPlacemark *placemark in placemarks) {
                           NSString *country =[placemark.addressDictionary objectForKey:@"Country"];
                           NSString *state  = [placemark.addressDictionary objectForKey:@"State"];
                           NSString *subLocality = [placemark.addressDictionary objectForKey:@"SubLocality"];
                           NSString *street = [placemark.addressDictionary objectForKey:@"Street"];
                           NSString *name = [placemark.addressDictionary objectForKey:@"Name"];
#pragma mark - 我在 接口2
                           NSLog(@"当前具体位置:%@, %@, %@, %@, %@",country,state,subLocality,street,name);
//                           NSString *location = [[subLocality stringByAppendingString:street]stringByAppendingString:name];
                           [ShareManager defaultManager].locationPlace = name;
                       }
                   }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"下载地图出错" delegate:nil cancelButtonTitle:@"back" otherButtonTitles:nil];
    [alertView show];
}
*/
#pragma mark MKMapViewDelegate代理
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CallOutAnnotation class]]) {
        CallOutAnnotationView *annotationView = (CallOutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutView"];
        if (!annotationView) {
            annotationView = [[CallOutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CalloutView"] ;
            CustomMapCell  *cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomMapCell" owner:self options:nil] objectAtIndex:0]
            ;
            cell.chageTitle.text = @"数据接口1";
            cell.changeSubtitle.text = @"数据接口2";
            cell.imageView.image = [UIImage imageNamed:@"save"];
    
            [annotationView.contentView addSubview:cell];
            [cell setDelegate:self];
        return annotationView;
	} else if ([annotation isKindOfClass:[DefaultAnnotation class]]) {
        MKAnnotationView *annotationView =[aMapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotation"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomAnnotation"];
            annotationView.canShowCallout = NO;
            annotationView.image = [UIImage imageNamed:@"tag_1.png"];
        }
		
		return annotationView;
    }
         }
	return nil;
   
    
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[DefaultAnnotation class]])
    {
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude)
        {
            return;
        }
        if (_calloutAnnotation) {
            [mapView removeAnnotation:_calloutAnnotation];
            _calloutAnnotation = nil;
        }
        _calloutAnnotation = [[CallOutAnnotation alloc]
                               initWithLatitude:view.annotation.coordinate.latitude
                               andLongitude:view.annotation.coordinate.longitude];
        [mapView addAnnotation:_calloutAnnotation];
        
        [mapView setCenterCoordinate:_calloutAnnotation.coordinate animated:YES];
	}
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (_calloutAnnotation&& ![view isKindOfClass:[CallOutAnnotationView class]]) {
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
            [mapView removeAnnotation:_calloutAnnotation];
            _calloutAnnotation = nil;
        }
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D coordinate = userLocation.coordinate;
    [aMapView setCenterCoordinate:coordinate animated:YES];
    
    [aMapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05, 0.05)) animated:YES];
    
    
//    aMapView.centerCoordinate = aCurrentiLocation.coordinate;
    
#pragma mark - 我在 接口1
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       for (CLPlacemark *placemark in placemarks) {
                           NSString *country =[placemark.addressDictionary objectForKey:@"Country"];
                           NSString *state  = [placemark.addressDictionary objectForKey:@"State"];
                           NSString *subLocality = [placemark.addressDictionary objectForKey:@"SubLocality"];
                           NSString *street = [placemark.addressDictionary objectForKey:@"Street"];
                           NSString *name = [placemark.addressDictionary objectForKey:@"Name"];
#pragma mark - 我在 接口2
                           NSLog(@"当前具体位置:%@, %@, %@, %@, %@",country,state,subLocality,street,name);
                           //                           NSString *location = [[subLocality stringByAppendingString:street]stringByAppendingString:name];
                           [ShareManager defaultManager].locationPlace = name;
                       }
                   }];
    

}
-(void)buttonChange1:(UIButton *)btn;
{
    NSLog(@"按钮改变1");
}
-(void)buttonChange2:(UIButton *)btn;
{
    NSLog(@"按钮改变2");
}
/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSArray *touchArray = [touches allObjects];
    for (UITouch *touch in touchArray) {
        CGPoint current = [touch locationInView:self.aMapView];
        NSLog(@"%f,%f",current.x,current.y);
     selectLocation = [aMapView convertPoint:current toCoordinateFromView:aMapView];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![aMapView becomeFirstResponder] ) {
        [popCell removeFromSuperview];
    }
 }
*/

- (IBAction)didClickBack:(UIBarButtonItem *)sender
{
    [Singleton instance].mapInRight = YES;
    
    [self dismissModalViewControllerAnimated:YES];
    
}
- (void)popViewInfo:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        
        [popCell removeFromSuperview];
        
        selectLocation = aMapView.userLocation.coordinate;
        
        popCell = [[[NSBundle mainBundle] loadNibNamed:@"PopInfoCell" owner:self options:nil] objectAtIndex:0];
        popCell.frame = CGRectMake(0, ScreenHeight - 50, 320, 50);
        
        popCell.label4.text = [NSString stringWithFormat:@"所选位置:（%f, %f）",selectLocation.latitude,selectLocation.longitude];
        popCell.label4.font = [UIFont systemFontOfSize:10.0];
        popCell.label4.textColor = [UIColor blueColor];
        [popCell setDelegate:self];

        popCell.backgroundColor = [UIColor grayColor];
        popCell.alpha = 0.7f;
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5f;
        animation.delegate = self;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromTop;
        
        [[popCell layer] addAnimation:animation forKey:nil];
        [aMapView addSubview:popCell];
    }
}

-(void)bt1
{
    NSLog(@"预留按钮");

}

-(void)bt2
{
    NSLog(@"投掷接口 %f  % f", selectLocation.latitude,
          selectLocation.longitude);
    [ShareManager defaultManager].latitude = selectLocation.latitude;
    [ShareManager defaultManager].longitude = selectLocation.longitude;
    [self dismissViewControllerAnimated:YES completion:nil];
    [Singleton instance].mapInRight = YES;
}
@end
