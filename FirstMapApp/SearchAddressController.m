//
//  SearchAddressController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 5/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "MainViewController.h"
#import "SearchAddressController.h"
#import "StaticObjects.h"
#import "AddressSearch.h"
#import "ReverseGeocode.h"
#import "MBProgressHUD.h"


@interface SearchAddressController ()

@end

@implementation SearchAddressController{
    NSOperationQueue *queue;
    AddressSearch * address;
    ReverseGeocode * rev;
    MBProgressHUD *hud;

}



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
 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





//-----------------------//
//NO. OF SECTION IN TABLE//
//-----------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}




//---------------------//
//NO. OF ROW IN SECTION//
//---------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[StaticObjects getName] count];
}





//----------------------------//
//CONTENT OF CELL FOR EACH ROW//
//----------------------------//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
   cell.textLabel.text = [[StaticObjects getName] objectAtIndex:indexPath.row];
    
    return cell;
}




//------------------------------//
//WHEN U CLICK ON THE TABLE CELL//
//------------------------------//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    NSString * xPosition;
    NSString * yPosition;
    NSString * nameOfCell;
    
    //GET THE X , Y & CELLITEM COORDINATE OF THE PLACE THE USER SELECT
    xPosition = [[StaticObjects getX] objectAtIndex:(long)[indexPath row]];
    yPosition = [[StaticObjects getY] objectAtIndex:(long)[indexPath row]];
    nameOfCell = [[StaticObjects getName] objectAtIndex:(long)[indexPath row]];
    
    //SET X , Y & CELLITEM COORDINATE IN THE FORM OF NSSTRING
    [StaticObjects setXCoorrdinate:xPosition];
    [StaticObjects setYCoorrdinate:yPosition];
    [StaticObjects setNameOfAddress:nameOfCell];

    
    rev = [[ReverseGeocode alloc]init];
    [rev start:nil];
    
    //UNWIND SEGUE BACK TO MAIN PAGE (MAP PAGE)
    [self performSegueWithIdentifier:@"unwindToMainAfterSearch" sender:self];

    
    
}



//---------------------//
//SET LOADING INDICATOR//
//---------------------//
-(void)loading{
    
    //SET LOADING INDICATOR
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"Searching...";
    [self.view addSubview:hud];
    [hud show:YES];
    
}



@end
