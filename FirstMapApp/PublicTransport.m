//
//  PublicTransport.m
//  FirstMapApp
//
//  Created by SLA MacBook on 18/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "PublicTransport.h"
#import "StaticObjects.h"

@implementation PublicTransport{
    int counter;
    bool getTransferStatus;
    bool getAlightCoordinateStatus;
    NSMutableArray *boardX;
    NSMutableArray *boardY;
    NSMutableArray *alightX;
    NSMutableArray *alightY;

}

- (void)start{
    
    counter =0;
    getTransferStatus = NO;
    getAlightCoordinateStatus = NO;
    boardX = [[NSMutableArray alloc]init];
    boardY = [[NSMutableArray alloc]init];
    alightX = [[NSMutableArray alloc]init];
    alightY = [[NSMutableArray alloc]init];

    
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
    
    //CHECK IF USER SWAP ROUTE DIRECTION
    if ([StaticObjects getSwapRouteStatusForPublic] == YES) {

        //SEND REQUEST TO SERVER
        request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/publictransportation/service1.svc/routesolns?token=%@&sl=%@,%@&el=%@,%@&startstop=&endstop=&walkdist=300&mode=%@&routeopt=%@&retgeo=true&maxsolns=1&callback=",[StaticObjects getToken],[StaticObjects getEndPublicX],[StaticObjects getEndPublicY],[StaticObjects getStartPublicX],[StaticObjects getStartPublicY],[StaticObjects getMode],[StaticObjects getRoute]]]];

    }
    else{
        
        //SEND REQUEST TO SERVER
        request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/publictransportation/service1.svc/routesolns?token=%@&sl=%@,%@&el=%@,%@&startstop=&endstop=&walkdist=300&mode=%@&routeopt=%@&retgeo=true&maxsolns=1&callback=",[StaticObjects getToken],[StaticObjects getStartPublicX],[StaticObjects getStartPublicY],[StaticObjects getEndPublicX],[StaticObjects getEndPublicY],[StaticObjects getMode],[StaticObjects getRoute]]]];
        
    }
    
    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request Public Transport- %@",request);
}

//-------------------------------------//
//METHOD WILL RUN WHEN RECEIVE RESPONSE//
//-------------------------------------//
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    
    [jsonData setLength:0];
    NSLog(@"PUBLIC TRANSPORT Response - %@",jsonData);
}

//---------------------------------//
//METHOD WILL RUN WHEN RECEIVE DATA//
//---------------------------------//
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    
    [jsonData appendData:data];
    NSLog(@"Receive PUBLIC TRANSPORT- %@",jsonData);
}

//------------------------------------//
//METHOD WILL RUN WHEN THERE IS ERROR //
//------------------------------------//
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"error with connection at PUBLIC TRANSPORT :%@",[error description]);
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
    NSData * dataFormat = [removeSpaceJson dataUsingEncoding:NSUTF8StringEncoding];
    jsonData = [dataFormat mutableCopy];
    
    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Public Transport (json final format)- %@",json);

    //CHECK IF WE ARE CHECKING FOR TRANSFER COORDINATE
    if (getTransferStatus == YES) {
        
        //YES = CHECKING FOR ALIGHT COORDINATE
        if (getAlightCoordinateStatus == YES) {
            
            [self extractTransferCoordinateAlight:json];
        
        }
        //ELSE = CHECKING FOR BOARD COORDINATE
        else {
        
            [self extractTransferCoordinateBoard:json];
        
        }
    }
    
    
    else{
        
        //CHECK FOR ERROR OR FAILED TO GET DIRECTION MESSAGE
        if([[NSString stringWithFormat:@"%@",[json objectForKey:@"BusRoute"]] isEqualToString:[NSString stringWithFormat:@"(null)"]] || [[NSString stringWithFormat:@"%@",[[[json objectForKey:@"BusRoute"] objectAtIndex:0] objectForKey:@"PATH"]] isEqualToString:[NSString stringWithFormat:@"(null)"]])
        {
    
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stoploading" object:self];
        
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Request Timeout" message:@"Failed to Get Direction" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        
        }
    
        else
        {
        
            //CALL METHOD TO EXTRACT JSON REPLY TO GET INFO
            [self extractPublicTransport:(json)];
        
        }
        }
    
}

//------------------------------//
//EXTRACT JSON REPLY TO GET INFO//
//------------------------------//
-(void)extractPublicTransport:(NSDictionary *)jsonString
{
    
    //GET ITEM INSIDE directions:
    NSArray *tempData=[jsonString objectForKey:@"BusRoute"];
    

    //GET 1st  ITEM
    NSDictionary *buscode = [tempData objectAtIndex:0];
    
    //GET ITEM INSIDE PATH
    NSArray *attribute=[buscode objectForKey:@"PATH"];
    
    //GET ITEM INSIDE STEPS
    NSArray *step=[buscode objectForKey:@"STEPS"];
    
    
    //GET AND SET TOTAL STOP (setDriveDistanceStop is use for both public transport and get direction)
    [StaticObjects setDriveDistanceStop:[NSString stringWithFormat:@"Total Stops: %@",[buscode objectForKey:@"TotalStops"]]];
    
    NSLog(@"TEST1 -%@",[StaticObjects getDriveDistanceStop]);
    
    //COUNT STEP ARRAY
    NSInteger count=[step count];
    
    //ALLOCATE
    NSMutableArray *alight = [[NSMutableArray alloc]init];
    NSMutableArray *board = [[NSMutableArray alloc]init];
    NSMutableArray *noOfStop = [[NSMutableArray alloc]init];
    NSMutableArray *routeType = [[NSMutableArray alloc]init];
    NSMutableArray *serviceType = [[NSMutableArray alloc]init];
    NSMutableArray *serviceID = [[NSMutableArray alloc]init];
    NSMutableArray *boardID = [[NSMutableArray alloc]init];
    NSMutableArray *alightID = [[NSMutableArray alloc]init];


    
    //LOOP TO STORE INFORMATION INTO ARRAY
    for(int i=0; i<count;i++)
    {
        [alight addObject: [[step objectAtIndex:i] objectForKey:@"AlightDesc"]];
        [board addObject: [[step objectAtIndex:i] objectForKey:@"BoardDesc"]];
        [noOfStop addObject:[[step objectAtIndex:i] objectForKey:@"NumberOfStop"]];
        [routeType addObject:[[step objectAtIndex:i] objectForKey:@"type"]];
        [serviceType addObject:[[step objectAtIndex:i] objectForKey:@"ServiceType"]];
        [serviceID addObject:[[step objectAtIndex:i] objectForKey:@"ServiceID"]];
        [boardID addObject:[[step objectAtIndex:i] objectForKey:@"BoardId"]];
        [alightID addObject:[[step objectAtIndex:i] objectForKey:@"AlightId"]];

    }
    
    //REPLACE EMPTY "BOARDDESC" INFORMATION WITH "ALIGHT DESC" FROM PREVIOUS STOP FOR JOURNEY THAT REQUIRE CHANGING OF BUS INBETWEEN JOURNEY
    for (int i=0; i<[board count]; i++) {

        if ([[board objectAtIndex:i] isEqualToString:@""]) {
            [board replaceObjectAtIndex:i withObject:[alight objectAtIndex:i-1]];

        }
        
    }
    
    //STORE INFO INTO STATIC ARRAY
    [StaticObjects setBusAlight:alight];
    [StaticObjects setBusBoard:board];
    [StaticObjects setNoBusStop:noOfStop];
    [StaticObjects setRouteType:routeType];
    [StaticObjects setServiceType:serviceType];
    [StaticObjects setServiceID:serviceID];
    [StaticObjects setBoardID:boardID];
    [StaticObjects setAlightID:alightID];
    
    
    //TESTING FOR DEBUGGING
    NSLog(@"TESTbuslign -%@",[StaticObjects getBusAlight]);
    NSLog(@"TESTbusboard -%@",[StaticObjects getBusBoard]);
    NSLog(@"TESTnoofstop -%@",[StaticObjects getNoBusStop]);
    NSLog(@"TESTroutetype -%@",[StaticObjects getRouteType]);
    NSLog(@"TESTservicetype -%@",[StaticObjects getServiceType]);
    NSLog(@"TESTserviceid -%@",[StaticObjects getServiceID]);
    NSLog(@"TESTboardid -%@",[StaticObjects getBoardID]);
    NSLog(@"TESTalignid -%@",[StaticObjects getAlightID]);

    
    NSArray *cordinates=[attribute objectAtIndex:0];//the array of cordinates
    
    //GET COORDINATE OF STARTING AND ENDING STOP
    NSArray *buscor=[cordinates objectAtIndex:0];//the array of cordinates
    NSString * replaceString = [[NSString stringWithFormat:@"%@",buscor] stringByReplacingOccurrencesOfString:@";" withString:@","];
    NSArray *arr = [replaceString componentsSeparatedByString:@","];
    NSArray *startEndCorr = @[[arr objectAtIndex:0],[arr objectAtIndex:1],[arr objectAtIndex:([arr count]-2)],[arr objectAtIndex:([arr count]-1)]];

    //SET TO STATIC OBJECT
    [StaticObjects setStartEndBusCorr:startEndCorr];
    
    [StaticObjects setBusCoor:cordinates];
    
    NSLog(@"TEST5 -%@",[StaticObjects getStartEndBusCorr]);
    NSLog(@"TEST6 -%@",[StaticObjects getBusCoor]);

    //NEXT CALL METHOD TO FIND COORDINATE OF TRANSFER
    [self getTranferCoordinate];
    
    NSLog(@"PUBLIC TRANSPORT STORE SUCCESSFULLY");
    

}

//-----------------------------------------------//
//GET COORDINATE OF TRANSFER (USE REST API FIRST)//
//-----------------------------------------------//
-(void)getTranferCoordinate{
    
    //YES = CHECKING FOR TRANSFER COORDINATE
    getTransferStatus = YES;
    NSURLRequest *request;
    
    //CHECK IF CHECKING FOR ALIGHT COORDINATE FIRST OR BOARD COORDINATE
    if (getAlightCoordinateStatus ==YES) {
        
        //CHECK IF THE ALIGHT LOCATION IS BUS STOP OR MRT (MRT ID LENGTH LESS THAN 5)
        if ([[NSString stringWithFormat:@"%@",[[StaticObjects getAlightID]objectAtIndex:counter]] length] <= 4) {
            
            // <NOTE> NEED TO CHECK FOR ESCAPE CHARACTER USING (stringByAddingPercentEscapesUsingEncoding)
            request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/basicSearch?token=%@&wc=SEARCHVAL LIKE '$%@'&otptFlds=CATEGORY&returnGeom=0&nohaxr=10",[StaticObjects getToken],[[StaticObjects getAlightID]objectAtIndex:counter]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
        }
        
        //ALIGHT LOCATION IS BUS STOP
        else{
            
            // <NOTE> NEED TO CHECK FOR ESCAPE CHARACTER USING (stringByAddingPercentEscapesUsingEncoding)
            request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/basicSearch?token=%@&wc=SEARCHVAL LIKE '%@$'&otptFlds=CATEGORY&returnGeom=0&nohaxr=10",[StaticObjects getToken],[[StaticObjects getAlightID]objectAtIndex:counter]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    
    
    //ELSE = CHECKING FOR BOARD COODINATE FIRST
    else{
        
        //CHECK IF THE ALIGHT LOCATION IS BUS STOP OR MRT (MRT ID LENGTH LESS THAN 5)
        if ([[NSString stringWithFormat:@"%@",[[StaticObjects getBoardID]objectAtIndex:counter]] length] <= 4) {
            
            // <NOTE> NEED TO CHECK FOR ESCAPE CHARACTER USING (stringByAddingPercentEscapesUsingEncoding)
            request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/basicSearch?token=%@&wc=SEARCHVAL LIKE '$%@'&otptFlds=CATEGORY&returnGeom=0&nohaxr=10",[StaticObjects getToken],[[StaticObjects getBoardID]objectAtIndex:counter]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
        }
        
        //ALIGHT LOCATION IS BUS STOP
        else{
        
            // <NOTE> NEED TO CHECK FOR ESCAPE CHARACTER USING (stringByAddingPercentEscapesUsingEncoding)
            request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/basicSearch?token=%@&wc=SEARCHVAL LIKE '%@$'&otptFlds=CATEGORY&returnGeom=0&nohaxr=10",[StaticObjects getToken],[[StaticObjects getBoardID]objectAtIndex:counter]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
        
        }
        
    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    NSLog(@"REQUEST -%@",request);
    
}


//-------------------------------------//
//EXTRACT BOARD COORDINATE FOR TRANSFER//
//-------------------------------------//
-(void)extractTransferCoordinateBoard:(NSDictionary *)jsonString{
    
    NSArray *tempData=[jsonString objectForKey:@"SearchResults"];
    
    //CHECK IF IS ERROR MESSAGE (IF ERROR MESSAGE DON STORE DATA INTO ARRAY)
    if ([[NSString stringWithFormat:@"%@",[[tempData objectAtIndex:0] objectForKey:@"ErrorMessage"]] isEqualToString:@"(null)"]) {
    
    [boardX addObject: [[tempData objectAtIndex:1] objectForKey:@"X"]];
    [boardY addObject: [[tempData objectAtIndex:1] objectForKey:@"Y"]];
    
    }
    
    //COUNTER TO INDICATE NO. OF FINISHED ITEMS
    counter++;

    //CHECK IF THERE IS COORDINATE TO CHECK
    if (counter < [[StaticObjects getBoardID] count]) {
        
        [self getTranferCoordinate];
        
    }
    
    //ELSE = FINISH GETTING COORDINATE FOR BOARD LOCATION, MOVING ON TO GET ALIGHT COORDINATE
    else{
        NSLog(@"COMPLETEboardX -%@",boardX);
        NSLog(@"COMPLETEboardY -%@",boardY);
        
        //RESET COUNTER
        counter =0;
        
        //INDICATE WE ARE CHECKING FOR ALIGHT COORDINATE NOW
        getAlightCoordinateStatus = YES;
        
        //CALL METHOD
        [self getTranferCoordinate];

        }
    
    
}


//--------------------------------------//
//EXTRACT ALIGHT COORDINATE FOR TRANSFER//
//--------------------------------------//
-(void)extractTransferCoordinateAlight:(NSDictionary *)jsonString{
    
    NSArray *tempData=[jsonString objectForKey:@"SearchResults"];
    
    //CHECK IF IS ERROR MESSAGE (IF ERROR MESSAGE DON STORE DATA INTO ARRAY)
    if ([[NSString stringWithFormat:@"%@",[[tempData objectAtIndex:0] objectForKey:@"ErrorMessage"]] isEqualToString:@"(null)"]) {
        
        [alightX addObject: [[tempData objectAtIndex:1] objectForKey:@"X"]];
        [alightY addObject: [[tempData objectAtIndex:1] objectForKey:@"Y"]];
        
        
    }
    
    //COUNTER TO INDICATE NO. OF FINISHED ITEMS
    counter++;
    
    //CHECK IF THERE IS COORDINATE TO CHECK
    if (counter < [[StaticObjects getAlightID] count]) {
        
        [self getTranferCoordinate];
        
    }
    
    //ELSE = FINISH GETTING COORDINATE FOR ALIGHT LOCATION, EXIT TO MAIN VIEW
    else{
        NSLog(@"COMPLETEalightX -%@",alightX);
        NSLog(@"COMPLETEalightY -%@",alightY);
        
        //STORE ALL BOARD, ALIGHT ARRAY INTO A tempArray
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        [tempArray addObject:boardX];
        [tempArray addObject:boardY];
        [tempArray addObject:alightX];
        [tempArray addObject:alightY];

        //STORE tempArray INTO A STATIC ARRAY
        [StaticObjects setTransferCoordinate:tempArray];
        
        //RESET COUNTER
        counter = 0;
        
        //CHANGE STATUS TO NOT CHECKING FOR TRANSFER COORDINATE
        getTransferStatus = NO;
        
        //CHANGE STATUS TO NOT CHECKING FOR TRANSER (ALIGHT COORDINATE)
        getAlightCoordinateStatus =NO;
    
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"waitForPublicTransport" object:self];
        
       
        
    }
}

@end
