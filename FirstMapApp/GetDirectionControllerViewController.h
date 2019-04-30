//
//  GetDirectionControllerViewController.h
//  FirstMapApp
//
//  Created by SLA MacBook on 12/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <ArcGIS/ArcGIS.h>

@interface GetDirectionControllerViewController : UITableViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *myLocation;
@property (strong, nonatomic) IBOutlet UITextField *destination;


- (IBAction)swapAction:(id)sender;


@end
