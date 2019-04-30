//
//  CategoryTableViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 2/1/14.
//  Copyright (c) 2014 Singapore Land Authority. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "ThemeSearchViewController.h"

@interface CategoryTableViewController ()

@end

@implementation CategoryTableViewController


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
    return [self.dataArray count];
}



//----------------------------//
//CONTENT OF CELL FOR EACH ROW//
//----------------------------//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"categoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.textLabel setText:[self.dataArray objectAtIndex:indexPath.row]];

    
    return cell;
}


//------------------//
//WHEN U SELECT CELL//
//------------------//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //UNWIND SEGUE
    [self performSegueWithIdentifier:@"categorytotheme" sender:indexPath];
    
}



//---------------------------------//
//PREFORM METHOD BEFORE DOING SEGUE//
//---------------------------------//
-(void) prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender {
    
    if ([segue.identifier isEqualToString:@"categorytotheme"]) {
        ThemeSearchViewController *themesearch = [segue destinationViewController];
        
        //PASS DATAARRAY
        themesearch.categoryText =[self.dataArray objectAtIndex:(long)[sender row]];
    }
}



@end
