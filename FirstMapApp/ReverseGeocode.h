//
//  ReverseGeocode.h
//  FirstMapApp
//
//  Created by SLA MacBook on 9/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReverseGeocode : NSOperation{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;

}
- (void)start:(NSMutableArray*)stat;

@end
