//
//  SearchAddressForRouteViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 27/1/14.
//  Copyright (c) 2014 Singapore Land Authority. All rights reserved.
//

#import "SearchAddressForRouteViewController.h"
#import "StaticObjects.h"
#import "GetDirectionControllerViewController.h"

@interface SearchAddressForRouteViewController ()

@end

@implementation SearchAddressForRouteViewController

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
    // Return the number of sections.
    return 1;
}


//---------------------//
//NO. OF ROW IN SECTION//
//---------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
     return [[StaticObjects getName] count];
}


//----------------------------//
//CONTENT OF CELL FOR EACH ROW//
//----------------------------//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchAddressRoute";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[StaticObjects getName] objectAtIndex:indexPath.row];

    return cell;
}


//------------------//
//WHEN U SELECT CELL//
//------------------//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * xPosition;
    NSString * yPosition;
    NSString * nameOfCell;
    
    //GET THE X , Y & CELLITEM COORDINATE OF THE CELL THE USER SELECT
    xPosition = [[StaticObjects getX] objectAtIndex:(long)[indexPath row]];
    yPosition = [[StaticObjects getY] objectAtIndex:(long)[indexPath row]];
    nameOfCell = [[StaticObjects getName] objectAtIndex:(long)[indexPath row]];
    
    
    //--------------------------------------------------//
    //UPDATE TEXTFIELD FOR GET DIRECTION AFTER SELECTING//
    //--------------------------------------------------//
    if ([[self.pushFrom objectAtIndex:0] isEqualToString:@"direction"]) {
        
        if ([[self.pushFrom objectAtIndex:1] isEqualToString:@"mylocation"]) {
            
            if ([StaticObjects getSwapRouteStatusForDirection] == NO) {
             
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setStartDirectionX:xPosition];
                [StaticObjects setStartDirectionY:yPosition];
                
            }
            else {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setEndDirectionX:xPosition];
                [StaticObjects setEndDirectionY:yPosition];
                
            }
            
            
        }
        else if([[self.pushFrom objectAtIndex:1] isEqualToString:@"destination"]){
         
            if ([StaticObjects getSwapRouteStatusForDirection] == NO) {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setEndDirectionX:xPosition];
                [StaticObjects setEndDirectionY:yPosition];
                
            }
            else {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setStartDirectionX:xPosition];
                [StaticObjects setStartDirectionY:yPosition];
                
            }

            
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTextFieldForGetDirection" object:nameOfCell];
    
    }
    
    
    //-----------------------------------------------------//
    //UPDATE TEXTFIELD FOR PUBLIC TRANSPORT AFTER SELECTING//
    //-----------------------------------------------------//
    else if ([[self.pushFrom objectAtIndex:0] isEqualToString:@"publictransport"]) {
        
        if ([[self.pushFrom objectAtIndex:1] isEqualToString:@"mylocation"]) {
            
            if ([StaticObjects getSwapRouteStatusForPublic] == NO) {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setStartPublicX:xPosition];
                [StaticObjects setStartPublicY:yPosition];
                
            }
            else {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setEndPublicX:xPosition];
                [StaticObjects setEndPublicY:yPosition];
                
            }
            
            
        }
        else if([[self.pushFrom objectAtIndex:1] isEqualToString:@"destination"]){
            
            if ([StaticObjects getSwapRouteStatusForPublic] == NO) {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setEndPublicX:xPosition];
                [StaticObjects setEndPublicY:yPosition];
                
            }
            else {
                
                //SET X , Y COORDINATE IN THE FORM OF NSSTRING
                [StaticObjects setStartPublicX:xPosition];
                [StaticObjects setStartPublicY:yPosition];
                
            }
            
            
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTextFieldForPublicTransport" object:nameOfCell];
        
    }
    
    //UNWIND SEGUE BACK TO MAIN PAGE (MAP PAGE)
    [self performSegueWithIdentifier:@"searchtogetdirection" sender:self];
}



//-----------//
//BACK BUTTON//
//-----------//
- (IBAction)backButton:(id)sender {
    
        [self performSegueWithIdentifier:@"searchtogetdirection" sender:self];
    
}




@end
