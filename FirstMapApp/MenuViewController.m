//
//  MenuViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 27/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "MenuViewController.h"
#import "ECSlidingViewController.h"
#import "MainViewController.h"
#import "SearchViewController.h"

@interface MenuViewController ()

@property (strong, nonatomic) NSArray *menu;
@property (strong, nonatomic) NSArray *imageArray;


@end

@implementation MenuViewController

@synthesize menu;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //CHANGE BACKGROUND COLOUR
    self.tableView.backgroundColor=[UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:1.0f];
    
    //CHANGE SEPARATOR COLOUR
    self.tableView.separatorColor = [UIColor colorWithRed:42/255.0f green:42/255.0f blue:42/255.0f alpha:1.0f];

    //NSARRAY THAT STORE NAME FOR SLIDE MENU
    self.menu = [NSArray arrayWithObjects:@"Address Search", @"Get Direction", @"Theme Search",@"Measure Distance",@"Measure Area", nil];
    
    //NSARRAY THAT STIRE IMAGENAME FOR SLIDE MENU
    self.imageArray = @[@"search.png", @"direction.png",@"theme.png",@"measure_length.png",@"measure_area.png"];
    
    //SET REVEAL AMOUNT FOR SLIDE MENU
    [self.slidingViewController setAnchorRightRevealAmount:220.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:[self.imageArray objectAtIndex:indexPath.row]];

    
    return cell;
}



//--------------------//
//WHEN YOU SELECT CELL//
//--------------------//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
       
    NSString *identifier = [NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]];
       
    
       [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{

           CGRect frame = self.slidingViewController.topViewController.view.frame;
           self.slidingViewController.topViewController.view.frame = frame;
           [self.slidingViewController resetTopView];
           
           //ONCLICK ADDRESS SEARCH CELL
           if([identifier isEqualToString:@"Address Search"]){
               
               [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToAddressSearch" object:@"addressSegue"];

           }
           
           //ONCLICK GET DIRECTION CELL
           else if([identifier isEqualToString:@"Get Direction"]){
               
               [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToGetDirection" object:self];
               
           }
           
           //ONCLICK THEME SEARCH CELL
           else if([identifier isEqualToString:@"Theme Search"]){

               [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToAddressSearch" object:@"themeSegue"];
               
           }
           
           //ONCLICK MEASURE DISTANCE CELL
           else if([identifier isEqualToString:@"Measure Distance"]){
           
               [[NSNotificationCenter defaultCenter] postNotificationName:@"calculateDistance" object:self];
           }
           
           //ONCLICK MEASURE DISTANCE CELL
           else if([identifier isEqualToString:@"Measure Area"]){
               
               [[NSNotificationCenter defaultCenter] postNotificationName:@"calculateArea" object:self];
           }

           
    }];
    
    
}

@end
