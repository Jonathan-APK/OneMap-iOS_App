//
//  TESTViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 27/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "MainNavigationViewController.h"
#import "MainViewController.h"

@interface MainNavigationViewController ()

@end

@implementation MainNavigationViewController

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
    MainViewController *main = [[MainViewController alloc]init];
    [super viewDidLoad];
    [self.navigationController pushViewController:main animated:YES];
   // [self.navigationController.navigationBar setTintColor:[UIColor yellowColor]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
