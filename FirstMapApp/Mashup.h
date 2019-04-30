//
//  Mashup.h
//  FirstMapApp
//
//  Created by SLA MacBook on 2/1/14.
//  Copyright (c) 2014 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Mashup : NSOperation{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;
}

@end
