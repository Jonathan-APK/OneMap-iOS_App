//
//  SearchViewController.h
//  FirstMapApp
//
//  Created by SLA MacBook on 23/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *search;
- (IBAction)searchDone:(id)sender;

@end
