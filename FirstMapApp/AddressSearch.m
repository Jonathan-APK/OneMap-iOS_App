//
//  AddressSearch.m
//  FirstMapApp
//
//  Created by SLA MacBook on 4/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "AddressSearch.h"
#import "StaticObjects.h"
#import "SearchAddressController.h"

@implementation AddressSearch

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
    
    //SEND REQUEST TO SERVER
    //<NOTE> NEED TO CHECK FOR ESCAPE CHARACTER USING (stringByAddingPercentEscapesUsingEncoding)
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/basicSearch?token=%@&searchVal=%@&otptFlds=SEARCHVAL,CATEGORY&returnGeom=1&rset=1",[StaticObjects getToken],[StaticObjects getSearchKeyword]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request address search - %@",request);
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
    NSLog(@"Receive - %@",jsonData);
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
    
    //NSLog(@"json string format- %@",removeSpaceJson);
    
    NSData * dataFormat = [removeSpaceJson dataUsingEncoding:NSUTF8StringEncoding];
    jsonData = [dataFormat mutableCopy];
    
    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if(json!=nil)
    {
    
        //EXTRACTS THE ADDRESS INFO
        [self extractAddress:(json)];
        
        if ([[StaticObjects getCallFrom] isEqualToString:@"searchview"]) {
            
            //NOTIFY SEARCHADDRESSCONTROLLER TO REFRESH TABLEVIEW AFTER GETTING & STORING JSON REPLY
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTable" object:self];
        
        }
        else if([[StaticObjects getCallFrom] isEqualToString:@"getdirection"]){
        
            //NOTIFY GetDirection TO REFRESH TABLEVIEW AFTER GETTING & STORING JSON REPLY
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchAPIDoneForGetDirection" object:self];

            
        }
        else if([[StaticObjects getCallFrom] isEqualToString:@"publictransport"]){
            
            //NOTIFY PUBLIC TRANSPORT TO REFRESH TABLEVIEW AFTER GETTING & STORING JSON REPLY
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchAPIDoneForPublicTransport" object:self];
            
            
        }
        
    }
   
    
}

//----------------------------//
//EXTRACT DATA FROM JSON REPLY//
//----------------------------//
-(void)extractAddress:(NSDictionary *)jsonString
{
    
    NSLog(@"GetAddress Reply- %@",jsonString);
    
    NSArray *tempData=[jsonString objectForKey:@"SearchResults"];
  
    //RETURN NO RESULT FOUND MESSAGE
    if ([[[tempData objectAtIndex:0] objectForKey:@"ErrorMessage"] isEqualToString:@"No result(s) found."]) {
        
        //NO RESULT FOUND SET VARIABLE TO NIL
        [StaticObjects setName:Nil];

        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"No Result"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];

    }
    

    //EXTRACT & STORE IN STATIC VARIABLE
    else{
    
    NSInteger count=[tempData count];
    
    NSMutableArray *name = [[NSMutableArray alloc]init];
    NSMutableArray *category = [[NSMutableArray alloc]init];
    NSMutableArray *x = [[NSMutableArray alloc]init];
    NSMutableArray *y = [[NSMutableArray alloc]init];
    
    for(int i=1; i<count;i++)
    {
        [name addObject: [[tempData objectAtIndex:i] objectForKey:@"SEARCHVAL"]];
        [category addObject: [[tempData objectAtIndex:i] objectForKey:@"CATEGORY"]];
        [x addObject: [[tempData objectAtIndex:i] objectForKey:@"X"]];
        [y addObject: [[tempData objectAtIndex:i] objectForKey:@"Y"]];
        
    }
    
    //STORE IN STATICOBJECT VARIABLE
    [StaticObjects setName:name];
    [StaticObjects setCategory:category];
    [StaticObjects setX:x];
    [StaticObjects setY:y];
    
    NSLog(@"ADDRESS RESULT SET");
        
    }
  
}

@end
