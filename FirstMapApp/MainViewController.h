//
//  ViewController.h
//  FirstMapApp
//
//  Created by SLA MacBook on 27/11/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "MBProgressHUD.h"
#import "SearchAddressController.h"
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController <AGSMapViewLayerDelegate,AGSMapViewTouchDelegate,AGSCalloutDelegate,CLLocationManagerDelegate,MBProgressHUDDelegate>{
    
    UIView* _loadingView;
    
        IBOutlet UIBarButtonItem *clear;
  
}
@property (nonatomic, retain) CLLocationManager	*locationManager;
@property (strong, nonatomic) IBOutlet UIButton *myLocation;
@property (nonatomic, copy) SearchAddressController *searchadd;
@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
- (IBAction)currentLocation:(id)sender;
- (IBAction)identify:(id)sender;
@property (nonatomic, strong) UIView* loadingView;
@property (nonatomic, weak) UILabel *popupLabel;
@property (nonatomic, weak) UILabel *routeLabel;
@property (nonatomic, weak) UILabel *distanceLabel;
@property (nonatomic, weak) UILabel *routeText;
- (IBAction)slideMenu:(id)sender;
- (IBAction)clearBtn:(id)sender;
@end
