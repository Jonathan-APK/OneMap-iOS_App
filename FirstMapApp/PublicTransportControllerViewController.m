//
//  PublicTransportControllerViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 18/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "PublicTransportControllerViewController.h"
#import "MBProgressHUD.h"
#import "StaticObjects.h"
#import "PublicTransport.h"
#import "AddressSearch.h"
#import "SearchAddressForRouteViewController.h"

@interface PublicTransportControllerViewController (){
     BOOL Mode;
     BOOL publicRoute;
     MBProgressHUD *hud;
     NSString * selectedField;
     NSOperationQueue *queue;
     PublicTransport * pt;
     AddressSearch *address;
     NSString * startName;
     NSString * endName;
     NSMutableArray * pushArray;


}

@end

@implementation PublicTransportControllerViewController

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

    
    //SET NOTIFICATION
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"waitForPublicTransport"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publicTransportDone:) name:@"waitForPublicTransport" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publicTransportDone:) name:@"clickdonepublic" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLoading:) name:@"stoploading" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchDone:) name:@"searchAPIDoneForPublicTransport" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextField:) name:@"updateTextFieldForPublicTransport" object:nil];

    
    //TAPGESTURE TO HIDE KEYBOARD WHEN TOUCHING OUTSIDE OF TEXTFIELD
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tap];
    
    
    //CHANGE KEYBOARD BUTTON TO DONE
    self.myLocation.returnKeyType = UIReturnKeyDone;
    
    [self.myLocation addTarget:self
                        action:@selector(startingDone:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.destination.returnKeyType = UIReturnKeyDone;
    
    [self.destination addTarget:self
                         action:@selector(destinationDone:)
               forControlEvents:UIControlEventEditingDidEndOnExit];
    

    //SET DEFAULT
    Mode = YES;
    publicRoute = YES;
    //self.myLocation.text = @"";
    self.destination.text = @"";
    [StaticObjects setSwapRouteStatusForPublic:NO];

    
    //ALLOC MEMORY
    startName = [[NSString alloc]init];
    endName = [[NSString alloc]init];
    pushArray = [[NSMutableArray alloc]init];
    
    //DEFAULT VALUE
    startName = @"nth";
    endName = @"nth";
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}



//----------------//
//WHEN SELECT CELL//
//----------------//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Make mylocation and destination cell unselectable
    NSIndexPath *locationPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *destintionPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *location = [self.tableView cellForRowAtIndexPath:locationPath];
    UITableViewCell *destination = [self.tableView cellForRowAtIndexPath:destintionPath];
    location.selectionStyle =UITableViewCellSelectionStyleNone;
    destination.selectionStyle =UITableViewCellSelectionStyleNone;
    
    
    //Create IndexPath (Long way of doing)
    NSIndexPath *Mode1 = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *Mode2 = [NSIndexPath indexPathForRow:1 inSection:1];
    NSIndexPath *publicRoute3 = [NSIndexPath indexPathForRow:0 inSection:2];
    NSIndexPath *publicRoute4 = [NSIndexPath indexPathForRow:1 inSection:2];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //Select Cell Change swap tick
    if(([Mode1 compare: indexPath] == NSOrderedSame) || ([Mode2 compare: indexPath] == NSOrderedSame))
    {
        
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:Mode1];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:Mode2];
        
        
        if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
        else if (cell1.accessoryType == UITableViewCellAccessoryNone)
        {
            
            cell1.accessoryType = UITableViewCellAccessoryCheckmark;
            cell2.accessoryType = UITableViewCellAccessoryNone;
            Mode = YES;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        else if (cell2.accessoryType == UITableViewCellAccessoryNone)
        {
            
            cell2.accessoryType = UITableViewCellAccessoryCheckmark;
            cell1.accessoryType = UITableViewCellAccessoryNone;
            Mode = NO;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
    }
    else if(([publicRoute3 compare: indexPath] == NSOrderedSame) || ([publicRoute4 compare: indexPath] == NSOrderedSame))
        
    {
        UITableViewCell *cell3 = [self.tableView cellForRowAtIndexPath:publicRoute3];
        UITableViewCell *cell4 = [self.tableView cellForRowAtIndexPath:publicRoute4];
        
        
        if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
        else if (cell3.accessoryType == UITableViewCellAccessoryNone)
        {
            
            cell3.accessoryType = UITableViewCellAccessoryCheckmark;
            cell4.accessoryType = UITableViewCellAccessoryNone;
            publicRoute = YES;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        else if (cell4.accessoryType == UITableViewCellAccessoryNone)
        {
            
            cell4.accessoryType = UITableViewCellAccessoryCheckmark;
            cell3.accessoryType = UITableViewCellAccessoryNone;
            publicRoute = NO;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
        
        
    }
    
    
}


//----------------------------------------------//
//RECEIVE NOTIFICATION FROM PUBLIC TRANSPORT API//
//----------------------------------------------//
-(void)publicTransportDone:(NSNotification *)notification
{
    
    //Click Done Button
    if([[notification name] isEqualToString:@"clickdonepublic"])
    {
        
        //Check if starting location is current direction
        if ([self.myLocation.text isEqualToString:@"Current Location"] && [endName isEqualToString:self.destination.text]) {
            
            
            //CHECK FOR ROUTE DIRECTION SWAP
            if ([StaticObjects getSwapRouteStatusForPublic] == NO) {
                
                //SET CURRENT COORDIINATE TO STATICOBJECT
                [StaticObjects setStartPublicX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                [StaticObjects setStartPublicY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
            }
            else if ([StaticObjects getSwapRouteStatusForPublic] == YES) {
                
                //SET CURRENT COORDIINATE TO STATICOBJECT
                [StaticObjects setEndPublicX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                [StaticObjects setEndPublicY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
            }
            
            
            if (Mode == YES){
                [StaticObjects setMode:@"bus"];
            }
            else if (Mode == NO){
                [StaticObjects setMode:@"bus/mrt"];
            }
            
            if (publicRoute == YES){
                [StaticObjects setRoute:@"cheapest"];
            }
            else if (publicRoute == NO){
                [StaticObjects setRoute:@"fastest"];
            }
            
            queue = [[NSOperationQueue alloc]init];
            pt = [[PublicTransport alloc]init];
            
            //Run GetToken in quene
            [queue addOperation:pt];
            
            [self loading];
            
            
            }
        
        //Check if destination location is current direction
        else if ([startName isEqualToString:self.myLocation.text] && [self.destination.text isEqualToString:@"Current Location"]) {
                
                //CHECK FOR ROUTE DIRECTION SWAP
                if ([StaticObjects getSwapRouteStatusForPublic] == NO) {
                    
                    //SET CURRENT COORDIINATE TO STATICOBJECT
                    [StaticObjects setEndPublicX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                    [StaticObjects setEndPublicY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
                }
                else if ([StaticObjects getSwapRouteStatusForPublic] == YES) {
                    
                    //SET CURRENT COORDIINATE TO STATICOBJECT
                    [StaticObjects setStartPublicX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                    [StaticObjects setStartPublicY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
                }
                
                
                if (Mode == YES){
                    [StaticObjects setMode:@"bus"];
                }
                else if (Mode == NO){
                    [StaticObjects setMode:@"bus/mrt"];
                }
                
                if (publicRoute == YES){
                    [StaticObjects setRoute:@"cheapest"];
                }
                else if (publicRoute == NO){
                    [StaticObjects setRoute:@"fastest"];
                }
                
                queue = [[NSOperationQueue alloc]init];
                pt = [[PublicTransport alloc]init];
                
                //Run GetToken in quene
                [queue addOperation:pt];
                
                [self loading];

                
            }
        
        //Check both start and end destination if input is correct
        else if ([startName isEqualToString:self.myLocation.text] && [endName isEqualToString:self.destination.text]) {
            
            
            if (Mode == YES){
                [StaticObjects setMode:@"bus"];
            }
            else if (Mode == NO){
                [StaticObjects setMode:@"bus/mrt"];
            }
            
            if (publicRoute == YES){
                [StaticObjects setRoute:@"cheapest"];
            }
            else if (publicRoute == NO){
                [StaticObjects setRoute:@"fastest"];
            }
            
            queue = [[NSOperationQueue alloc]init];
            pt = [[PublicTransport alloc]init];
            
            //Run GetToken in quene
            [queue addOperation:pt];
            
            [self loading];
            
            
        }
        
            //display message
            else{
                
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Incomplete Field" message:@"Please Ensure That Starting And Ending Location Are Correct" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
                
                
            
            
        
        }

    }
    
    //Wait reply from public transport api
    else if ([[notification name] isEqualToString:@"waitForPublicTransport"])
    {
        
        //HIDE LOADING INDICATOR
        [hud hide:YES];
        
    
        //SET START AND DESTINATION ADDRESS NAME FOR CALLOUT
        [StaticObjects setStartName:self.myLocation.text];
        [StaticObjects setEndName:self.destination.text];
    
        
        //UNWIND TO MAINVIEW
        [self performSegueWithIdentifier:@"publictransportdone.segue" sender:self];
    }
}




//---------------------//
//SET LOADING INDICATOR//
//---------------------//
-(void)loading{
    
    //SET LOADING INDICATOR
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"Getting Direction...";
    [self.view addSubview:hud];
    [hud show:YES];
    
}





//----------------------//
//STOP LOADING INDICATOR//
//----------------------//
-(void)stopLoading:(NSNotification *)notification
{
    [hud hide:YES];
}




//---------------------//
//SWAP DIRECTION BUTTON//
//---------------------//
- (IBAction)swapAction:(id)sender {
    
    //Animation
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    NSString * tempStr1 = [NSString stringWithFormat:@"%@",self.myLocation.text];
    NSString * tempStr2 = [NSString stringWithFormat:@"%@",self.destination.text];
    
    [self.myLocation.layer addAnimation:animation forKey:@"changeLocationTransition"];
    [self.destination.layer addAnimation:animation forKey:@"changeDestinationTransition"];
    
    //Change the text
    self.myLocation.text = tempStr2;
    self.destination.text = tempStr1;
    
    //SWAP startName and endName
    NSString * tempStart = startName;
    NSString * tempEnd = endName;
    startName = tempEnd;
    endName = tempStart;
    
    if ([StaticObjects getSwapRouteStatusForPublic] == YES) {
        
        //NO = NO CHANGE
        [StaticObjects setSwapRouteStatusForPublic:NO];
    }
    else{
        
        //YES = SWAP FROM AND TO
        [StaticObjects setSwapRouteStatusForPublic:YES];
    }
    

}


//----------------------------------------//
//RECEIVE NOTIFICATION TO UPDATE TEXTFIELD//
//----------------------------------------//
-(void)updateTextField:(NSNotification *)notification
{
    NSString *sender = [notification object];

    if ([[pushArray objectAtIndex:1] isEqualToString:@"mylocation"]) {
        
        self.myLocation.text = sender;
        startName = sender;
        
    }
    else if ([[pushArray objectAtIndex:1] isEqualToString:@"destination"]) {
        
        self.destination.text = sender;
        endName = sender;
        
    }
    
}


//--------------------------------------------//
//RECEIVE NOTIFICATION FROM ADDRESS SEARCH API//
//--------------------------------------------//
-(void)searchDone:(NSNotification *)notification
{
    
    //HIDE LOADING
    [hud hide:YES];
    
    [self performSegueWithIdentifier:@"publictosearch" sender:self];
    
}




//-------------------------------------------//
//DONE BUTTON FOR KEYBOARD ("FROM" TEXTFIELD)//
//-------------------------------------------//
- (IBAction)startingDone:(id)sender {
    
    //VALIDATE AT LEAST 3 CHAR
    if (self.myLocation.text.length < 3 ) {
        
        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:@"At least 3 characters required. Avoid BLK or BLOCK in search."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];
        
    }
    
    //VALIDATE IF SEARCH IS NOT NULL
    else if(self.myLocation.text !=nil)
    {
        
        //START LOADING
        [self loading];
        
        selectedField = [NSString stringWithFormat:@"mylocation"];
        
        //SET SEARCHWORD TO STATIC VARIABLE
        [StaticObjects setSearchKeyword:self.myLocation.text];
        
        queue = [[NSOperationQueue alloc]init];
        
        //SET STATUS  = CALL FROM SEARCH BAR
        [StaticObjects setCallFrom:[NSString stringWithFormat:@"publictransport"]];
        
        address = [[AddressSearch alloc]init];
        [queue addOperation:address];
        
        
        
    }
    
}



//-----------------------------------------//
//DONE BUTTON FOR KEYBOARD ("TO" TEXTFIELD)//
//-----------------------------------------//
- (IBAction)destinationDone:(id)sender {
    
    //VALIDATE AT LEAST 3 CHAR
    if (self.destination.text.length < 3 ) {
        
        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:@"At least 3 characters required. Avoid BLK or BLOCK in search."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];
        
    }
    
    //VALIDATE IF SEARCH IS NOT NULL
    else if(self.destination.text !=nil)
    {
        
        //START LOADING
        [self loading];
        
        selectedField = [NSString stringWithFormat:@"destination"];
        
        //SET SEARCHWORD TO STATIC VARIABLE
        [StaticObjects setSearchKeyword:self.destination.text];
        
        queue = [[NSOperationQueue alloc]init];
        
        //SET STATUS YES = CALL FROM SEARCH BAR
        [StaticObjects setCallFrom:[NSString stringWithFormat:@"publictransport"]];
        
        address = [[AddressSearch alloc]init];
        [queue addOperation:address];
        
        
    }
    
}


//---------------------------------//
//PERFORM METHOD BEFORE DOING SEGUE//
//---------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender

{
    if ([[segue identifier] isEqualToString:@"publictosearch"]) {
        
        //PASS ARRAY TO CATEGORYVIEW
        SearchAddressForRouteViewController *searchview = [segue destinationViewController];
        
        [pushArray removeAllObjects];
        [pushArray addObject:[NSString stringWithFormat:@"publictransport"]];
        [pushArray addObject:selectedField];
        
        searchview.pushFrom = pushArray;
        
    }
    
}



//----------------//
//DISMISS KEYBOARD//
//----------------//
-(void)dismissKeyboard {
    
    [self.myLocation resignFirstResponder];
    [self.destination resignFirstResponder];
    
}
@end
