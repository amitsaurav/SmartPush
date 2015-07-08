//
//  ViewController.h
//  SmartPush
//
//  Created by Saurav, Amit on 7/1/15.
//  Copyright (c) 2015 Saurav, Amit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>

- (void) createGeo;

@end

