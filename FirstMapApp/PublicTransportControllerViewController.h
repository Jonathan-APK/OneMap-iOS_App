//
//  PublicTransportControllerViewController.h
//  FirstMapApp
//
//  Created by SLA MacBook on 18/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicTransportControllerViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *myLocation;
@property (strong, nonatomic) IBOutlet UITextField *destination;

- (IBAction)swapAction:(id)sender;
@end
