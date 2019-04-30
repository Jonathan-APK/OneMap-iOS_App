//
//  GetToken.m
//  FirstMapApp
//
//  Created by SLA MacBook on 3/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "GetToken.h"
#import "StaticObjects.h"

@implementation GetToken


-(void)start{
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.onemap.sg/API/services.svc/getToken?accessKEY=qo/s2TnSUmfLz+32CvLC4RMVkzEFYjxqyti1KhByvEacEdMWBpCuSSQ+IFRT84QjGPBCuz/cBom8PfSm3GjEsGc8PkdEEOEr"]]];
    currentConnection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    NSLog(@"Request General Token - %@",request);
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
    NSDictionary *json ;
    NSError*error;

    json =[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if(json!=nil)
    {
        NSLog(@"GetToken Reply: %@",json);
        //EXTRACTS THE TOKEN
        NSString * extracted = [self extractToken:(json)];
         NSLog(@"Token- %@",extracted);
        
        //SET TOKEN TO STATIC VARIABLE IN STATICOBJECT
        [StaticObjects setToken:extracted];
        
        NSLog(@"GETTOKEN RESULT SET");
        
        

                  }
   
}



//----------------------------//
//EXTRACT DATA FROM JSON REPLY//
//----------------------------//
-(NSString*)extractToken:(NSDictionary *)jsonString
{
    //GET NEWTOKEN STRING   EXAMPLE: ( { NewToken = ... } )
    NSArray* data = [jsonString objectForKey:@"GetToken"];
    
    //REMOVE ()
    NSDictionary *tk = [data objectAtIndex:0];
    
    //REMOVE {} AND GET TOKEN VALUE
    NSString *tokens=[tk objectForKey:@"NewToken"];
    
    return tokens;
}

@end
