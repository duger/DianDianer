//
//  MapViewController.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomMapCell.h"
#import "CallOutAnnotation.h"
#import "CallOutAnnotationView.h"
#import "DefaultAnnotation.h"
#import "PopInfoCell.h"





@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,CustomMapDelegate,PopInfoDelegate>
{
    NSMutableArray *_annotationList;
    CallOutAnnotation *_calloutAnnotation;
	CallOutAnnotation *_previousdAnnotation;
}

+(MapViewController *)defaulite;

@property (strong, nonatomic) IBOutlet MKMapView       *aMapView;
@property (strong, nonatomic) CLLocationManager        *aLocationManager;
@property (strong, nonatomic) CLLocation               *aCurrentLocation;        //当前位置
@property (assign, nonatomic) CLLocationCoordinate2D   selectLocation;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (copy, nonatomic) NSString *title;
- (IBAction)didClickBack:(UIBarButtonItem *)sender;
-(NSString *)getLocationFromCoordinatesLatitude:(double)latitude andLongitude:(double)longitude;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;



@end

