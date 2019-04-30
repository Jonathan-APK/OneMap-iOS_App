//
//  Mashup.m
//  FirstMapApp
//
//  Created by SLA MacBook on 2/1/14.
//  Copyright (c) 2014 Singapore Land Authority. All rights reserved.
//

#import "Mashup.h"
#import "StaticObjects.h"

@implementation Mashup

- (void)start{
    
    if(![NSThread isMainThread])
    {
        //MAKE OPERATION RUN AT MAIN THREAD
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    //START MAIN METHOD
    [self main];
}

- (void)main{
    
    jsonData=[[NSMutableData alloc]init];
    
    // <NOTE> NEED TO CHECK FOR ESCAPE CHARACTER USING (stringByAddingPercentEscapesUsingEncoding)
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/mashupData?token=%@&themeName=%@&otptFlds=HYPERLINK,NAME",[StaticObjects getToken],[StaticObjects getThemeName]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request mashup  - %@",request);
}

//-------------------------------------//
//METHOD WILL RUN WHEN RECEIVE RESPONSE//
//-------------------------------------//
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    
    [jsonData setLength:0];
    NSLog(@"Response - %@",jsonData);
}



//---------------------------------//
//METHOD WILL RUN WHEN RECEIVE DATA//
//---------------------------------//
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    
    [jsonData appendData:data];
    NSLog(@"Receive mashup - %@",jsonData);
}



//------------------------------------//
//METHOD WILL RUN WHEN THERE IS ERROR //
//------------------------------------//
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"error with connection at GetTokenOperation :%@",[error description]);
    currentConnection = nil;
}



//------------------------------------------------------//
//METHOD WILL RUN WHEN FINISH RECEVING REPLY FROM SERVER//
//------------------------------------------------------//
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSError*error;
    NSDictionary *json;
    
    NSString * jsonString =[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    NSString * removeSpaceJson = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
   // NSLog(@"json string format- %@",removeSpaceJson);
    
    NSData * dataFormat = [removeSpaceJson dataUsingEncoding:NSUTF8StringEncoding];
    jsonData = [dataFormat mutableCopy];
    
    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"json final string format- %@",json);

    
    
    if([[NSString stringWithFormat:@"%@",[json objectForKey:@"SrchResults"]] isEqualToString:[NSString stringWithFormat:@"(null)"]] ){
        
        NSLog(@"MashUp Reply Null");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLoadingMain" object:self];
       
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Request Timeout" message:@"Request Timeout. No Network Or Slow Connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        
    }
    
    else 
    {
        
        //EXTRACTS THE ADDRESS INFO
        [self extractMash:(json)];
        
     //   [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self];
        
    }
    
    
}

//----------------------------//
//EXTRACT DATA FROM JSON REPLY//
//----------------------------//
-(void)extractMash:(NSDictionary *)jsonString
{
    
    NSArray *tempData=[jsonString objectForKey:@"SrchResults"];
    
    
        //CHECK NO. OF ITEMS WHICH CONTAIN (NAME, COORDINATE)
        NSInteger count=[tempData count];
        
        NSMutableArray *name = [[NSMutableArray alloc]init];
        NSMutableArray *xy = [[NSMutableArray alloc]init];
        NSMutableArray *icon = [[NSMutableArray alloc]init];
        NSMutableArray *hyperlink = [[NSMutableArray alloc]init];
    
    
        //LOOP TO GET NAME, COORDINATE AND STORE IN ARRAY
        for(int i=1; i<count;i++)
        {
            [name addObject: [[tempData objectAtIndex:i] objectForKey:@"NAME"]];
            [xy addObject: [[tempData objectAtIndex:i] objectForKey:@"XY"]];
            [icon addObject:[[tempData objectAtIndex:i] objectForKey:@"ICON_NAME"]];
            [hyperlink addObject:[[tempData objectAtIndex:i] objectForKey:@"HYPERLINK"]];

        }
    
    //SET TO STATIC VARIABLE
    [StaticObjects setMashName:name];
    [StaticObjects setMashCoordinate:xy];
    [StaticObjects setThemeIcon:icon];
    [StaticObjects setMashLink:hyperlink];
    NSLog(@"count -%d",[name count]);
    
    //POST NOTIFICATION AFTER EVERYTHING IS DONE
    [[NSNotificationCenter defaultCenter] postNotificationName:@"themeSearch" object:self userInfo:nil];

}




@end
