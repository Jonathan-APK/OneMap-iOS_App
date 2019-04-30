//
//  SearchViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 23/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "SearchViewController.h"
#import "StaticObjects.h"
#import "AddressSearch.h"
#import "MBProgressHUD.h"


@interface SearchViewController ()

@end

@implementation SearchViewController{
    int selected;
    NSOperationQueue *queue;
    AddressSearch *address;
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

    NSLog(@"SEARCH LOADED");
    
    //CHANGE KEYBOARD BUTTON TO DONE
    self.search.returnKeyType = UIReturnKeyDone;
    
    [self.search addTarget:self
                       action:@selector(searchDone:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //SET NOTIFICATION
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateTable"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkRes:) name:@"updateTable" object:nil];
    
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
    
    //Make search keyword cell unselectable
    NSIndexPath *searchString = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *searchword = [self.tableView cellForRowAtIndexPath:searchString];
    searchword.selectionStyle =UITableViewCellSelectionStyleNone;

    
    }



//-----------//
//DONE BUTTON//
//-----------//
- (IBAction)searchDone:(id)sender {
    
    //VALIDATE AT LEAST 3 CHAR
    if (self.search.text.length < 3 ) {

        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:@"At least 3 characters required. Avoid BLK or BLOCK in search."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];
        
    }
    
    //VALIDATE IF SEARCH IS NOT NULL
    else if(self.search.text !=nil)
    {
        //SET LOADING INDICATOR
        [self loading];
        [StaticObjects setSearchKeyword:self.search.text];
        queue = [[NSOperationQueue alloc]init];
        
        //SET STATUS = CALL FROM SEARCH BAR
        [StaticObjects setCallFrom:[NSString stringWithFormat:@"searchview"]];
        
        address = [[AddressSearch alloc]init];
        [queue addOperation:address];
            

            }

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


//----------------------------------------------------------------//
//NOTIFICATION METHOD - HIDE LOADING & SEGUE TO SEARCH RESULT PAGE//
//----------------------------------------------------------------//
-(void)checkRes:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"updateTable"])
    {
        
        [hud hide:YES];
        [self performSegueWithIdentifier:@"tosearchresult.segue" sender:self];
        NSLog(@"segue!!!");

    }
}



//---------------------------------//
//UNWIND FROM BACK (ADDRESS SEARCH)//
//---------------------------------//
- (IBAction)unwindToSearch:(UIStoryboardSegue *)segue
{
    //CLEAR TEXTFIELD TEXT
    self.search.text = nil;

    //SET NAME AS NIL
    [StaticObjects setName:nil];
    NSLog(@"Back from search result");
    
}


@end
