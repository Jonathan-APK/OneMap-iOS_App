//
//  ThemeSearchViewController.h
//  FirstMapApp
//
//  Created by SLA MacBook on 30/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeSearchViewController : UITableViewController<UIPickerViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *themefield;
- (IBAction)doneBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *categoryfield;
@property (strong, nonatomic) NSMutableArray * themeIndex;
@property (strong, nonatomic) NSString *categoryText;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;


-(IBAction) segmentedControlIndexChanged;

@end
