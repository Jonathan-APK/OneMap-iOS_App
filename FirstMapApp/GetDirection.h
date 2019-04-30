//
//  GetDirection.h
//  FirstMapApp
//
//  Created by SLA MacBook on 11/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetDirection : NSOperation{
    NSURLConnection *currentConnection;
    NSMutableData *jsonData;
}
@end
