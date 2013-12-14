//
//  DefaultAnnotation.h
//  DianDianEr
//
//  Created by 信徒 on 13-10-30.
//  Copyright (c) 2013年 王超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DefaultAnnotation : NSObject<MKAnnotation>
{
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
	NSString *_title;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end


