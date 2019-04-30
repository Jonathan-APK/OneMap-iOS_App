//
//  AgencySearch.m
//  FirstMapApp
//
//  Created by SLA MacBook on 20/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "AgencySearch.h"
#import "StaticObjects.h"

@implementation AgencySearch{
    
    int pageCounter;
    NSMutableArray *searchArray;
    NSMutableArray *theme;
    NSMutableArray *x;
    NSMutableArray *y;

}

- (void)start{
    
    pageCounter=0;
    searchArray = [[NSMutableArray alloc]init];
    theme = [[NSMutableArray alloc]init];
    x = [[NSMutableArray alloc]init];
    y = [[NSMutableArray alloc]init];

    
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
    
    for (int i=1; i<=10; i++) {
        
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/themesearch?token=qo/s2TnSUmfLz+32CvLC4RMVkzEFYjxqyti1KhByvEacEdMWBpCuSSQ+IFRT84QjGPBCuz/cBom8PfSm3GjEsGc8PkdEEOEr&wc=searchvallike'%%secondary%%'&otptflds=SEARCHVAL,THEME&returnGeom=1&rset=%d",i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    
    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request Agency search- %@",request);
    }
    
    }

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    
    [jsonData setLength:0];
    NSLog(@"Response - %@",jsonData);
}


-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    
    [jsonData appendData:data];
    NSLog(@"Receive Agency search- %@",jsonData);
}


-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"error with connection at get direction :%@",[error description]);
    currentConnection = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    pageCounter++;
    
    NSError*error;
    NSDictionary *json;
    
    NSString * jsonString =[[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    NSString * removeSpaceJson = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    //NSLog(@"GetDirection (json string format)- %@",removeSpaceJson);
    
    NSData * dataFormat = [removeSpaceJson dataUsingEncoding:NSUTF8StringEncoding];
    jsonData = [dataFormat mutableCopy];
    
    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    NSLog(@"Agency Search (json final format)- %@",json);
    
    if(json!=nil)
    {
        
        //CALL METHOD
        [self extractAgencySearch:(json)];
        
    }
    
}

-(void)extractAgencySearch:(NSDictionary *)jsonString
{
    
    //GET ITEM INSIDE directions:
    NSArray *tempData=[jsonString objectForKey:@"SearchResults"];
    NSLog(@"AS TEST -%@",tempData);
    
    
    for (int i=1; i<[tempData count]; i++) {
        
    //GET FIRST ITEM INSIDE ()
    NSDictionary *agencyCode = [tempData objectAtIndex:i];

    [searchArray addObject:[agencyCode objectForKey:@"SEARCHVAL"]];
    [theme addObject:[agencyCode objectForKey:@"THEME"]];
    [x addObject:[agencyCode objectForKey:@"X"]];
    [y addObject:[agencyCode objectForKey:@"Y"]];


    }
    
    if(pageCounter == 10){
    
    
    [StaticObjects setAgencyName:searchArray];
    [StaticObjects setAgencyTheme:theme];
    [StaticObjects setAgencyX:x];
    [StaticObjects setAgencyY:y];
    

    NSLog(@"AGENCY SEARCH STORE SUCCESSFULLY");
    }
        /*
    [[NSNotificationCenter defaultCenter] postNotificationName:@"waitForGetDirection" object:self];
    
    */
}




@end
