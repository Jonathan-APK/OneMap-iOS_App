//
//  GetDirection.m
//  FirstMapApp
//
//  Created by SLA MacBook on 11/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "GetDirection.h"
#import "StaticObjects.h"

@implementation GetDirection

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
    
    NSURLRequest *request;
    
    
    //CHECK IF USER SWAP THE ROUTE DIRECTION
    if ([StaticObjects getSwapRouteStatusForDirection] == YES) {
        
        request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/route/solve?token=%@&routeStops=%@,%@;%@,%@&routemode=DRIVE&avoidERP=%d&routeOption=%@",[StaticObjects getToken],[StaticObjects getEndDirectionX],[StaticObjects getEndDirectionY],[StaticObjects getStartDirectionX],[StaticObjects getStartDirectionY],[StaticObjects getERP],[StaticObjects getRoute]]]];
    }
    else{
        
         request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/route/solve?token=%@&routeStops=%@,%@;%@,%@&routemode=DRIVE&avoidERP=%d&routeOption=%@",[StaticObjects getToken],[StaticObjects getStartDirectionX],[StaticObjects getStartDirectionY],[StaticObjects getEndDirectionX],[StaticObjects getEndDirectionY],[StaticObjects getERP],[StaticObjects getRoute]]]];
        
    }
    
    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request Get Directon- %@",request);
}


//-------------------------------------//
//METHOD WILL RUN WHEN RECEIVE RESPONSE//
//-------------------------------------//
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    
    [jsonData setLength:0];
    //NSLog(@"Response - %@",jsonData);
}



//---------------------------------//
//METHOD WILL RUN WHEN RECEIVE DATA//
//---------------------------------//
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    
    [jsonData appendData:data];
    NSLog(@"Receive get direction- %@",jsonData);
}



//------------------------------------//
//METHOD WILL RUN WHEN THERE IS ERROR //
//------------------------------------//
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"error with connection at get direction :%@",[error description]);
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
    
    NSLog(@"GetDirection (json string format)- %@",jsonString);
    
    NSData * dataFormat = [removeSpaceJson dataUsingEncoding:NSUTF8StringEncoding];
    jsonData = [dataFormat mutableCopy];
    
    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"GetDirection (json final format)- %@",json);
    
    
    if([[NSString stringWithFormat:@"%@",[json objectForKey:@"directions"]] isEqualToString:[NSString stringWithFormat:@"(null)"]]){
        
        NSLog(@"Get Direction Reply Null");
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:[NSString stringWithFormat:@"request error"] forKey:@"error"];
        
        //RETURN ERROR MESSAGE TO GET DIRECTION VIEW CONTROLLER
        [[NSNotificationCenter defaultCenter] postNotificationName:@"waitForGetDirection" object:self userInfo:userInfo];
        
        
        }
   
    else
        {
            //CALL METHOD
            [self extractDirection:(json)];
            
                }
    
}



//----------------------------//
//EXTRACT DATA FROM JSON REPLY//
//----------------------------//
-(void)extractDirection:(NSDictionary *)jsonString
{
    
    
    //GET ITEM INSIDE directions:
    NSArray *tempData=[jsonString objectForKey:@"directions"];
    //GET FIRST ITEM INSIDE ()
    NSDictionary *revcode = [tempData objectAtIndex:0];
    //GET ALL ITEM INSIDE features
    NSArray *attribute=[revcode objectForKey:@"features"];
    
    //GET AND SET TOTAL DISTANCE (setDriveDistanceStop is use for both public transport and get direction)
    NSMutableArray *tempDistance = [[revcode objectForKey:@"summary"] objectForKey:@"totalLength"];
    double distance2 = [[NSString stringWithFormat:@"%@",tempDistance] doubleValue];
    [StaticObjects setDriveDistanceStop:[NSString stringWithFormat:@"%0.2fKm",distance2]];

    //DIRECTION
    NSInteger count=[attribute count];

    NSMutableArray *directionText = [[NSMutableArray alloc]init];
    NSMutableArray *distance = [[NSMutableArray alloc]init];
    NSMutableArray *time = [[NSMutableArray alloc]init];
    
    for(int i=1; i<count-1;i++)
    {
        [directionText addObject: [[[attribute objectAtIndex:i] objectForKey:@"attributes"] objectForKey:@"text"]];
        
        [distance addObject: [[[attribute objectAtIndex:i] objectForKey:@"attributes"] objectForKey:@"length"]];
        
        [time addObject:[[[attribute objectAtIndex:i] objectForKey:@"attributes"] objectForKey:@"time"]];    }
    
    //SET TO STATIC VARIABLE
    [StaticObjects setRouteDirection:directionText];
    [StaticObjects setRouteDistance:distance];
    [StaticObjects setRouteTime:time];
    
    
    //GET ITEM INSIDE SUMMARY
    NSDictionary *summary=[revcode objectForKey:@"summary"];
    //GET ITEM INSIDE envelope
    NSMutableDictionary *envel=[summary objectForKey:@"envelope"];

    NSString *xmax=[envel objectForKey:@"xmax"];
    NSString *xmin=[envel objectForKey:@"xmin"];
    NSString *ymax=[envel objectForKey:@"ymax"];
    NSString *ymin=[envel objectForKey:@"ymin"];

    
    //ADD ALL COORDINATE INTO ARRAY
    NSMutableArray * envelopeArray = [[NSMutableArray alloc] init];
    [envelopeArray addObject:xmax];
    [envelopeArray addObject:xmin];
    [envelopeArray addObject:ymax];
    [envelopeArray addObject:ymin];

    //SET ARRAY INTO STATIC OBJECT
    [StaticObjects setEnvelope:envelopeArray];
    
    
    //GET ITEM INSIDE routes
    NSDictionary *routes=[jsonString objectForKey:@"routes"];

    //GET ITEM INSIDE features
    NSArray *route2=[routes objectForKey:@"features"];

    //GET FIRST ITEM INSIDE ()
    NSDictionary *att=[route2 objectAtIndex:0];

    //GET INSIDE INSIDE geometry
    NSMutableDictionary *geo=[att objectForKey:@"geometry"];

    //GET ITEM INSIDE paths
    NSArray *temp=[geo objectForKey:@"paths"];

    //GET ARRAY OF cordinates
    NSArray *cordinates=[temp objectAtIndex:0];//the array of cordinates

    
    //SET TO STATIC VARIABLE
    [StaticObjects setDirectionCoor:cordinates];
    
    
    NSLog(@"GET DIRECTION STORE SUCCESSFULLY");
    
    //RETURN NOTIFICATON TO GET DIRECTION VIEW CONTROLLER THAT TASK HAS FINISH EXECUTING
    [[NSNotificationCenter defaultCenter] postNotificationName:@"waitForGetDirection" object:self];


}



@end
