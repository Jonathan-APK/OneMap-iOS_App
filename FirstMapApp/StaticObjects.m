//
//  StaticObjects.m
//  FirstMapApp
//
//  Created by SLA MacBook on 3/12/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "StaticObjects.h"

@implementation StaticObjects

//GetToken 
static NSString * token;

//AddressSearch
static NSMutableArray *name;
static NSMutableArray *category;
static NSMutableArray *x;
static NSMutableArray *y;

static NSString *xCoorrdinate;
static NSString *yCoorrdinate;
static NSString *nameOfAddress;

static NSString * callFrom;


//SearchFunction
static NSString * searchKeyword;

//Reverse Geocode
static NSString * building;
static NSString * address;

//Get Direction
static NSArray * directionCoor;
static double currentX;
static double currentY;
static bool erp;
static NSString * driveDistanceStops;
static NSString * route;
static NSMutableArray * envelope;
static NSMutableArray * directionText;
static NSMutableArray * routeDistance;
static NSMutableArray * routeTime;
static bool swapRouteStatusForDirection;

static NSString * startDirectionX;
static NSString * startDirectionY;
static NSString * startName;
static NSString * endDirectionX;
static NSString * endDirectionY;
static NSString * endName;

//Public Transport
static NSArray * busCorr;
static NSString * mode;
static NSArray * startEndBusCorr;
static NSMutableArray *busBoard;
static NSMutableArray *busAlight;
static NSMutableArray *noOfStop;
static NSMutableArray *routeType;
static NSMutableArray *serviceType;
static NSMutableArray *serviceID;
static NSMutableArray *boardID;
static NSMutableArray *alightID;
static NSMutableArray *transferCoordinate;
static bool swapRouteStatusForPublic;
static NSString * startPublicX;
static NSString * startPublicY;
static NSString * endPublicX;
static NSString * endPublicY;

//Agency Search
static NSMutableArray *agencyName;
static NSMutableArray *agencyTheme;
static NSMutableArray *agencyX;
static NSMutableArray *agencyY;

//MASHUP
static NSMutableArray *mashName;
static NSMutableArray *mashCoordinate;
static NSMutableArray *mashLink;
static NSMutableArray *themeIcon;
static NSString * themeName;
static bool themeSearchStatus;
static bool displayTheme;

//IDENTIFY STATUS
static bool identifyStatus;




//Search Function
+(void)setSearchKeyword:(NSString *) key
{
    searchKeyword=key;
    
}

+(NSString *)getSearchKeyword
{
    return searchKeyword;
}





//--------------------//
//GetToken Get And Set//
//--------------------//
+(void)setToken:(NSString *) tk
{
    token=tk;

}

+(NSString *)getToken
{
    return token;
}


//-------------------------//
//AddressSearch Get And Set//
//-------------------------//
+(void)setName:(NSMutableArray *)searchName
{
    name = searchName;
}

+(NSMutableArray *)getName
{
    return name;
}

+(void)setCategory:(NSMutableArray *)searchCategory
{
    category = searchCategory;
}

+(NSMutableArray *)getCategory
{
    return category;
}

+(void)setX:(NSMutableArray *)searchX
{
    x = searchX;
}

+(NSMutableArray *)getX
{
    return x;
}

+(void)setY:(NSMutableArray *)searchY
{
    y = searchY;
}

+(NSMutableArray *)getY
{
    return y;
}

+(void)setYCoorrdinate:(NSString *)setYCoor
{
    yCoorrdinate = setYCoor;
}

+(NSString *)getYCoor
{
    return yCoorrdinate;
}

+(void)setXCoorrdinate:(NSString *)setXCoor
{
    xCoorrdinate = setXCoor;
}

+(NSString *)getXCoor
{
    return xCoorrdinate;
}

+(void)setNameOfAddress:(NSString *)nameCell
{
    nameOfAddress = nameCell;
}

+(NSString *)getNameOfAddress
{
    return nameOfAddress;
}


+(void)setCallFrom:(NSString *) from
{
    callFrom=from;
    
}


+(NSString *)getCallFrom
{
    return callFrom;
}

+(void)setStartDirectionX:(NSString *) x
{
    startDirectionX=x;
    
}


+(NSString *)getStartDirectionX
{
    return startDirectionX;
}


+(void)setStartDirectionY:(NSString *) y
{
    startDirectionY=y;
    
}


+(NSString *)getStartDirectionY
{
    return startDirectionY;
}


+(void)setEndDirectionX:(NSString *) x
{
    endDirectionX=x;
    
}


+(NSString *)getEndDirectionX
{
    return endDirectionX;
}


+(void)setEndDirectionY:(NSString *) y
{
    endDirectionY=y;
    
}


+(NSString *)getEndDirectionY
{
    return endDirectionY;
}


+(void)setStartName:(NSString *) name
{
    startName=name;
    
}


+(NSString *)getStartName
{
    return startName;
}


+(void)setEndName:(NSString *) name
{
    endName=name;
    
}


+(NSString *)getEndName
{
    return endName;
}
//---------------------------//
//Reverse Geocode Get And Set//
//---------------------------//

+(void)setBuilding:(NSString *)setbuilding
{
    building = setbuilding;
}

+(NSString *)getBuilding
{
    return building;
}

+(void)setAddress:(NSString *)setAddress
{
    address = setAddress;
}

+(NSString *)getAddress
{
    return address;
}


//-------------//
//Get Direction//
//-------------//

+(void)setDirectionCoor:(NSArray *) coor
{
    directionCoor=coor;
    
}

+(NSArray *)getDirectionCoor
{
    return directionCoor;
}

+(void)setCurrentX:(double) coorX
{
    currentX=coorX;
    
}

+(double)getCurrentX
{
    return currentX;
}


+(void)setCurrentY:(double) coorY
{
    currentY=coorY;
    
}

+(double)getCurrentY
{
    return currentY;
}

+(void)setERP:(bool) tempERP
{
    erp=tempERP;
    
}


+(bool)getERP
{
    return erp;
}


+(void)setDriveDistanceStop:(NSString *) distance
{
    driveDistanceStops=distance;
    
}


+(NSString *)getDriveDistanceStop
{
    return driveDistanceStops;
}


+(void)setRoute:(NSString *) tempRoute
{
    route=tempRoute;
    
}

+(NSString *)getRoute
{
    return route;
}

+(void)setEnvelope:(NSMutableArray *) envel
{
    envelope=envel;
    
}

+(NSMutableArray *)getEnvelope
{
    return envelope;
}

+(void)setRouteDirection:(NSMutableArray *) text
{
    directionText=text;
    
}

+(NSMutableArray *)getRouteDirection
{
    return directionText;
}

+(void)setRouteDistance:(NSMutableArray *) distance
{
    routeDistance=distance;
    
}

+(NSMutableArray *)getRouteDistance
{
    return routeDistance;
}

+(void)setRouteTime:(NSMutableArray *) time
{
    routeTime=time;
    
}

+(NSMutableArray *)getRouteTime
{
    return routeTime;
}


+(void)setSwapRouteStatusForDirection:(BOOL) swap
{
    swapRouteStatusForDirection=swap;
    
}

+(BOOL)getSwapRouteStatusForDirection
{
    return swapRouteStatusForDirection;
}


//----------------//
//Public Transport//
//----------------//

+(void)setBusCoor:(NSArray *) coor{
    busCorr = coor;
}

+(NSArray *)getBusCoor{
    return busCorr;
}


+(void)setMode:(NSString *) tempMode
{
    mode=tempMode;
    
}

+(NSString *)getMode
{
    return mode;
}


+(void)setStartEndBusCorr:(NSArray *) coor{
    startEndBusCorr = coor;
}

+(NSArray *)getStartEndBusCorr{
    return startEndBusCorr;
}


+(void)setBusAlight:(NSMutableArray *) alight
{
    busAlight=alight;
    
}

+(NSMutableArray *)getBusAlight
{
    return busAlight;
}

+(void)setBusBoard:(NSMutableArray *) board
{
    busBoard=board;
    
}

+(NSMutableArray *)getBusBoard
{
    return busBoard;
}

+(void)setNoBusStop:(NSMutableArray *) noofstop
{
    noOfStop=noofstop;
    
}

+(NSMutableArray *)getNoBusStop
{
    return noOfStop;
}

+(void)setRouteType:(NSMutableArray *) type
{
    routeType=type;
    
}

+(NSMutableArray *)getRouteType
{
    return routeType;
}

+(void)setServiceType:(NSMutableArray *) type
{
    serviceType=type;
    
}

+(NSMutableArray *)getServiceType
{
    return serviceType;
}


+(void)setServiceID:(NSMutableArray *) serviceid
{
    serviceID=serviceid;
    
}

+(NSMutableArray *)getServiceID
{
    return serviceID;
}

+(void)setBoardID:(NSMutableArray *) boardid
{
    boardID=boardid;
    
}

+(NSMutableArray *)getBoardID
{
    return boardID;
}

+(void)setAlightID:(NSMutableArray *) alightid
{
    alightID=alightid;
    
}

+(NSMutableArray *)getAlightID
{
    return alightID;
}

+(void)setTransferCoordinate:(NSMutableArray *) coor
{
    transferCoordinate=coor;
    
}

+(NSMutableArray *)getTransferCoordinate
{
    return transferCoordinate;
}

+(void)setSwapRouteStatusForPublic:(BOOL) swap
{
    swapRouteStatusForPublic=swap;
    
}

+(BOOL)getSwapRouteStatusForPublic
{
    return swapRouteStatusForPublic;
}

+(void)setStartPublicX:(NSString *) x
{
    startPublicX=x;
    
}


+(NSString *)getStartPublicX
{
    return startPublicX;
}


+(void)setStartPublicY:(NSString *) y
{
    startPublicY=y;
    
}


+(NSString *)getStartPublicY
{
    return startPublicY;
}


+(void)setEndPublicX:(NSString *) x
{
    endPublicX=x;
    
}


+(NSString *)getEndPublicX
{
    return endPublicX;
}


+(void)setEndPublicY:(NSString *) y
{
    endPublicY=y;
    
}


+(NSString *)getEndPublicY
{
    return endPublicY;
}

//-------------//
//Agency Search//
//-------------//
+(void)setAgencyName:(NSMutableArray *)tempname
{
    agencyName = tempname;
}

+(NSMutableArray *)getAgencyName
{
    return agencyName;
}


+(void)setAgencyTheme:(NSMutableArray *)temptheme
{
    agencyTheme = temptheme;
}

+(NSMutableArray *)getAgencyTheme
{
    return agencyTheme;
}


+(void)setAgencyX:(NSMutableArray *)tempx
{
    agencyX = tempx;
}

+(NSMutableArray *)getAgencyX
{
    return agencyX;
}

+(void)setAgencyY:(NSMutableArray *)tempy
{
    agencyY = tempy;
}

+(NSMutableArray *)getAgencyY
{
    return agencyY;
}


//------//
//MASHUP//
//------//

+(void)setMashName:(NSMutableArray *)name
{
    mashName = name;
}

+(NSMutableArray *)getMashName
{
    return mashName;
}

+(void)setMashCoordinate:(NSMutableArray *)coor
{
    mashCoordinate = coor;
}

+(NSMutableArray *)getMashCoordinate
{
    return mashCoordinate;
}



+(void)setMashLink:(NSMutableArray *)link
{
    mashLink = link;
}

+(NSMutableArray *)getMashLink
{
    return mashLink;
}


+(void)setThemeIcon:(NSMutableArray *)icon
{
    themeIcon = icon;
}

+(NSMutableArray *)getThemeIcon
{
    return themeIcon;
}

+(void)setThemeName:(NSString *) theme
{
    themeName=theme;
    
}

+(NSString *)getThemeName
{
    return themeName;
}

+(void)setThemeStatus:(bool) status
{
    themeSearchStatus=status;
    
}


+(bool)getThemeStatus
{
    return themeSearchStatus;
}



+(void)setDisplayTheme:(bool) display
{
    displayTheme=display;
    
}


+(bool)getDisplayTheme
{
    return displayTheme;
}



//---------------//
//IDENTIFY STATUS//
//---------------//

+(void)setIdentifyStatus:(bool) identify
{
    identifyStatus=identify;
    
}


+(bool)getIdentifyStatus
{
    return identifyStatus;
}

@end
