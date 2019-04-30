//
//  PublicTransport.h
//  FirstMapApp
//
//  Created by SLA MacBook on 18/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicTransport : NSOperation{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;
    
}

@end
