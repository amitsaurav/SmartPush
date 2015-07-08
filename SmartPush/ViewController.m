//
//  ViewController.m
//  SmartPush
//
//  Created by Saurav, Amit on 7/1/15.
//  Copyright (c) 2015 Saurav, Amit. All rights reserved.
//

#import "ViewController.h"
#import "ServiceHelper.h"

@interface ViewController () {
    CLLocationManager *locationManager;
    CLRegion *geoRegion;
    CLLocation *center;
    CLLocation *userLocation;
    NSString *regionId;
    CGFloat latitude;
    CGFloat longitude;
    CGFloat radius;
    __weak IBOutlet UITextView *logArea;
    __weak IBOutlet MKMapView *mapView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];

    latitude = 47.6235755f;
    longitude = -122.339806f;
    radius = 225;
    regionId = @"fence1";
    center = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    geoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(latitude, longitude)
                                                  radius:radius
                                              identifier:regionId];
    mapView.delegate = self;

    for (CLRegion *region in [locationManager monitoredRegions]) {
        [locationManager stopMonitoringForRegion:region];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)refreshFenceStatus:(id)sender {
    [locationManager requestStateForRegion:geoRegion];
}

- (void) createGeo {
    [locationManager startMonitoringForRegion:geoRegion];
    [self setupMap];
}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSString *stateString = @"";
    if (state == CLRegionStateInside) {
        stateString = @"INSIDE";
    } else if (state == CLRegionStateOutside){
        stateString = @"OUTSIDE";
    } else {
        stateString = @"UNKNOWN";
    }
    CGFloat distance = [center distanceFromLocation:userLocation];

    [self addLog:[NSString stringWithFormat:@"You are: %@ with distance: %g mt from center.", stateString, distance]];
    [[ServiceHelper sharedInstance] logText:[NSString stringWithFormat:@"status_%@_%g", stateString, distance]];

}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self addLog:[NSString stringWithFormat:@"Started monitoring region: %@", region]];
    [[ServiceHelper sharedInstance] logText:@"Started_monitoring_region"];
}
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [self addLog:[NSString stringWithFormat:@"Failed monitoring region: %@", region]];
}
- (void) removeGeo {
    [locationManager stopMonitoringForRegion:geoRegion];
    [self addLog:[NSString stringWithFormat:@"Stopped monitoring region: %@", geoRegion]];
}
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self addLog:[NSString stringWithFormat:@"Entered region: %@", geoRegion]];
    [[ServiceHelper sharedInstance] logText:@"entered_region"];
    [self sendLocalNotification];
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self addLog:[NSString stringWithFormat:@"Exited region: %@", geoRegion]];
    [[ServiceHelper sharedInstance] logText:@"exited_region"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    userLocation = [locations lastObject];
    if ([[locationManager monitoredRegions] count] == 1) {
        [locationManager requestStateForRegion:geoRegion];
    }
}

- (void) sendLocalNotification {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:regionId]) {
        [self persistState];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"Woohoo! The truck is nearby!";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void) persistState {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:regionId]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:regionId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (IBAction)clearNotificationFlag:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:regionId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) addLog:(NSString *) text {
    logArea.text = [NSString stringWithFormat:@"%@\n%@", logArea.text, text];
}

- (void) setupMap {
    MKCoordinateRegion region;
    region.center.latitude = latitude;
    region.center.longitude = longitude;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;

    MKCoordinateRegion scaledRegion = [mapView regionThatFits:region];
    [mapView setRegion:scaledRegion animated:YES];

    MKPointAnnotation *centerPin = [[MKPointAnnotation alloc] init];
    centerPin.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    centerPin.title = @"Center";
    centerPin.subtitle = @"Geofence center";
    [mapView addAnnotation:centerPin];

    MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius:radius];
    [circleOverlay setTitle:@"Geofence Radius"];
    [mapView addOverlay:circleOverlay];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer* aRenderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];

        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 2;
        return aRenderer;
    }else{
        return nil;
    }
}

@end
