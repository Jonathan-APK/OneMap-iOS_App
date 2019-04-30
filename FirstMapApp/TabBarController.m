//
//  TabBarController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 18/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "TabBarController.h"
#import "StaticObjects.h"

@implementation TabBarController{
    BOOL tabIndex;
}

-(void)viewDidLoad{
  
    //SET DEFAULT TAB AS DRIVE ROUTE
    tabIndex = YES;
}



//-----------//
//DONE BUTTON//
//-----------//
- (IBAction)doneBtn:(id)sender {
    if (tabIndex == YES){
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickdone" object:self];
    
    }
    else if (tabIndex == NO){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickdonepublic" object:self];

    }
}



//----------//
//SELECT TAB//
//----------//
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
    NSUInteger indexOfTab = [[tabBar items] indexOfObject:item];
    
    if(indexOfTab == 0){
        tabIndex = YES;
    }
    else if(indexOfTab == 1){
        tabIndex = NO;
    }

    
}

//-------------//
//UNWIND METHOD//
//-------------//
- (IBAction)unwindToDirectonFromSearch:(UIStoryboardSegue *)segue
{

    //[StaticObjects setName:nil];

}
@end

