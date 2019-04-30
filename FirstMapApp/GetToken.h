//
//  GetToken.h
//  FirstMapApp
//
//  Created by SLA MacBook on 3/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetToken : NSOperation{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;
    
    }


@end
