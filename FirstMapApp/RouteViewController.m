//
//  RouteViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 8/1/14.
//  Copyright (c) 2014 Singapore Land Authority. All rights reserved.
//

#import "RouteViewController.h"
#import "StaticObjects.h"

@interface RouteViewController ()

@end

@implementation RouteViewController

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
    
    //TESTING
    NSLog(@"ROUTEVIEW-%d",self.routeView);
    
    
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];

}



//-----------------------//
//NO. OF SECTION IN TABLE//
//-----------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger tempInt = 0;
    
    //CHECK IF SEGUE FROM GET DIRECTION VIEW OR PUBLIC TRANSPORT VIEW
    if (self.routeView == YES) {
        
        tempInt = [[StaticObjects getRouteDirection] count];

    }
    else if (self.routeView == NO){
        
        tempInt = [[StaticObjects getBusAlight] count];

    }
    
    // Return the number of sections.
    return tempInt;
}



//---------------------//
//NO. OF ROW IN SECTION//
//---------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}



//----------------------------//
//CONTENT OF CELL FOR EACH ROW//
//----------------------------//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"routeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    //DISPLAY TABLE INFOR FOR GET DIRECTION
    if (self.routeView == YES) {
        

        NSArray *container =@[[StaticObjects getRouteDirection],[StaticObjects getRouteDistance],[StaticObjects getRouteTime]];
    
        if(indexPath.row == 0){
        
            [cell.textLabel setText:[NSString stringWithFormat:@"Direction:\n%@",container[indexPath.row][indexPath.section]]];

        }
        else if(indexPath.row == 1){

            NSString *tempString = [NSString stringWithFormat:@"%@",(container[indexPath.row][indexPath.section])];
            float tempInt = [tempString floatValue];
    
            [cell.textLabel setText:[NSString stringWithFormat:@"Distance:\n%.2f Km",tempInt]];
    
        }
        else if(indexPath.row == 2){
        
            NSString *tempString = [NSString stringWithFormat:@"%@",(container[indexPath.row][indexPath.section])];
            float tempInt = ceil([tempString floatValue]);

        
            [cell.textLabel setText:[NSString stringWithFormat:@"Estimated Time:\n%.0f Min",tempInt]];
        
        }
        
    }
    //DISPLAY TABLE INFOR FOR PUBLIC TRANSPORT
    else if (self.routeView == NO) {
        
        
        NSArray *container =@[[StaticObjects getBusBoard],[StaticObjects getBusAlight],[StaticObjects getNoBusStop]];
        
        if(indexPath.row == 0){
            
            [cell.textLabel setText:[NSString stringWithFormat:@"Board At:\n%@\n%@ %@",container[indexPath.row][indexPath.section],[[StaticObjects getServiceType] objectAtIndex:indexPath.section],[[StaticObjects getServiceID] objectAtIndex:indexPath.section]]];
            
        }
        else if(indexPath.row == 1){
            
            
            [cell.textLabel setText:[NSString stringWithFormat:@"Alignt At:\n%@",container[indexPath.row][indexPath.section]]];
            
        }
        else if(indexPath.row == 2){
            
            
            [cell.textLabel setText:[NSString stringWithFormat:@"Total Stop:\n%@",container[indexPath.row][indexPath.section]]];
            
        }
        
    }
    
    cell.textLabel.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:15.0];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [[cell textLabel] setNumberOfLines:0];

        
        
    return cell;
}




//-------------//
//HEIGHT OF ROW//
//-------------//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}



//---------------------------------//
//SET TITLE HEADER FOR EACH SECTION//
//---------------------------------//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
    //CHECK FOR NULL
    if ([[NSString stringWithFormat:@"%@",[[StaticObjects getRouteType] objectAtIndex:section]] isEqualToString:@"(null)"]) {
        
        sectionName = [NSString stringWithFormat:@"Step %d",(section+1)];
        
    }
    else{
    
        sectionName = [NSString stringWithFormat:@"Step %d - %@",(section+1),[[StaticObjects getRouteType] objectAtIndex:section]];

    }
    
    return sectionName;
    
}



//------------------------------//
//WHEN U CLICK ON THE TABLE CELL//
//------------------------------//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


@end
