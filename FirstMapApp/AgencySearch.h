//
//  AgencySearch.h
//  FirstMapApp
//
//  Created by SLA MacBook on 20/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgencySearch : NSOperation{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;
}

@end
