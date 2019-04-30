//
//  GetDirectionControllerViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 12/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "GetDirectionControllerViewController.h"
#import "StaticObjects.h"
#import "GetDirection.h"
#import "MBProgressHUD.h"
#import "SearchAddressForRouteViewController.h"
#import "AddressSearch.h"

@interface GetDirectionControllerViewController (){
    bool ERP;
    BOOL Route;
    NSOperationQueue *queue;
    NSString * selectedField;
    GetDirection * dirc;
    AddressSearch *address;
    MBProgressHUD *hud;
    NSString * startName;
    NSString * endName;
    NSMutableArray * pushArray;

}

@end

@implementation GetDirectionControllerViewController

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
    [super viewDidLoad];
    
    //SET NOTIFICATION
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"waitForGetDirection"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(directionDone:) name:@"waitForGetDirection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(directionDone:) name:@"clickdone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchDone:) name:@"searchAPIDoneForGetDirection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextField:) name:@"updateTextFieldForGetDirection" object:nil];


    
    //TAPGESTURE TO HIDE KEYBOARD WHEN TOUCHING OUTSIDE OF TEXTFIELD
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;

    [self.tableView addGestureRecognizer:tap];
    
    
    //CHANGE KEYBOARD BUTTON TO DONE
    self.myLocation.returnKeyType = UIReturnKeyDone;
    
    [self.myLocation addTarget:self
                    action:@selector(startingDone:)
          forControlEvents:UIControlEventEditingDidEndOnExit];

    self.destination.returnKeyType = UIReturnKeyDone;
    
    [self.destination addTarget:self
                        action:@selector(destinationDone:)
              forControlEvents:UIControlEventEditingDidEndOnExit];

    
    //SET DEFAULT VALUE
    [StaticObjects setSwapRouteStatusForDirection:NO];
    ERP = 0;
    Route = YES;
    //self.myLocation.text = @"";
    self.destination.text = @"";
    
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
    // Dispose of any resources that can be recreated.
}




//------------------------------//
//WHEN U CLICK ON THE TABLE CELL//
//------------------------------//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Make mylocation and destination cell unselectable
    NSIndexPath *locationPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *destintionPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *location = [self.tableView cellForRowAtIndexPath:locationPath];
    UITableViewCell *destination = [self.tableView cellForRowAtIndexPath:destintionPath];
    location.selectionStyle =UITableViewCellSelectionStyleNone;
    destination.selectionStyle =UITableViewCellSelectionStyleNone;

    
    //Create IndexPath (Long way of doing)
    NSIndexPath *ERP1 = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *ERP2 = [NSIndexPath indexPathForRow:1 inSection:1];
    NSIndexPath *Route3 = [NSIndexPath indexPathForRow:0 inSection:2];
    NSIndexPath *Route4 = [NSIndexPath indexPathForRow:1 inSection:2];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];

    
    //Select Cell Change swap tick
    if(([ERP1 compare: indexPath] == NSOrderedSame) || ([ERP2 compare: indexPath] == NSOrderedSame))
    {
        
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:ERP1];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:ERP2];

        
        if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

        }

        else if (cell1.accessoryType == UITableViewCellAccessoryNone)
        {

            cell1.accessoryType = UITableViewCellAccessoryCheckmark;
            cell2.accessoryType = UITableViewCellAccessoryNone;
            ERP = 0;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        else if (cell2.accessoryType == UITableViewCellAccessoryNone)
        {

            cell2.accessoryType = UITableViewCellAccessoryCheckmark;
            cell1.accessoryType = UITableViewCellAccessoryNone;
            ERP = 1;
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

        }
      
    }
    else if(([Route3 compare: indexPath] == NSOrderedSame) || ([Route4 compare: indexPath] == NSOrderedSame))
        
        {
            UITableViewCell *cell3 = [self.tableView cellForRowAtIndexPath:Route3];
            UITableViewCell *cell4 = [self.tableView cellForRowAtIndexPath:Route4];
            
            
            if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
            }
            
            else if (cell3.accessoryType == UITableViewCellAccessoryNone)
            {
                
                cell3.accessoryType = UITableViewCellAccessoryCheckmark;
                cell4.accessoryType = UITableViewCellAccessoryNone;
                Route = YES;
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
            else if (cell4.accessoryType == UITableViewCellAccessoryNone)
            {
                
                cell4.accessoryType = UITableViewCellAccessoryCheckmark;
                cell3.accessoryType = UITableViewCellAccessoryNone;
                Route = NO;
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
            }

        
        }

    
}


//--------------------------------------------//
//RECEIVE NOTIFICATION FROM ADDRESS SEARCH API//
//--------------------------------------------//
-(void)searchDone:(NSNotification *)notification
{
    
    //HIDE LOADING
    [hud hide:YES];
    
    [self performSegueWithIdentifier:@"getdirectiontosearch" sender:self];

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



//-------------------------------------------//
//RECEIVE NOTIFICATION FROM GET DIRECTION API//
//-------------------------------------------//
-(void)directionDone:(NSNotification *)notification

{
    
    NSDictionary * userInfo = notification.userInfo;
    NSString * message = [userInfo objectForKey:@"error"];

    
    //display error message
    if ([[notification name] isEqualToString:@"waitForGetDirection"] && [message isEqualToString:@"request error"])
    {
        
        //HIDE LOADING INDICATOR
        [hud hide:YES];
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Request Timeout" message:@"No Network Or Slow Internet Connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
       
    }

    //Wait reply from get direction api after tapping done btn
   else if ([[notification name] isEqualToString:@"waitForGetDirection"])
    {
        
        //HIDE LOADING INDICATOR
        [hud hide:YES];
        
        
        //SET START AND DESTINATION ADDRES NAME FOR CALLOUT
        [StaticObjects setStartName:self.myLocation.text];
        [StaticObjects setEndName:self.destination.text];
            
     
        //UNWIND TO MAINVIEW
        [self performSegueWithIdentifier:@"getdirectiondone.segue" sender:self];
        

    }
    
    //Done Button
    else if([[notification name] isEqualToString:@"clickdone"])
    {
        NSLog(@"STARTNAME -%@",startName);
        NSLog(@"ENDNAME -%@",endName);
        
            //Check if starting location is current direction
            if ([self.myLocation.text isEqualToString:@"Current Location"] && [endName isEqualToString:self.destination.text]) {
            
            NSLog(@"Current location Test starting");
         
                //CHECK FOR ROUTE DIRECTION SWAP
                if ([StaticObjects getSwapRouteStatusForDirection] == NO) {

                    //SET CURRENT COORDIINATE TO STATICOBJECT
                    [StaticObjects setStartDirectionX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                    [StaticObjects setStartDirectionY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
                }
                else if ([StaticObjects getSwapRouteStatusForDirection] == YES) {
                    
                    //SET CURRENT COORDIINATE TO STATICOBJECT
                    [StaticObjects setEndDirectionX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                    [StaticObjects setEndDirectionY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
                }
         
                [StaticObjects setERP:ERP];
            
                if (Route == YES){
                    [StaticObjects setRoute:@"shortest"];
                }
                else if (Route == NO){
                    [StaticObjects setRoute:@"fastest"];
                }
            
                queue = [[NSOperationQueue alloc]init];
                dirc = [[GetDirection alloc]init];
            
                [queue addOperation:dirc];
            
                [self loading];
         
            }
        
            //Check if destination location is current direction
            else if ([startName isEqualToString:self.myLocation.text] && [self.destination.text isEqualToString:@"Current Location"]) {
            
            NSLog(@"Current location Test destination");
         
                
                //CHECK FOR ROUTE DIRECTION SWAP
                if ([StaticObjects getSwapRouteStatusForDirection] == NO) {
                    
                    //SET CURRENT COORDIINATE TO STATICOBJECT
                    [StaticObjects setEndDirectionX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                    [StaticObjects setEndDirectionY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
                }
                else if ([StaticObjects getSwapRouteStatusForDirection] == YES) {
                    
                    //SET CURRENT COORDIINATE TO STATICOBJECT
                    [StaticObjects setStartDirectionX:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentX]]];
                    [StaticObjects setStartDirectionY:[NSString stringWithFormat:@"%f",[StaticObjects getCurrentY]]];
                }

         
             [StaticObjects setERP:ERP];
             
             if (Route == YES){
             [StaticObjects setRoute:@"shortest"];
             }
             else if (Route == NO){
             [StaticObjects setRoute:@"fastest"];
             }
             
             queue = [[NSOperationQueue alloc]init];
             dirc = [[GetDirection alloc]init];
             
             [queue addOperation:dirc];
             
             [self loading];
         
            }

            //Check both start and end destination if input is correct
           else if ([startName isEqualToString:self.myLocation.text] && [endName isEqualToString:self.destination.text]) {
                
                [StaticObjects setERP:ERP];
                
                if (Route == YES){
                    [StaticObjects setRoute:@"shortest"];
                }
                else if (Route == NO){
                    [StaticObjects setRoute:@"fastest"];
                }
                
                queue = [[NSOperationQueue alloc]init];
                dirc = [[GetDirection alloc]init];
                
                [queue addOperation:dirc];
                
                [self loading];
                
            }
        
            //display message
            else{
                
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Incomplete Field" message:@"Please Ensure That Starting And Ending Location Are Correct" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
                
                
                }

        
    
            
        
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
    
    //SWAP TEXTFIELD
    self.myLocation.text = tempStr2;
    self.destination.text = tempStr1;
    
    //SWAP startName and endName
    NSString * tempStart = startName;
    NSString * tempEnd = endName;
    startName = tempEnd;
    endName = tempStart;
    
    if ([StaticObjects getSwapRouteStatusForDirection] == YES) {

        //NO = NO CHANGE
        [StaticObjects setSwapRouteStatusForDirection:NO];
    }
    else if([StaticObjects getSwapRouteStatusForDirection] == NO){
        
        //YES = SWAP FROM AND TO
        [StaticObjects setSwapRouteStatusForDirection:YES];
    }
    
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
        
        //SET STATUS = CALL FROM SEARCH BAR
        [StaticObjects setCallFrom:[NSString stringWithFormat:@"getdirection"]];
        
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
        [StaticObjects setCallFrom:[NSString stringWithFormat:@"getdirection"]];
        
        address = [[AddressSearch alloc]init];
        [queue addOperation:address];
        

    }
    
}



//---------------------------------//
//PERFORM METHOD BEFORE DOING SEGUE//
//---------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender

{
    if ([[segue identifier] isEqualToString:@"getdirectiontosearch"]) {
        
        //PASS ARRAY TO CATEGORYVIEW
        SearchAddressForRouteViewController *searchview = [segue destinationViewController];
        
        [pushArray removeAllObjects];
        [pushArray addObject:[NSString stringWithFormat:@"direction"]];
        [pushArray addObject:selectedField];
        
        NSLog(@"TEST -%@",pushArray);
        
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
