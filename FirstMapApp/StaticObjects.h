//
//  StaticObjects.h
//  FirstMapApp
//
//  Created by SLA MacBook on 3/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaticObjects : NSOperation{
    
}
//GetToken//
+(void)setToken:(NSString *) tk;
+(NSString *)getToken;


//AddressSearch//
+(void)setName:(NSMutableArray *) searchName;
+(NSMutableArray *)getName;

+(void)setCategory:(NSMutableArray *) searchCategory;
+(NSMutableArray *)getCategory;

+(void)setX:(NSMutableArray *) searchX;
+(NSMutableArray *)getX;

+(void)setY:(NSMutableArray *) searchY;
+(NSMutableArray *)getY;

+(void)setYCoorrdinate:(NSString *)setYCoor;
+(NSString *)getYCoor;

+(void)setXCoorrdinate:(NSString *)setXCoor;
+(NSString *)getXCoor;

+(void)setNameOfAddress:(NSString *)nameCell;
+(NSString *)getNameOfAddress;

+(void)setCallFrom:(NSString *) from;
+(NSString *)getCallFrom;



//Search Function
+(void)setSearchKeyword:(NSString *) key;
+(NSString *)getSearchKeyword;

//Reverse Geocode
+(void)setAddress:(NSString *)setAddress;
+(NSString *)getAddress;

+(void)setBuilding:(NSString *)setbuilding;
+(NSString *)getBuilding;

//Get Direction
+(void)setDirectionCoor:(NSArray *) coor;
+(NSArray *)getDirectionCoor;

+(void)setCurrentX:(double) coorX;
+(double)getCurrentX;

+(void)setCurrentY:(double) coorY;
+(double)getCurrentY;

+(void)setERP:(bool) tempERP;
+(bool)getERP;

+(void)setDriveDistanceStop:(NSString *) distance;
+(NSString *)getDriveDistanceStop;

+(void)setRoute:(NSString *) tempRoute;
+(NSString *)getRoute;

+(void)setEnvelope:(NSMutableArray *) envel;
+(NSMutableArray *)getEnvelope;

+(void)setRouteDirection:(NSMutableArray *) text;
+(NSMutableArray *)getRouteDirection;

+(void)setRouteDistance:(NSMutableArray *) distance;
+(NSMutableArray *)getRouteDistance;

+(void)setRouteTime:(NSMutableArray *) time;
+(NSMutableArray *)getRouteTime;

+(void)setSwapRouteStatusForDirection:(BOOL) swap;
+(BOOL)getSwapRouteStatusForDirection;


+(void)setStartDirectionX:(NSString *) x;
+(NSString *)getStartDirectionX;

+(void)setStartDirectionY:(NSString *) y;
+(NSString *)getStartDirectionY;

+(void)setEndDirectionX:(NSString *) x;
+(NSString *)getEndDirectionX;

+(void)setEndDirectionY:(NSString *) y;
+(NSString *)getEndDirectionY;

+(void)setStartName:(NSString *) name;
+(NSString *)getStartName;

+(void)setEndName:(NSString *) name;
+(NSString *)getEndName;

//Public Transport
+(void)setBusCoor:(NSArray *) coor;
+(NSArray *)getBusCoor;

+(void)setMode:(NSString *) tempMode;
+(NSString *)getMode;

+(void)setStartEndBusCorr:(NSArray *) coor;
+(NSArray *)getStartEndBusCorr;

+(void)setBusAlight:(NSMutableArray *) alight;
+(NSMutableArray *)getBusAlight;

+(void)setBusBoard:(NSMutableArray *) board;
+(NSMutableArray *)getBusBoard;

+(void)setNoBusStop:(NSMutableArray *) noofstop;
+(NSMutableArray *)getNoBusStop;

+(void)setRouteType:(NSMutableArray *) type;
+(NSMutableArray *)getRouteType;

+(void)setServiceType:(NSMutableArray *) type;
+(NSMutableArray *)getServiceType;

+(void)setServiceID:(NSMutableArray *) serviceid;
+(NSMutableArray *)getServiceID;

+(void)setBoardID:(NSMutableArray *) boardid;
+(NSMutableArray *)getBoardID;

+(void)setAlightID:(NSMutableArray *) alightid;
+(NSMutableArray *)getAlightID;

+(void)setTransferCoordinate:(NSMutableArray *) coor;
+(NSMutableArray *)getTransferCoordinate;

+(void)setSwapRouteStatusForPublic:(BOOL) swap;
+(BOOL)getSwapRouteStatusForPublic;

+(void)setStartPublicX:(NSString *) x;
+(NSString *)getStartPublicX;

+(void)setStartPublicY:(NSString *) y;
+(NSString *)getStartPublicY;

+(void)setEndPublicX:(NSString *) x;
+(NSString *)getEndPublicX;

+(void)setEndPublicY:(NSString *) y;
+(NSString *)getEndPublicY;


//Agency Search
+(void)setAgencyName:(NSMutableArray *)tempname;
+(NSMutableArray *)getAgencyName;

+(void)setAgencyTheme:(NSMutableArray *)temptheme;
+(NSMutableArray *)getAgencyTheme;

+(void)setAgencyX:(NSMutableArray *)tempx;
+(NSMutableArray *)getAgencyX;

+(void)setAgencyY:(NSMutableArray *)tempy;
+(NSMutableArray *)getAgencyY;


//Mashup
+(void)setMashName:(NSMutableArray *)name;
+(NSMutableArray *)getMashName;

+(void)setMashCoordinate:(NSMutableArray *)coor;
+(NSMutableArray *)getMashCoordinate;

+(void)setMashLink:(NSMutableArray *)link;
+(NSMutableArray *)getMashLink;

+(void)setThemeIcon:(NSMutableArray *)icon;
+(NSMutableArray *)getThemeIcon;

+(void)setThemeName:(NSString *) theme;
+(NSString *)getThemeName;

+(void)setThemeStatus:(bool) status;
+(bool)getThemeStatus;

+(void)setDisplayTheme:(bool) display;
+(bool)getDisplayTheme;

//Identify Status
+(void)setIdentifyStatus:(bool) identify;
+(bool)getIdentifyStatus;

@end
