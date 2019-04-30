//
//  AddressSearch.h
//  FirstMapApp
//
//  Created by SLA MacBook on 4/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressSearch : NSOperation
{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;
    
}
@end
