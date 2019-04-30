//
//  ThemeSearchViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 30/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "ThemeSearchViewController.h"
#import "CategoryTableViewController.h"
#import "ThemeTableViewController.h"
#import "StaticObjects.h"
#import "MainViewController.h"

@interface ThemeSearchViewController ()

@end

@implementation ThemeSearchViewController{
    NSMutableArray *themeArray;
    NSMutableArray *themeArray2;
    NSMutableArray *categoryArray;
    NSString * themeName;
    bool displayTheme;
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

    
    //DEFAULT SEGMENT = ALL (ALL = YES, CUSTOM = NO)
     displayTheme = YES;

    
    //SET TABLECELL NON SELECTABLE
    self.tableView.allowsSelection = NO;

    
    //SET ALL TEXTFIELD TO NULL
    self.themefield.text=nil;
    self.categoryfield.text=nil;
    
    //ARRAY FOR UIPICKERVIEWER
    themeArray = [[NSMutableArray alloc] init];
    themeArray2 = [[NSMutableArray alloc] init];
    categoryArray = [[NSMutableArray alloc] init];
    
    
    //ADD DATA TO ARRAY (FOR CATEGORY)
    [categoryArray addObject:@"Community"];
    [categoryArray addObject:@"Culture"];
    [categoryArray addObject:@"Education"];
    [categoryArray addObject:@"Emergency Preparedness"];
    [categoryArray addObject:@"Employment"];
    [categoryArray addObject:@"Environment"];
    [categoryArray addObject:@"Family"];
    [categoryArray addObject:@"Government Offices"];
    [categoryArray addObject:@"Health"];
    [categoryArray addObject:@"National Service"];
    [categoryArray addObject:@"Recreation"];
    [categoryArray addObject:@"Sports"];

  
    //SET TEXTFIELD TAG FOR IDENTIFICATION
    self.categoryfield.tag = 1;
    self.themefield.tag = 2;
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//------------------//
//ONSELECT TEXTFIELD//
//------------------//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    //1 FOR CATEGORY TEXTFIELD
    if (textField.tag == 1) {
        
        //SEGUE TO CATEGORY SELECTION PAGE
        [self performSegueWithIdentifier:@"categorySegue" sender:self];
    }
    
    //2 FOR THEME TEXTFIELD
    else if (textField.tag == 2) {
        
        //CHECK TEXTFIELD FOR NULL
        if(self.categoryfield.text == nil){
            
            NSLog(@"NO CATEGORY SO NTH HAPPEN");
            
        }
        else{
        
        //GET THEME BASED ON CATEGORY CHOSEN
        [self checkCategory:self.categoryfield.text];
            
        //SEGUE TO THEME SELECTION PAGE
        [self performSegueWithIdentifier:@"themeSegue" sender:self];
        
        }
    }
    return NO;
}



//-----------------------------//
//CHECK SEGUE BEFORE PERFORMING//
//-----------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender

{
    if ([[segue identifier] isEqualToString:@"categorySegue"]) {
        
        //PASS ARRAY TO CATEGORYVIEW
        CategoryTableViewController *categoryview = [segue destinationViewController];
        categoryview.dataArray = categoryArray;
    }
    else if ([[segue identifier] isEqualToString:@"themeSegue"]) {
        
        //PASS ARRAY TO THEMEVIEW
        ThemeTableViewController *themeview = [segue destinationViewController];
        themeview.dataArray = themeArray;

    }

}



//-------------------------------------//
//UNWIND BACK FROM CATEGORY RESULT VIEW//
//-------------------------------------//
- (IBAction)unwindToThemeSearchFromCategory:(UIStoryboardSegue *)segue
{
    
    if(self.categoryfield.text == nil){
    
        //SET CATEGORY TEXTFIELD BASE ON SELECTED ITEMS IN CATEGORY VIEW
        self.categoryfield.text = self.categoryText;

    }
    else {
        
        //SET CATEGORY TEXTFIELD BASE ON SELECTED ITEMS IN CATEGORY VIEW
        self.categoryfield.text = self.categoryText;
        
        //SET THEME TEXTFIELD TO NULL
        self.themefield.text = nil;
        
    }
    
}



//----------------------------------//
//UNWIND BACK FROM THEME RESULT VIEW//
//----------------------------------//
- (IBAction)unwindToThemeSearchFromTheme:(UIStoryboardSegue *)segue
{
    //SET THEMENAME TO STRING ONCE USER CHOOSE
    themeName = [NSString stringWithFormat:@"%@",[themeArray2 objectAtIndex:[[self.themeIndex objectAtIndex:1] integerValue]]];
    
    //EMPTY THEMEARRAY THAT STORE LIST OF THEMENAME FOR MASH API
    [themeArray2 removeAllObjects];
    
    //SET CATEGORY TEXTFIELD BASE ON SELECTED ITEMS IN THEME VIEW
    self.themefield.text = [self.themeIndex objectAtIndex:0];
    
 


}



//----------------------------------------------------//
//UNWIND FOR BACK BUTTON IN CATEGORY/THEME RESULT VIEW//
//----------------------------------------------------//
- (IBAction)unwindToTheme:(UIStoryboardSegue *)segue
{
    NSLog(@"UNWINDTOTHEME");
}




//---------------------//
//DONE BTN ON TOP RIGHT//
//---------------------//
- (IBAction)doneBtn:(id)sender {
    
    //CHECK IF EITHER THEME OR CATEGORY FIELD IS NULL
    if(self.themefield.text ==nil || self.categoryfield.text ==nil){
        
        //PROMPT ALERT TO ASK USER TO SELECT IF EITHER NULL
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Empty Field" message:@"Please Select A Category And Theme" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        
    }
    
    //MEAN BOTH FIELD HAVE BEEN SELECTED
    else{
        
        //SET THEME NAME SELECTED TO STATIC VARIABLE
        [StaticObjects setThemeName:themeName];
 
        //SET DISPLAYTHEME TO INDICATE IF DISPLAY ALL THEME ON MAP OR SELECTED AREA
        [StaticObjects setDisplayTheme:displayTheme];
        
        if (displayTheme == YES) {
        
            //SET STATUS TO INDICATE USER IS NOT GOING TO SEARCH FOR CUSTOM THEME
            [StaticObjects setThemeStatus:NO];
            
        }
        else{
            //SET STATUS TO INDICATE USER IS GOING TO SEARCH FOR CUSTOM THEME
            [StaticObjects setThemeStatus:YES];
        }
        
        
        //PERFORM SEGUE TO MAIN VIEW
        [self performSegueWithIdentifier:@"themetomain" sender:self];

    }

    
}



//------------------------------//
//UISEGMENTEDCONTROL TOUCH EVENT//
//------------------------------//
-(IBAction) segmentedControlIndexChanged{
	switch (self.segment.selectedSegmentIndex) {
		case 0:
            
            displayTheme = YES;
            //NSLog(@"ALL-%d",displayTheme);
			break;
		
        case 1:
        
            displayTheme = NO;
            //NSLog(@"Custom-%d",displayTheme);
			break;
            
		    }
}



//-----------------------------------------------------//
//METHOD USE TO CHECK FOR THEME BASE ON CATEGORY CHOSEN//
//-----------------------------------------------------//
-(void)checkCategory:(NSString *) category{
    
    if ([category isEqualToString:@"Community"]) {
        
        
        [themeArray addObject:@"Friendly Buildings"];
        [themeArray addObject:@"Community Devt Councils"];
        [themeArray addObject:@"Community Mediation"];
        [themeArray addObject:@"Community Clubs"];
        [themeArray addObject:@"Constituency Offices"];
        [themeArray addObject:@"Infocomm Accessibility"];
        [themeArray addObject:@"PA Holiday Facilities"];
        [themeArray addObject:@"Other PA Networks"];
        [themeArray addObject:@"Resident's Committees"];
        [themeArray addObject:@"Silver Infocomm"];
        [themeArray addObject:@"Social Service Offices"];
        [themeArray addObject:@"Water Ventures"];
        
        [themeArray2 addObject:@"BFABUILDINGS"];
        [themeArray2 addObject:@"CDCOUNCILS"];
        [themeArray2 addObject:@"COMMMEDIATIONCTR"];
        [themeArray2 addObject:@"COMMUINITYCLUBS"];
        [themeArray2 addObject:@"CONSTITUENCYOFFICES"];
        [themeArray2 addObject:@"INFOCOMMACCESS"];
        [themeArray2 addObject:@"OTHERFACILITIES"];
        [themeArray2 addObject:@"OTHERPANETWORKS"];
        [themeArray2 addObject:@"RESIDENTSCOMMITTEE"];
        [themeArray2 addObject:@"SILVERINFOCOMM"];
        [themeArray2 addObject:@"sso"];
        [themeArray2 addObject:@"WATERVENTURE"];

    }
    else if ([category isEqualToString:@"Culture"]) {

        
        [themeArray addObject:@"Auditoriums"];
        [themeArray addObject:@"Exhibition Centres"];
        [themeArray addObject:@"Heritage Sites"];
        [themeArray addObject:@"Libraries"];
        [themeArray addObject:@"Monuments"];
        [themeArray addObject:@"Museums"];
        [themeArray addObject:@"Performing Arts"];
        [themeArray addObject:@"Street and Places"];
        [themeArray addObject:@"Conservation Area Map"];
        
        
        [themeArray2 addObject:@"AUDITORIUMS"];
        [themeArray2 addObject:@"EXHIBITIONCENTRES"];
        [themeArray2 addObject:@"HERITAGESITES"];
        [themeArray2 addObject:@"LIBRARIES"];
        [themeArray2 addObject:@"MONUMENTS"];
        [themeArray2 addObject:@"MUSEUM"];
        [themeArray2 addObject:@"PERFORMINGARTS"];
        [themeArray2 addObject:@"StreetsandPlaces"];
        [themeArray2 addObject:@"URA_CONSERVATION_AREA"];
        
    }
    else if ([category isEqualToString:@"Education"]) {
    
        
        [themeArray addObject:@"Private Education Institutions"];
        [themeArray addObject:@"Kindergartens"];
    
        
        [themeArray2 addObject:@"CPE_PEI_PREMISES"];
        [themeArray2 addObject:@"KINDERGARTENS"];
        
    }
    else if ([category isEqualToString:@"Emergency Preparedness"]) {
   
        
        [themeArray addObject:@"Fire Posts"];
        [themeArray addObject:@"Fire Stations"];
        
        [themeArray2 addObject:@"FIREPOST"];
        [themeArray2 addObject:@"FIRESTATION"];
    
    }
    else if ([category isEqualToString:@"Employment"]) {

        
        [themeArray addObject:@"CET Centres"];
        [themeArray addObject:@"WDA Service Points"];
        
        [themeArray2 addObject:@"CETCentres"];
        [themeArray2 addObject:@"WDASERVICEPOINTS"];
        
    }
    else if ([category isEqualToString:@"Environment"]) {
        
        
        [themeArray addObject:@"After Death Facilities"];
        [themeArray addObject:@"Dengue Focus Area"];
        [themeArray addObject:@"Funeral Parlours"];
        [themeArray addObject:@"Green Mark Buildings"];
        [themeArray addObject:@"Hawker Centres"];
        [themeArray addObject:@"Heritage Trees"];
        [themeArray addObject:@"Malaria Receptive Area"];
        [themeArray addObject:@"Recycling Bins"];
        [themeArray addObject:@"Skyrise Greenery"];
        [themeArray addObject:@"Waste Disposal Sites"];
        [themeArray addObject:@"Waste Treatment"];
        
        
        [themeArray2 addObject:@"AFTERDEATHFACILITIES"];
        [themeArray2 addObject:@"dengue_focus_area"];
        [themeArray2 addObject:@"FUNERALPARLOURS"];
        [themeArray2 addObject:@"GREENBUILDING"];
        [themeArray2 addObject:@"HAWKERCENTRE"];
        [themeArray2 addObject:@"HERITAGETREES"];
        [themeArray2 addObject:@"malaria_receptive_area"];
        [themeArray2 addObject:@"RECYCLINGBINS"];
        [themeArray2 addObject:@"SKYRISEGREENERY"];
        [themeArray2 addObject:@"WASTEDISPOSALSITE"];
        [themeArray2 addObject:@"WASTETREATMENT"];
        
    }
    else if ([category isEqualToString:@"Family"]) {

        
        [themeArray addObject:@"Child Care Services"];
        [themeArray addObject:@"Disability Services"];
        [themeArray addObject:@"Eldercare Services"];
        [themeArray addObject:@"Family Services"];
        [themeArray addObject:@"Family Friendly Establishments"];
        [themeArray addObject:@"Student Care Services"];
        [themeArray addObject:@"Voluntary Welfare Organizations"];
        
        
        [themeArray2 addObject:@"CHILDCARE"];
        [themeArray2 addObject:@"DISABILITY"];
        [themeArray2 addObject:@"ELDERCARE"];
        [themeArray2 addObject:@"FAMILY"];
        [themeArray2 addObject:@"FAMILYFRIENDLYESTAB"];
        [themeArray2 addObject:@"STUDENTCARE"];
        [themeArray2 addObject:@"VOLUNTARYWELFAREORGS"];

    }
    else if ([category isEqualToString:@"Government Offices"]) {
    
        
        
       

        
        
        [themeArray addObject:@"CPF Offices"];
        [themeArray addObject:@"HDB Branches"];
        [themeArray addObject:@"NEA Offices"];
        [themeArray addObject:@"PA Headquarters"];
        [themeArray addObject:@"Singapore Police Force Establishments"];
        
        
        [themeArray2 addObject:@"CPFB_Location"];
        [themeArray2 addObject:@"HDB_Branches"];
        [themeArray2 addObject:@"NEAOFFICES"];
        [themeArray2 addObject:@"PAHeadquarters"];
        [themeArray2 addObject:@"SPF_Establishments"];


    }
    else if ([category isEqualToString:@"Health"]) {

        
        [themeArray addObject:@"Breast Screening Centre"];
        [themeArray addObject:@"Cervical Screening Centre"];
        [themeArray addObject:@"Dengue Clusters"];
        [themeArray addObject:@"Healthier Dinning"];
        [themeArray addObject:@"Quit Centres"];
        
        
        [themeArray2 addObject:@"BREASTSCREEN"];
        [themeArray2 addObject:@"CERVICALSCREEN"];
        [themeArray2 addObject:@"DENGUE_CLUSTER"];
        [themeArray2 addObject:@"Healthier_hawker_centres"];
        [themeArray2 addObject:@"QuitCentres"];


    }
    else if ([category isEqualToString:@"National Service"]) {
    
     
        
        [themeArray addObject:@"Fitness Conditioning Centres (FCCs)"];
        [themeArray addObject:@"IPPT In Your Community"];
        [themeArray addObject:@"NAPFA Test Centres"];
        [themeArray addObject:@"SAFRA Centres"];
        
        
        [themeArray2 addObject:@"HSGB_FCC"];
        [themeArray2 addObject:@"HSGB_IPPT"];
        [themeArray2 addObject:@"HSGB_NAPFA"];
        [themeArray2 addObject:@"HSGB_SAFRA"];


    }
    else if ([category isEqualToString:@"Recreation"]) {

        
        [themeArray addObject:@"ABC Water Projects"];
        [themeArray addObject:@"Hotels"];
        [themeArray addObject:@"Parks"];
        [themeArray addObject:@"Park Connector Loops"];
        [themeArray addObject:@"Tourist Attractions"];
        [themeArray addObject:@"Wireless Hotspots"];
        
        
        [themeArray2 addObject:@"ABCWATERSPROJ"];
        [themeArray2 addObject:@"HOTELS"];
        [themeArray2 addObject:@"NATIONALPARKS"];
        [themeArray2 addObject:@"Park_Connector_Loops"];
        [themeArray2 addObject:@"TOURISM"];
        [themeArray2 addObject:@"WIRELESS_HOTSPOTS"];
    }
    else if ([category isEqualToString:@"Sports"]) {
    
        [themeArray addObject:@"DUS Schools Sports Facilities"];
        [themeArray addObject:@"SSC Sports Facilities"];
        
        
        [themeArray2 addObject:@"DUS_School_Sports_Facilities"];
        [themeArray2 addObject:@"SSC_Sports_Facilities"];

    
    }
    
}



@end
