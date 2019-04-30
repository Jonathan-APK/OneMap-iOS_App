//
//  ReverseGeocode.m
//  FirstMapApp
//
//  Created by SLA MacBook on 9/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "ReverseGeocode.h"
#import "StaticObjects.h"

@implementation ReverseGeocode{
    BOOL status;
    NSMutableArray* tempCoordinate;
}

- (void)start:(NSMutableArray*)stat{

    tempCoordinate = stat;
    [self main];
}

- (void)main{

    jsonData=[[NSMutableData alloc]init];
    NSURLRequest *request;
    
    //CHECK IF YOU ARE USING REVERSEGEOCODE API FOR ADDRESS SEARCH FUNCTION
    if(tempCoordinate == nil){
        
        status = YES;
        request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/revgeocode?token=%@&location=%@,%@",[StaticObjects getToken],[StaticObjects getXCoor],[StaticObjects getYCoor]]]];
    
    }
    //CHECK IF USER IS USING API FOR IDENTIFY BUTTON
    else {
    
        status = NO;
        request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/revgeocode?token=%@&location=%@,%@",[StaticObjects getToken],[tempCoordinate objectAtIndex:0],[tempCoordinate objectAtIndex:1]]]];
        
    }
    
        currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request reverse geocode - %@",request);
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
    //NSLog(@"Receive rev code- %@",jsonData);
}



//------------------------------------//
//METHOD WILL RUN WHEN THERE IS ERROR //
//------------------------------------//
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"error with connection at Reverse Geocode :%@",[error description]);
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
    
    NSLog(@"json string format- %@",removeSpaceJson);
    
    NSData * dataFormat = [removeSpaceJson dataUsingEncoding:NSUTF8StringEncoding];
    jsonData = [dataFormat mutableCopy];
    
    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"json final format- %@",json);

    //CHECK IF REPLY IS NULL
    if (tempCoordinate !=nil && json == nil){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLoadingMain" object:self];
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"No Address Found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else 
    {
        
        //CALL METHOD
        [self extractGeocode:(json)];
        
    }
    
}

//---------------------------//
//EXTRACT DATA FROM API REPLY//
//---------------------------//
-(void)extractGeocode:(NSDictionary *)jsonString
{
    //GET ITEM INSIDE GeocodeInfo:
    NSArray *tempData=[jsonString objectForKey:@"GeocodeInfo"];
    
    //REMOVE ()
    NSDictionary *revcode = [tempData objectAtIndex:0];
    
    //SET TO STATIC VARIABLE
    [StaticObjects setBuilding:[revcode objectForKey:@"BUILDINGNAME"]];
    [StaticObjects setAddress:[NSString stringWithFormat:@"BLK %@ %@ %@",[revcode objectForKey:@"BLOCK"],[revcode objectForKey:@"ROAD"],[revcode objectForKey:@"POSTALCODE"]]];
    
    //TESTING PURPOSE
    NSLog(@"building after- %@",[StaticObjects getBuilding]);
    NSLog(@"address after- %@",[StaticObjects getAddress]);
    NSLog(@"REVERSE GEOCODE STORE SUCCESSFULLY");
    
    if(status ==YES){

    //SEND NOTIFICATION TO MOVE TO LOCATION
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeToLocation" object:self];
    
    //SEND NOTIFICATION TO STOP LOADING
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLoadingMain" object:self];
    
    }
    else{
        
        NSDictionary * arrayInfo = [NSDictionary dictionaryWithObjectsAndKeys:tempCoordinate,@"myArray",nil];
        NSLog(@"ARRAYINFO -%@",arrayInfo);
        
        //SEND NOTIFICATION ONCE DONE
        [[NSNotificationCenter defaultCenter] postNotificationName:@"displayCallout" object:self userInfo:arrayInfo];

    }

   }



@end
