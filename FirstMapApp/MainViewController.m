//
//  MainViewController.m
//  FirstMapApp
//
//  Created by SLA MacBook on 27/11/13.
//  Copyright (c) 2013 Singapore Land Authority. All rights reserved.
//

#import "MainViewController.h"
#import "GetToken.h"
#import "AddressSearch.h"
#import "StaticObjects.h"
#import "ReverseGeocode.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "SearchViewController.h"
#import "Mashup.h"
#import "RouteViewController.h"

@interface MainViewController (){
    
    AGSGraphicsLayer* myGraphicsLayer;
    AGSGraphicsLayer * measureDistanceLayer;
    
}

@end

@implementation MainViewController{
    GetToken *token;
    NSOperationQueue *queue;
    MBProgressHUD *hud;
    ReverseGeocode *rev;
    int themeCounter;
    int distanceCounter;
    int areaCounter;
    NSMutableArray *themeArray;
    AGSPolygon *polygon;
    BOOL routeFrom;
    BOOL calculateDistanceStatus;
    BOOL calculateAreaStatus;
    NSMutableArray * distancePoint;
    NSMutableArray *distanceArray;
    double totalDistance;
    double totalArea;
    double rotation;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //FOR SLIDE Menu
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    
    //ALLOCATE MEMORY
    themeArray = [[NSMutableArray alloc]init];
    polygon = [[AGSPolygon alloc]init];
    distancePoint = [[NSMutableArray alloc]init];
    distanceArray = [[NSMutableArray alloc]init];
    
    //SET DEFAULT ROTATION OF MAP = 0
    rotation = 0;
    
    //SET DEFAULT INDENTIFY NO
    [StaticObjects setIdentifyStatus:NO];
    
    //SET DEFAULT = NO
    calculateDistanceStatus = NO;
    calculateAreaStatus = NO;
    
    //CALCULATE DISTANCE/AREA DEFAULT = 0
    totalDistance =0;
    totalArea =0;
    
    //RESET COUNTER =0;
    themeCounter = 0;
    distanceCounter = 0;
    areaCounter =0;
    
    //LOADING VIEW
    [self loading];

    //SET DELEGATE
    self.mapView.layerDelegate =self;
    [[self.mapView callout]setDelegate:self];
    self.mapView.touchDelegate = self;
    
    

    //DISPLAY MAP
    NSURL* url = [NSURL URLWithString:@"http://e1.onemap.sg/arcgis/rest/services/SM128/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [tiledLayer fullEnvelope];
    [tiledLayer setRenderNativeResolution:YES];

    //ADD MAPLAYER WITH NAME REFERENCE
    [self.mapView addMapLayer:tiledLayer withName:@"OneMap Tiled Layer"];

    //ALLOC MEMORY
    queue = [[NSOperationQueue alloc]init];
    token =[[GetToken alloc]init];
    
    //RUN GETTOKEN API IN QUEUE
    [queue addOperation:token];
    
    //SET NOTIFICATION TO LISTEN
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeToLocation"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveLoc:) name:@"removeToLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLoading:) name:@"stopLoadingMain" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayCallout:) name:@"displayCallout" object:rev];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushToAddressSearch:) name:@"pushToAddressSearch" object:rev];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushToGetDirection:) name:@"pushToGetDirection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeSearch:) name:@"themeSearch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calculateDistance:) name:@"calculateDistance" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calculateArea:) name:@"calculateArea" object:nil];
    
    
    //SET 2 FINGER ROTATION GESTURE (CURRENTLY NOT IN USE)
    UIRotationGestureRecognizer *twoFingersRotate =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingersRotate:)];
    [[self view] addGestureRecognizer:twoFingersRotate];
    
       }





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






//-----------------------------------//
//METHOD WILL RUN IF MAPVIEW DID LOAD//
//-----------------------------------//
- (void) mapViewDidLoad:(AGSMapView*)mapView {
    
    //Max Zoom
   // [self.mapView setMaxEnvelope:[AGSEnvelope envelopeWithXmin:5000 ymin:26000 xmax:53000 ymax:59000 spatialReference:self.mapView.spatialReference]];
    
    //SHOW AND MOVE TO CURRENT LOCATION
    [self.mapView.locationDisplay startDataSource];
     self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
 
    
    //RenderMap View
    [self.mapView setBackgroundColor:[UIColor colorWithRed:0.699309 green:0.793383 blue:0.93478 alpha:1.0]];
    [self.mapView setGridLineWidth:0];
    [self.mapView setGridSize:0];
    
    
    //HIDE LOADING INDICATOR
    [hud hide:YES];
    
    
    //START UPDATING GPS CORRDINATE
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];

    
    //GRAPHIC LAYER FOR MEASURE DISTANCE
    measureDistanceLayer = [AGSGraphicsLayer graphicsLayer];
    //ADD GRAPHICLAYER TO MAPVIEW WITH NAME FOR EASY REMOVING
    [self.mapView addMapLayer:measureDistanceLayer withName:@"calDistance"];
    

    
    }






//----------------------------------//
//GET CURRENT CORRDINATE THROUGH GPS//
//----------------------------------//
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        //NSLog(@"Latitude: %f, Longitude: %f", location.coordinate.latitude, location.coordinate.longitude);
        AGSPoint* gpsPoint = [[AGSPoint alloc] initWithX:location.coordinate.longitude
                                                       y:location.coordinate.latitude
                                        spatialReference:[AGSSpatialReference wgs84SpatialReference]];
        
        AGSGeometryEngine* engine = [AGSGeometryEngine defaultGeometryEngine];
        
        // convert GPS WGS-84 coordinates to the map's spatial reference
        // (assuming self.mapView is your AGSMapView for your map)
        AGSPoint* mapPoint = (AGSPoint*) [engine projectGeometry:gpsPoint
                                              toSpatialReference:self.mapView.spatialReference];
        
        //get x and y coordinate from AGSPoint
        [StaticObjects setCurrentX:mapPoint.x];
        [StaticObjects setCurrentY:mapPoint.y];
        
        NSLog(@"UPDATE COORDINATE");

    }
}





//----------------------------------------//
//UNWIND METHOD FROM BACK (ADDRESS SEARCH)//
//----------------------------------------//
- (IBAction)unwindToMain:(UIStoryboardSegue *)segue
{
    
    [StaticObjects setName:nil];
    NSLog(@"Back from address");

}





//----------------------//
//UNWIND AFTER SEARCHING//
//----------------------//
- (IBAction)unwindToMainAfterSearch:(UIStoryboardSegue *)segue1
{
    //SET LOADING SCREEN
    [self loading];
    
    [StaticObjects setName:nil];
    
    //Hide Route Label
    [self hide];
    
    NSLog(@"After Search");
    
}





//-----------------------//
//UNWIND FROM THEMESEARCH//
//-----------------------//
- (IBAction)unwindToMainForThemeSearch:(UIStoryboardSegue *)segue
{
    //HIDE ROUTE LABEL IF ANY
    [self hide];
    
    //REMOVE GRAPHIC LAYERS
    [self.mapView removeMapLayerWithName:@"PolygonTheme"];
    [self.mapView removeMapLayerWithName:@"CustomThemeResult"];
    [self.mapView removeMapLayerWithName:@"AllThemeResult"];
    
    //FOR CUSTOM THEMESEARCH
    if ([StaticObjects getDisplayTheme] == NO) {
    
        [self performSelector:@selector(showWithMessage:) withObject:@"Select 4 locations on the map to create a rectangular area. The theme will appear within the selected area. "];
        
    }
    //FOR ALL THEMESEARCH
    else if ([StaticObjects getDisplayTheme] == YES){
        
        //START LOADING INDICATOR
        [self loading];
        
        //CALL MASHUP API TO GET ALL THEME SELECTED BY USERS
        Mashup *mash = [[Mashup alloc]init];
        [queue addOperation:mash];
        
    }
    
        
    NSLog(@"Back segue from theme search");
}





//--------------------------------//
//UNWIND FROM BACK (GET DIRECTION)//
//--------------------------------//
- (IBAction)unwindToMainForDirection:(UIStoryboardSegue *)segue
{

    NSLog(@"Back segue from direction");
}




//-----------------------------------//
//UNWIND FROM DONE (Public Transport)//
//-----------------------------------//
- (IBAction)unwindToMainForPublicTransportDoneBtn:(UIStoryboardSegue *)segue
{
    
    //REMOVE RED PIN ICON
    [self.mapView removeMapLayerWithName:@"RoutePin"];
    [self.mapView removeMapLayerWithName:@"PinIcon"];
    
    //DISPLAY BLACK SLIDE ICON
    [self performSelector:@selector(showWithMessageForDirection:) withObject:[StaticObjects getEndName]];

    //YES indicate from get direction view
    routeFrom = NO;
    
    //REMOVE MAP LAYER WITH POLYLINE
    [self.mapView removeMapLayerWithName:@"PolyLine"];
    [self.mapView removeMapLayerWithName:@"PolyLinePublic"];
    [self.mapView removeMapLayerWithName:@"PublicPin"];
    
    double xmin;
    double xmax;
    double ymin;
    double ymax;

    //CHECK WHICH COORDINATE IS GREATER
    if([[[StaticObjects getStartEndBusCorr] objectAtIndex:0] doubleValue] < [[[StaticObjects getStartEndBusCorr] objectAtIndex:2] doubleValue]){
       
         xmin = [[[StaticObjects getStartEndBusCorr] objectAtIndex:0] doubleValue];
         xmax = [[[StaticObjects getStartEndBusCorr] objectAtIndex:2] doubleValue];
    }
    else{
         xmin = [[[StaticObjects getStartEndBusCorr] objectAtIndex:2] doubleValue];
         xmax = [[[StaticObjects getStartEndBusCorr] objectAtIndex:0] doubleValue];
    }
    
    if([[[StaticObjects getStartEndBusCorr] objectAtIndex:1] doubleValue] < [[[StaticObjects getStartEndBusCorr] objectAtIndex:3] doubleValue]){
        
         ymin = [[[StaticObjects getStartEndBusCorr] objectAtIndex:1] doubleValue];
         ymax = [[[StaticObjects getStartEndBusCorr] objectAtIndex:3] doubleValue];
    }
    else{
         ymin = [[[StaticObjects getStartEndBusCorr] objectAtIndex:3] doubleValue];
         ymax = [[[StaticObjects getStartEndBusCorr] objectAtIndex:1] doubleValue];
    }
    
    //ENVELOPE INTO MAP BASE ON COORDINATE
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:(xmin - 1000.0)
                                                     ymin:ymin
                                                     xmax:(xmax + 1000.0)
                                                     ymax:ymax
                                         spatialReference:self.mapView.spatialReference];
    
    //MAP ZOOM ANIMATED AND SHOW LOCATION
    [self.mapView zoomToEnvelope:envelope animated:YES];
    
    //HIDE CALLOUT
    self.mapView.callout.hidden = YES;
    
    
    
    //CALL METHOD
    [self getPublicTransportPolyLine];
}





//-------------------------------//
//UNWIND FROM DONE (GET DIRECTON)//
//-------------------------------//
- (IBAction)unwindToMainForDirectionDoneBtn:(UIStoryboardSegue *)segue
{
    
    //DISPLAY BLACK SLIDE ICON
    [self performSelector:@selector(showWithMessageForDirection:) withObject:[StaticObjects getEndName]];
    
    //NO = NO SWAP ROUTE DIRECTION
    if ([StaticObjects getSwapRouteStatusForDirection] == NO) {
        
        //REMOVE RED PIN ICON
        [self.mapView removeMapLayerWithName:@"RoutePin"];
        [self.mapView removeMapLayerWithName:@"PinIcon"];
        
        //ADD IN RED PIN ICON
        myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:myGraphicsLayer withName:@"RoutePin"];
        
        //RED PIN FOR DESTINATION
        AGSPictureMarkerSymbol *myMarkerSymbolDestination = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"locationPin.png"];
        myMarkerSymbolDestination.size=CGSizeMake(51, 68);
        [myMarkerSymbolDestination setOffset:CGPointMake(5, 30)];
        AGSPoint* myMarkerPointDestination =
        [AGSPoint pointWithX:[[StaticObjects getEndDirectionX] doubleValue]
                           y:[[StaticObjects getEndDirectionY] doubleValue]
            spatialReference:self.mapView.spatialReference];
        AGSGraphic* myGraphicEnd =
        [AGSGraphic graphicWithGeometry:myMarkerPointDestination
                                 symbol:myMarkerSymbolDestination
                             attributes:nil];
        
        //GREEN PIN FOR DESTINATION
        AGSPictureMarkerSymbol *myMarkerSymbolStart = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"startingLocationPin.png"];
        myMarkerSymbolStart.size=CGSizeMake(51, 68);
        [myMarkerSymbolStart setOffset:CGPointMake(5, 30)];
        AGSPoint* myMarkerPointStart =
        [AGSPoint pointWithX:[[StaticObjects getStartDirectionX] doubleValue]
                           y:[[StaticObjects getStartDirectionY] doubleValue]
            spatialReference:self.mapView.spatialReference];
        AGSGraphic* myGraphicStart =
        [AGSGraphic graphicWithGeometry:myMarkerPointStart
                                 symbol:myMarkerSymbolStart
                             attributes:nil];
        
        NSArray *graphicArray = @[myGraphicEnd, myGraphicStart];

        
        //Add the graphic to the Graphics layer
        [myGraphicsLayer addGraphics:graphicArray];
        
    }
    
    //USER DID SWAP DIRECTION FOR GET DIRECTION
    else{
        
        //REMOVE RED PIN ICON
        [self.mapView removeMapLayerWithName:@"RoutePin"];
        [self.mapView removeMapLayerWithName:@"PinIcon"];

        //ADD IN RED PIN ICON ON PREVIOUS RED PIN LOCATION
        myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        [self.mapView addMapLayer:myGraphicsLayer withName:@"RoutePin"];
        
        //RED PIN FOR DESTINATION
        AGSPictureMarkerSymbol *myMarkerSymbolDestination = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"locationPin.png"];
        myMarkerSymbolDestination.size=CGSizeMake(51, 68);
        [myMarkerSymbolDestination setOffset:CGPointMake(5, 30)];
        AGSPoint* myMarkerPointDestination =
        [AGSPoint pointWithX:[[StaticObjects getStartDirectionX] doubleValue]
                           y:[[StaticObjects getStartDirectionY] doubleValue]
            spatialReference:self.mapView.spatialReference];
        AGSGraphic* myGraphicEnd =
        [AGSGraphic graphicWithGeometry:myMarkerPointDestination
                                 symbol:myMarkerSymbolDestination
                             attributes:nil];
        
        //GREEN PIN FOR DESTINATION
        AGSPictureMarkerSymbol *myMarkerSymbolStart = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"startingLocationPin.png"];
        myMarkerSymbolStart.size=CGSizeMake(51, 68);
        [myMarkerSymbolStart setOffset:CGPointMake(5, 30)];
        AGSPoint* myMarkerPointStart =
        [AGSPoint pointWithX:[[StaticObjects getEndDirectionX] doubleValue]
                           y:[[StaticObjects getEndDirectionY] doubleValue]
            spatialReference:self.mapView.spatialReference];
        AGSGraphic* myGraphicStart =
        [AGSGraphic graphicWithGeometry:myMarkerPointStart
                                 symbol:myMarkerSymbolStart
                             attributes:nil];
        
        
        NSArray *graphicArray = @[myGraphicEnd, myGraphicStart];

        
        //Add the graphic to the Graphics layer
        [myGraphicsLayer addGraphics:graphicArray];


    }
        
    //YES indicate from get direction view
    routeFrom = YES;
    
    //REMOVE MAP LAYER WITH POLYLINE
    [self.mapView removeMapLayerWithName:@"PolyLine"];
    [self.mapView removeMapLayerWithName:@"PolyLinePublic"];
    [self.mapView removeMapLayerWithName:@"PublicPin"];
    
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:([[[StaticObjects getEnvelope] objectAtIndex:1] doubleValue] - 500.0)
                                                     ymin:[[[StaticObjects getEnvelope] objectAtIndex:3] doubleValue]

                                                     xmax:([[[StaticObjects getEnvelope] objectAtIndex:0] doubleValue] + 500.0)

                                                     ymax:[[[StaticObjects getEnvelope] objectAtIndex:2] doubleValue]
                                         spatialReference:self.mapView.spatialReference];
    
    //MAP ZOOM ANIMATED AND SHOW LOCATION
    [self.mapView zoomToEnvelope:envelope animated:YES];
    
    //HIDE CALLOUT
    self.mapView.callout.hidden = YES;
    
    //CALL METHOD
    [self getDirectionPolyLine];
}






//--------------------------------------------------//
//PUSH MAIN VIEW TO GET DIRECTION VIEW FOR SIDE MENU//
//--------------------------------------------------//
-(void)pushToGetDirection:(NSNotification *)notification{

    //PERFORM SEGUE TO GET DIRECTION VIEW
    [self performSegueWithIdentifier:@"getdirection.segue" sender:self];

}





//---------------------------------------------------//
//PUSH MAIN VIEW TO ADDRESS SEARCH VIEW FOR SIDE MENU//
//---------------------------------------------------//
-(void)pushToAddressSearch:(NSNotification *)notification{
    
    //GET STRING THAT IS PASS THROUGH NOTIFICATION
    NSString *sender = [notification object];
    
    //PUSH TO ADDRESS SEARCH VIEW
    if([sender isEqualToString:@"addressSegue"]){

    [self performSegueWithIdentifier: @"pushAddressSearch" sender: self];

    }
    
    //PUSH TO THEME SEARCH VIEW
    else  if([sender isEqualToString:@"themeSegue"]){

        [self performSegueWithIdentifier: @"pushThemeSearch" sender: self];

    }

}






//--------------------------------//
//DISPLAY LOCATION AFTER SEARCHING//
//--------------------------------//
- (void) searchLocaton:(NSString *)senderIdentifierStr{
    
    NSLog(@"senderIdentifierStr - %@",senderIdentifierStr);
    
    myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    
    //CHECK FOR NULL
    if([StaticObjects getXCoor] !=nil && [StaticObjects getYCoor] !=nil){
    
    //ENVELOPE INTO LOCATION ON MAP
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:[[StaticObjects getXCoor] doubleValue] - 100.0
                                                     ymin:[[StaticObjects getYCoor] doubleValue]
                                                     xmax:[[StaticObjects getXCoor] doubleValue] + 100.0
                                                     ymax:[[StaticObjects getYCoor] doubleValue]
                                         spatialReference:self.mapView.spatialReference];
    
    //MAP ZOOM ANIMATED AND SHOW LOCATION
    [self.mapView zoomToEnvelope:envelope animated:YES];
    
    //ADD GRAPHICSLAYER INTO MAY LAYER
    [self.mapView addMapLayer:myGraphicsLayer withName:@"PinIcon"];
    
    //CREATE MARKER (LOCATION POINTER) TO BE PLACE IN GRAPHIC LAYER
    AGSPictureMarkerSymbol *myMarkerSymbol = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"userPin.png"];
    
    //SET SIZE OF IMAGE
    myMarkerSymbol.size=CGSizeMake(51, 51);
        
    //SET OFFSET OF MARKER IMAGE SO THAT IT POINT LOWER INTO THE MAP
    [myMarkerSymbol setOffset:CGPointMake(5, 30)];

    //Create an AGSPoint defines where the Graphic will be drawn
    AGSPoint* myMarkerPoint =
	[AGSPoint pointWithX:[[StaticObjects getXCoor] doubleValue]
                       y:[[StaticObjects getYCoor] doubleValue]
		spatialReference:self.mapView.spatialReference];
    
    //Create the Graphic using the symbol and geometry created earlier
        AGSGraphic* myGraphic =
	[AGSGraphic graphicWithGeometry:myMarkerPoint
                             symbol:myMarkerSymbol
                         attributes:nil];
        
    //Add the graphic to the Graphics layer
   [myGraphicsLayer addGraphic:myGraphic];
    
         }
    
    if ([senderIdentifierStr isEqualToString:@"fromSearch"]) {
        
        //Create an AGSPoint for callout (add +33 so that callout display on top on image)
        AGSPoint* callOutPoint =
        [AGSPoint pointWithX:[[StaticObjects getXCoor] doubleValue]
                       y:[[StaticObjects getYCoor] doubleValue]+33
		spatialReference:self.mapView.spatialReference];
    
    
        //DISPLAY CALLOUT
        if ([[StaticObjects getAddress] isEqualToString:@"BLK (null) (null) (null)"])
        {
            [self.mapView.callout showCalloutAt:callOutPoint screenOffset:CGPointZero animated:YES];
            self.mapView.callout.title = @"Address";
            self.mapView.callout.detail = [StaticObjects getNameOfAddress];
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.autoAdjustWidth = YES;
        
        }
        else {
        
            [self.mapView.callout showCalloutAt:callOutPoint screenOffset:CGPointZero animated:YES];
            self.mapView.callout.title = [StaticObjects getBuilding];
            self.mapView.callout.detail = [StaticObjects getAddress];
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.autoAdjustWidth = YES;

        }
    }
    
    //HIDE LOADING
    [hud hide:YES];
    
}





//-------------------------------------//
//DRAW LINE ON MAP FOR PUBLIC TRANSPORT//
//-------------------------------------//
-(void)getPublicTransportPolyLine{
    
  
    myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];

    
    //REPLACE SOME CHAR IN STRING WITH ANOTHER CHAR
    NSString * newString = [[NSString stringWithFormat:@"%@",[StaticObjects getBusCoor]] stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    NSString * newString2 = [newString stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    NSString * newString3 = [newString2 stringByReplacingOccurrencesOfString:@"," withString:@"\",\""];
    NSString * newString4 = [newString3 stringByReplacingOccurrencesOfString:@";" withString:@"\"],[\""];
  
    //STRING FOR NSDICTIONARY
    NSString* str = [NSString stringWithFormat:@"\{ \"paths\" : [[%@]],\"spatialReference\" : {\"wkid\" : 4325}}",newString4];
    
    //ASSIGN INTO NSDATA AND THEN INTO NSDICTIONARY
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *coor =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    //ADD GRAPHICLAYER INTO MAP LAYER
    [self.mapView addMapLayer:myGraphicsLayer withName:@"PolyLinePublic"];
    
    //graphicWithGeometry
    AGSPolyline * poly= [AGSPolyline polylineWithJSON:coor];
    
    //Create the Graphic using the symbol and geometry created earlier
    AGSGraphic* directionGraphic =
	[AGSGraphic graphicWithGeometry:poly
                             symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:1.0f] width:4 ]
                         attributes:nil];

    //ADD GRAPHIC TO GRAPHICLAYER
    [myGraphicsLayer addGraphic:directionGraphic];

    

    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    tempArray =[[StaticObjects getTransferCoordinate] objectAtIndex:0];
    
    //CHECK IF TRANSFER COORINATE (BOARD) HAS MORE THAN 1 COORDINATE
    if ([tempArray count] >1) {

        //PLOT COORDINATE FOR BOARD BUS/MRT (TRANSFER)
        for (int i=1; i < [tempArray count]; i++) {

            
            //Create an AGSPoint that defines where the Graphic will be drawn
            AGSPoint* transferMarker =
            [AGSPoint pointWithX:[[[[StaticObjects getTransferCoordinate] objectAtIndex:0] objectAtIndex:i] doubleValue]
                           y:[[[[StaticObjects getTransferCoordinate] objectAtIndex:1] objectAtIndex:i] doubleValue]
                            spatialReference:self.mapView.spatialReference];
        
            //Create the Graphic using the symbol and geometry created earlier
            AGSGraphic *transferGraphic =
            [AGSGraphic graphicWithGeometry:transferMarker
                                 symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithRed:253/255.0f green:254/255.0f blue:253/255.0f alpha:1.0f]]
                                 attributes:nil];
            //ADD GRAPHIC TO GRAPHICLAYER
            [myGraphicsLayer addGraphic:transferGraphic];

        }
    }
    
    
    
    NSMutableArray *tempArray2 = [[NSMutableArray alloc]init];
    tempArray2 =[[StaticObjects getTransferCoordinate] objectAtIndex:2];
    
    //CHECK IF TRANSFER COORINATE (ALIGHT) HAS MORE THAN 1 COORDINATE
    if ([tempArray2 count] >1) {

        //PLOT COORDINATE FOR ALIGHT BUS/MRT (TRANSFER)
        for (int i=0; i < [tempArray2 count] -1; i++) {

            //Create an AGSPoint that defines where the Graphic will be drawn
            AGSPoint* transferMarker =
            [AGSPoint pointWithX:[[[[StaticObjects getTransferCoordinate] objectAtIndex:2] objectAtIndex:i] doubleValue]
                               y:[[[[StaticObjects getTransferCoordinate] objectAtIndex:3] objectAtIndex:i] doubleValue]
                spatialReference:self.mapView.spatialReference];
            
            //Create the Graphic using the symbol and geometry created earlier
            AGSGraphic *transferGraphic =
            [AGSGraphic graphicWithGeometry:transferMarker
                                     symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithRed:253/255.0f green:254/255.0f blue:253/255.0f alpha:1.0f]]
                                 attributes:nil];

            //ADD GRAPHIC TO GRAPHICLAYER
            [myGraphicsLayer addGraphic:transferGraphic];
            
        }
        
    }
    
    //-----------------------------//
    //ADD IN GREEN AND RED BUS ICON//
    //-----------------------------//
    
    AGSGraphicsLayer * myGraphicsLayer2 = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:myGraphicsLayer2 withName:@"PublicPin"];
    
    //CREATE MARKER (LOCATION POINTER) TO BE PLACE IN GRAPHIC LAYER
    AGSPictureMarkerSymbol *busStartSymbol = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"busStart.png"];
    
    //SET SIZE OF IMAGE
    busStartSymbol.size=CGSizeMake(31, 31);
    
    //Create an AGSPoint that defines where the Graphic will be drawn
    AGSPoint* busStartMarker =
	[AGSPoint pointWithX:[[[[StaticObjects getTransferCoordinate] objectAtIndex:0] objectAtIndex:0] doubleValue]
                       y:[[[[StaticObjects getTransferCoordinate] objectAtIndex:1] objectAtIndex:0] doubleValue]
		spatialReference:self.mapView.spatialReference];
    
    //Create the Graphic, using the symbol and geometry created earlier
    AGSGraphic *busStartGraphic =
	[AGSGraphic graphicWithGeometry:busStartMarker
                             symbol:busStartSymbol
                         attributes:nil];
    
    
    //CREATE MARKER (LOCATION POINTER) TO BE PLACE IN GRAPHIC LAYER
    AGSPictureMarkerSymbol *busStopSymbol = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"busStop.png"];
    
    //SET SIZE OF IMAGE
    busStopSymbol.size=CGSizeMake(31, 31);
    
    NSMutableArray *tempArray3 = [[NSMutableArray alloc]init];
    tempArray3 =[[StaticObjects getTransferCoordinate] objectAtIndex:2];
    int count = [tempArray3 count];
    
    //Create an AGSPoint that defines where the Graphic will be drawn
    AGSPoint* busStopMarker =
	[AGSPoint pointWithX:[[[[StaticObjects getTransferCoordinate] objectAtIndex:2] objectAtIndex:(count -1)] doubleValue]
                       y:[[[[StaticObjects getTransferCoordinate] objectAtIndex:3] objectAtIndex:(count -1)] doubleValue]
		spatialReference:self.mapView.spatialReference];
    
    //Create the Graphic using the symbol and geometry created earlier
    AGSGraphic *busStopGraphic =
	[AGSGraphic graphicWithGeometry:busStopMarker
                             symbol:busStopSymbol
                         attributes:nil];
    
    //CREATE NSARRAY AND STORE ALL GRAPHIC INTO IT
    NSArray *graphicArray = @[busStartGraphic, busStopGraphic];
    
    
    
    //ADD GRAPHIC TO GRAPHICLAYER
    [myGraphicsLayer2 addGraphics:graphicArray];
    
    
}






//---------------------------------//
//DRAW LINE ON MAP FOR GETDIRECTION//
//---------------------------------//
-(void)getDirectionPolyLine{
    
    myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];

    //STRING FOR NSDICTIONARY
    NSString* str = [NSString stringWithFormat:@"\{ \"paths\" : [%@],\"spatialReference\" : {\"wkid\" : 4326}}",[StaticObjects getDirectionCoor]];
    
    //REPLACE "()" WITH "[]"
    NSString * newString = [str stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    NSString * newString2 = [newString stringByReplacingOccurrencesOfString:@")" withString:@"]"];

    
    //ASSIGN INTO NSDATA AND THEN INTO NSDICTIONARY
    NSData* data = [newString2 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *coor =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    //ADD GRAPHICLAYER TO MAP LAYER
    [self.mapView addMapLayer:myGraphicsLayer withName:@"PolyLine"];
    
    AGSPolyline * poly= [AGSPolyline polylineWithJSON:coor];
    
    //Create the Graphic using the symbol and geometry created earlier
    AGSGraphic* directionGraphic =
	[AGSGraphic graphicWithGeometry:poly
                             symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:1.0f] width:4 ]
                         attributes:nil];
    
    //Add the graphic to the Graphics layer
    [myGraphicsLayer addGraphic:directionGraphic];
    
}






//----------------------------------------------//
//CALCULATE DISTANCE METHOD FOR MEASURE DISTANCE//
//----------------------------------------------//
-(void)calculateDistance:(NSNotification *)notification{
    
    //SET TO CAL DISTANCE MODE
    calculateDistanceStatus = YES;
    
    //REMOVE UNWANTED GRAPHIC FROM PREVIOUS
    [self.mapView removeMapLayerWithName:@"PolygonTheme"];
    [self.mapView removeMapLayerWithName:@"CustomThemeResult"];
    [self.mapView removeMapLayerWithName:@"AllThemeResult"];
    
    //DISPLAY MESSAGE
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Calculate Length" message:@"Choose Locations On Map To Calculate Length" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    
    //DISPLAY BLACK SLIDE ICON MESSAGE
    [self performSelector:@selector(showWithMessageForCalculateDistance:) withObject:[NSString stringWithFormat:@"Total Length: %0.2f Metres",totalDistance]];
    

    
}





//--------------------------------------//
//CALCULATE AREA METHOD FOR MEASURE AREA//
//--------------------------------------//
-(void)calculateArea:(NSNotification *)notification{
    
    //SET TO CAL DISTANCE MODE
    calculateAreaStatus = YES;
    
    //REMOVE UNWANTED GRAPHIC FROM PREVIOUS
    [self.mapView removeMapLayerWithName:@"PolygonTheme"];
    [self.mapView removeMapLayerWithName:@"CustomThemeResult"];
    [self.mapView removeMapLayerWithName:@"AllThemeResult"];
    
    //DISPLAY MESSAGE
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Calculate Area" message:@"Choose Locations On Map To Calculate Area" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    
    
    //DISPLAY BLACK SLIDE ICON MESSAGE
    [self performSelector:@selector(showWithMessageForCalculateDistance:) withObject:[NSString stringWithFormat:@"Total Area: %0.2f m²",totalArea]];
    
    
    
}




//------------------------------------------------------------------//
//RECEIVE NOTIFICATION OF WHEN TO DISPLAY SEARCH LOCATION ON THE MAP//
//------------------------------------------------------------------//
-(void)moveLoc:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"removeToLocation"])
    {
        //REMOVE GRAPHIC
        [self.mapView removeMapLayerWithName:@"PinIcon"];
        [self.mapView removeMapLayerWithName:@"PolyLine"];
        [self.mapView removeMapLayerWithName:@"RoutePin"];
        [self.mapView removeMapLayerWithName:@"PolyLinePublic"];
        [self.mapView removeMapLayerWithName:@"PublicPin"];
        [self.mapView removeMapLayerWithName:@"PolygonTheme"];
        [self.mapView removeMapLayerWithName:@"CustomThemeResult"];
        
        //CALL searchLocation method
        [self performSelector:@selector(searchLocaton:) withObject:@"fromSearch"];
        
        
    }
}






//-------------------------------------------//
//DISPLAY CALLOUT WHEN TOUCH MAP/LOCATION PIN//
//-------------------------------------------//
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features{
    
    //CHECK IF USER IS TRYING TO CALCULATE AREA
    if (calculateAreaStatus == YES) {
        
        //REMOVE PREVIOUS GRAPHICLAYER IF ANY
        [self.mapView removeMapLayerWithName:@"calArea"];
        
        myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        
        //ADD GRAPHICLAYER TO MAPVIEW WITH NAME FOR EASY REMOVING
        [self.mapView addMapLayer:myGraphicsLayer withName:@"calArea"];
        

        
        NSString *tempString = [NSString stringWithFormat:@"[%f,%f]",[mappoint x],[mappoint y]];
        
        //ADD COORDINATE SELECTED INTO ARRAY
        [themeArray addObject:tempString];
        
        //FORMAT STRING INTO REQUIRED FORMAT (JSON)
        NSString *tempString2 = [NSString stringWithFormat:@"%@",themeArray];
        NSString * newString1 = [tempString2 stringByReplacingOccurrencesOfString:@")" withString:@"]"];
        NSString * newString2 = [newString1 stringByReplacingOccurrencesOfString:@"(" withString:@"["];
        NSString * newString3 = [newString2 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString* polygonString = [NSString stringWithFormat:@"\{ \"rings\" : [%@],\"spatialReference\" : {\"wkid\" : 4320}}",newString3];
        
        //ASSIGN INTO NSDATA AND THEN INTO NSDICTIONARY
        NSData* data = [polygonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *coor =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        polygon = [AGSPolygon polygonWithJSON:coor];
        
        
        //COMPOSITE SYMBOL
        AGSCompositeSymbol* composite = [AGSCompositeSymbol compositeSymbol];
        
        //POINT DESIGN
        AGSSimpleMarkerSymbol* markerSymbol = [[AGSSimpleMarkerSymbol alloc] init];
        markerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
        markerSymbol.color = [UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:1];
        [composite addSymbol:markerSymbol];
        
        //LINE DESIGN
        AGSSimpleLineSymbol* lineSymbol = [[AGSSimpleLineSymbol alloc] init];
        lineSymbol.color= [UIColor grayColor];
        lineSymbol.width = 4;
        [composite addSymbol:lineSymbol];
        
        //FILL DESIGN
        AGSSimpleFillSymbol* fillSymbol = [[AGSSimpleFillSymbol alloc] init];
        fillSymbol.color = [UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:0.2];
        [composite addSymbol:fillSymbol];
        
        //CREATE GRAPHIC
        AGSGraphic* myGraphic =
        [AGSGraphic graphicWithGeometry:polygon
                                 symbol:composite
                             attributes:nil];
        
        //ADD GRAPHIC TO GRAPHICLAYER
        [myGraphicsLayer addGraphic:myGraphic];
        
        areaCounter++;
        
        if (areaCounter>2) {
            
            AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
            totalArea = [geometryEngine areaOfGeometry:polygon];
            
            [self performSelector:@selector(showWithMessageForCalculateDistance:) withObject:[NSString stringWithFormat:@"Total Area: %0.2f m²",totalArea]];
        }

        
    }

    //CHECK IF USER IS TRYING TO CALCULATE DISTANCE
    else if (calculateDistanceStatus == YES) {
        
        
        //-------//
        //PLOYGON//
        //-------//
        NSString *tempString = [NSString stringWithFormat:@"[%f,%f]",[mappoint x],[mappoint y]];
        
        //ADD COORDINATE SELECTED INTO ARRAY
        [distanceArray addObject:tempString];
        [distancePoint addObject:mappoint];
        distanceCounter++;

        //FORMAT STRING INTO REQUIRED FORMAT (JSON)
        NSString *tempString2 = [NSString stringWithFormat:@"%@",distanceArray];
        NSString * newString1 = [tempString2 stringByReplacingOccurrencesOfString:@")" withString:@"]"];
        NSString * newString2 = [newString1 stringByReplacingOccurrencesOfString:@"(" withString:@"["];
        NSString * newString3 = [newString2 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString* polygonString = [NSString stringWithFormat:@"\{ \"paths\" : [%@],\"spatialReference\" : {\"wkid\" : 4320}}",newString3];
        
        //ASSIGN INTO NSDATA AND THEN INTO NSDICTIONARY
        NSData* data = [polygonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *coor =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        AGSPolyline *polyline = [AGSPolyline polylineWithJSON:coor];
        
        if(distanceCounter>1){
        
            //CALCULATE DISTANCE HERE
            AGSPoint *calPoint = [distancePoint objectAtIndex:distanceCounter -2];
            totalDistance += [calPoint distanceToPoint:[distancePoint objectAtIndex:distanceCounter -1]];
            
            [self performSelector:@selector(showWithMessageForCalculateDistance:) withObject:[NSString stringWithFormat:@"Total Length: %0.2f Metres",totalDistance]];
        
            
        
        }
        
        
        //COMPOSITE SYMBOL
        AGSCompositeSymbol* composite = [AGSCompositeSymbol compositeSymbol];
        
        //POINT DESIGN
        AGSSimpleMarkerSymbol* markerSymbol = [[AGSSimpleMarkerSymbol alloc] init];
        markerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
        markerSymbol.color = [UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:1];
        [composite addSymbol:markerSymbol];
        
        //LINE DESIGN
        AGSSimpleLineSymbol* lineSymbol = [[AGSSimpleLineSymbol alloc] init];
        lineSymbol.color= [UIColor grayColor];
        lineSymbol.width = 4;
        [composite addSymbol:lineSymbol];
        
        //CREATE GRAPHIC
        AGSGraphic* myGraphic =
        [AGSGraphic graphicWithGeometry:polyline
                                 symbol:composite
                             attributes:nil];
        //ADD GRAPHIC TO GRAPHICLAYER
        [measureDistanceLayer addGraphic:myGraphic];
        
    }
    
    //IF YES = ALLOW USER TO CHOOSE 4 LOCATION ON MAP FOR CUSTOM THEME SEARCH
    else if([StaticObjects getThemeStatus] == YES){

        //REMOVE PREVIOUS GRAPHICLAYER IF ANY
        [self.mapView removeMapLayerWithName:@"PolygonTheme"];
        
        myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        
        //IF 4 = NOT USER FIRST TIME DOING THEME SEARCH
        if (themeCounter ==4) {
            
            //RESET COUNTER TO INDICATE POINT CHOSEN ON MAP (MAX 4)
            themeCounter =0;

            //REMOVE PREVIOUS GRAPHIC ADDED IN GRAPHICLAYER
            [myGraphicsLayer removeAllGraphics];
            
            //EMPTY THEMEARRAY USE TO STORE COORDINATE SELECTED BY USER
            [themeArray removeAllObjects];
            
        }
        
        //ADD GRAPHICLAYER TO MAPVIEW WITH NAME FOR EASY REMOVING
        [self.mapView addMapLayer:myGraphicsLayer withName:@"PolygonTheme"];
        
        
        //NO. OF TIME USER SELECT POINT ON THE MAP (MAX 4)
        if (themeCounter <4) {
        
            NSString *tempString = [NSString stringWithFormat:@"[%f,%f]",[mappoint x],[mappoint y]];
            
            //ADD COORDINATE SELECTED INTO ARRAY
            [themeArray addObject:tempString];
            
            //FORMAT STRING INTO REQUIRED FORMAT (JSON)
            NSString *tempString2 = [NSString stringWithFormat:@"%@",themeArray];
            NSString * newString1 = [tempString2 stringByReplacingOccurrencesOfString:@")" withString:@"]"];
            NSString * newString2 = [newString1 stringByReplacingOccurrencesOfString:@"(" withString:@"["];
            NSString * newString3 = [newString2 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString* polygonString = [NSString stringWithFormat:@"\{ \"rings\" : [%@],\"spatialReference\" : {\"wkid\" : 4320}}",newString3];
            
            //ASSIGN INTO NSDATA AND THEN INTO NSDICTIONARY
            NSData* data = [polygonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *coor =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            polygon = [AGSPolygon polygonWithJSON:coor];
            
            
            
            //COMPOSITE SYMBOL
            AGSCompositeSymbol* composite = [AGSCompositeSymbol compositeSymbol];
            
            //POINT DESIGN
            AGSSimpleMarkerSymbol* markerSymbol = [[AGSSimpleMarkerSymbol alloc] init];
            markerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
            markerSymbol.color = [UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:1];
            [composite addSymbol:markerSymbol];
            
            //LINE DESIGN
            AGSSimpleLineSymbol* lineSymbol = [[AGSSimpleLineSymbol alloc] init];
            lineSymbol.color= [UIColor grayColor];
            lineSymbol.width = 4;
            [composite addSymbol:lineSymbol];
            
            //FILL DESIGN
            AGSSimpleFillSymbol* fillSymbol = [[AGSSimpleFillSymbol alloc] init];
            fillSymbol.color = [UIColor colorWithRed:42/255.0f green:176/255.0f blue:255/255.0f alpha:0.2];
            [composite addSymbol:fillSymbol];

            //CREATE GRAPHIC
            AGSGraphic* myGraphic =
            [AGSGraphic graphicWithGeometry:polygon
                                     symbol:composite
                                 attributes:nil];
            
            //ADD GRAPHIC TO GRAPHICLAYER
            [myGraphicsLayer addGraphic:myGraphic];
            
            //INCREASE COUNTER BY 1
            themeCounter++;
        
            //IF 4 = USER HAVE FINISH SELECTING 4 LOCATION TO FORM POLYGON
            if (themeCounter ==4) {
                
                //HIDE THE MESSAGE ASKING USER TO SELECT LOCATION
                [self hide];

                //START LOADING INDICATOR
                [self loading];

                //CALL MASHUP API TO GET ALL THEME SELECTED BY USERS
                Mashup *mash = [[Mashup alloc]init];
                [queue addOperation:mash];
                
            }
        
        }
    
    }
    
    //OTHER THAN ADDING CUSTOM THEME SEARCH / MEASURE DISTANCE,AREA
    else{
       
        //DISPLAY CALLOUT FOR PIN ICON
        if ([features objectForKey:@"PinIcon"] != 0) {
    
            if ([[StaticObjects getAddress] isEqualToString:@"BLK (null) (null) (null)"]) {
            
                //DISPLAY CALLOUT
                [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
                mapView.callout.title = @"Address";
                mapView.callout.detail = [StaticObjects getNameOfAddress];
                mapView.callout.accessoryButtonHidden = YES;
                mapView.callout.autoAdjustWidth = YES;
            }
            else {
                
                //DISPLAY CALLOUT
                [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
                mapView.callout.title = [StaticObjects getBuilding];
                mapView.callout.detail = [StaticObjects getAddress];
                mapView.callout.accessoryButtonHidden = YES;
                mapView.callout.autoAdjustWidth = YES;
            
            }
        }
        
        //DISPLAY CALLOUT FOR ROUTE PIN ICON
        else if ([features objectForKey:@"RoutePin"] != 0) {
        
            NSMutableArray *tempArrayX = [[NSMutableArray alloc]init];
            
            if ([StaticObjects getSwapRouteStatusForDirection] == NO) {
                
                [tempArrayX addObject:[StaticObjects getStartDirectionX]];
                [tempArrayX addObject:[StaticObjects getEndDirectionX]];
            
            }
            else {
                
                [tempArrayX addObject:[StaticObjects getEndDirectionX]];
                [tempArrayX addObject:[StaticObjects getStartDirectionX]];
                
            }
            
            
            
            //CHECK FOR CLOSEST COORDINATE FOR X AXIS
            int lowestIndexX=0, lowestDiffX=INT_MAX;
            for(int i=0; i<[tempArrayX count]; i++)
            {
                int current = [[tempArrayX objectAtIndex:i] doubleValue];
                int diff = abs(mappoint.x - current);
                if(diff < lowestDiffX)
                {
                    lowestDiffX = diff;
                    lowestIndexX = i;
                }
            }
            
            
            if (lowestIndexX == 0) {
                
                
                    //DISPLAY CALLOUT
                    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
                    mapView.callout.title = @"Start";
                    mapView.callout.detail = [StaticObjects getStartName];
                    mapView.callout.accessoryButtonHidden = YES;
                    mapView.callout.autoAdjustWidth = YES;

            }
            else if (lowestIndexX == 1){
                
                
                    //DISPLAY CALLOUT
                    [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
                    mapView.callout.title = @"End";
                    mapView.callout.detail = [StaticObjects getEndName];
                    mapView.callout.accessoryButtonHidden = YES;
                    mapView.callout.autoAdjustWidth = YES;
                
            }
            
        
        }
        
        //DISPLAY CALLOUT FOR PUBLIC TRANSPORT PIN ICON
        else if ([features objectForKey:@"PublicPin"] != 0) {
        
            NSMutableArray *tempArrayX = [[NSMutableArray alloc]init];
            
            //GET NO. OF ITEM IN ARRAY FOR ALIGHT X
            NSMutableArray *tempArray3 = [[NSMutableArray alloc]init];
            tempArray3 =[[StaticObjects getTransferCoordinate] objectAtIndex:2];
            int count = [tempArray3 count];
            
            [tempArrayX addObject:[[[StaticObjects getTransferCoordinate] objectAtIndex:0] objectAtIndex:0]];
            [tempArrayX addObject:[[[StaticObjects getTransferCoordinate] objectAtIndex:2] objectAtIndex:(count -1)]
];
            
            
            //CHECK FOR CLOSEST COORDINATE FOR X AXIS
            int lowestIndexX=0, lowestDiffX=INT_MAX;
            for(int i=0; i<[tempArrayX count]; i++)
            {
                int current = [[tempArrayX objectAtIndex:i] doubleValue];
                int diff = abs(mappoint.x - current);
                if(diff < lowestDiffX)
                {
                    lowestDiffX = diff;
                    lowestIndexX = i;
                }
            }
            
            
            if (lowestIndexX == 0) {
                
                
                //DISPLAY CALLOUT
                [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
                mapView.callout.title = @"Start";
                mapView.callout.detail = [[StaticObjects getBusBoard] objectAtIndex:0];
                mapView.callout.accessoryButtonHidden = YES;
                mapView.callout.autoAdjustWidth = YES;
                
            }
            else if (lowestIndexX == 1){
                
                //NO. OF ITEM IN ARRAY
                int count = [[StaticObjects getBusAlight] count];
                
                //DISPLAY CALLOUT
                [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
                mapView.callout.title = @"End";
                mapView.callout.detail = [[StaticObjects getBusAlight] objectAtIndex:count -1];
                mapView.callout.accessoryButtonHidden = YES;
                mapView.callout.autoAdjustWidth = YES;
                
            }

        
        }
        
        //DISPLAY CALLOUT INFO FOR ANY POINT SELECTED OTHER THAN PIN IMAGE/POLYGON
        else if([features count] ==0 && [StaticObjects getIdentifyStatus] ==YES){
        
            //LOADING INDICATOR
            [self loading];
        
            //ADD COORDINATE SELECTED INTO A TEMP ARRAY
            NSMutableArray *tempCorr = [NSMutableArray new];
            [tempCorr addObject:[NSNumber numberWithFloat:mappoint.x]];
            [tempCorr addObject:[NSNumber numberWithFloat:mappoint.y]];
        
            //CALL REVERSE GEOCODE API & PASS ARRAY
            rev = [[ReverseGeocode alloc]init];
            [rev start:tempCorr];
        
        }
        
        //DISPLAY CALLOUT FOR THEME SEARCH
        else if([features objectForKey:@"AllThemeResult"] !=0 || [features objectForKey:@"CustomThemeResult"] !=0){
        
            //NSLog(@"TEST =%@",[StaticObjects getMashCoordinate]);
            //NSLog(@"TEST3 -%f",mappoint.x);

            NSArray *tempArray1 = [[NSArray alloc]init];
            NSMutableArray *tempArray2 = [[NSMutableArray alloc]init];
            
            //SEPARATE COORDINATE INTO X AND Y
            for (int i=0; i<[[StaticObjects getMashCoordinate] count]; i++) {
                
                 tempArray1 = [[[StaticObjects getMashCoordinate] objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                
                //DIFF BETWEEN X & Y FOR ALL THEME COOR
                double diff = ([[tempArray1 objectAtIndex:0] doubleValue] - [[tempArray1 objectAtIndex:1] doubleValue]);
                
                //ADD TO ARRAY
                [tempArray2 addObject:[NSString stringWithFormat:@"%f",diff]];
                

            }
            
            //DIFF BETWEEN X & Y FOR MAPPOINT
            double mapPtDiff = (mappoint.x - mappoint.y);
            
            //CHECK FOR CLOSEST NUMBER BETWEEN (tempArray2 & mapPtDiff)
            int lowestIndex=0, lowestDiff=INT_MAX;
            for(int i=0; i<[tempArray2 count]; i++)
            {
                int current = [[tempArray2 objectAtIndex:i] doubleValue];
                int diff = abs(mapPtDiff - current);
                if(diff < lowestDiff)
                {
                    lowestDiff = diff;
                    lowestIndex = i;
                }
            }
            
            
            //DISPLAY CALLOUT
            [self.mapView.callout showCalloutAt:mappoint screenOffset:CGPointZero animated:YES];
            
            mapView.callout.accessoryButtonHidden = YES;
            mapView.callout.title = [[StaticObjects getMashName] objectAtIndex:lowestIndex];
            mapView.callout.detail = [[StaticObjects getMashLink] objectAtIndex:lowestIndex];
            mapView.callout.autoAdjustWidth = YES;
            
        }
        
    }
    
}

/*
//CLICK CALLOUT ACCESSORY BUTTON (NOT IN USE CURRENTLY)
-(void) didClickAccessoryButtonForCallout:(AGSCallout *)callout{

    //PERFORM SEGUE TO GET DIRECTION VIEW
    [self performSegueWithIdentifier:@"getdirection.segue" sender:self];
    
}
*/






//------------------------------------------------------------------------------------------------------//
//POPUP LABEL FOR THEME SEARCH WHEN USER IS REQUIRED TO SELECT 4 LOCATION (LABEL APPEAR BELOW MAIN VIEW)//
//------------------------------------------------------------------------------------------------------//
- (UILabel *)popupLabel
{
    if( !_popupLabel ) {
        CGFloat height = 64.0;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.view.bounds.size.height - height,
                                                                   self.view.bounds.size.width,
                                                                   height)];
        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.alpha = 0.0;
        [self.view addSubview:label];
        
        _popupLabel = label;
    }
    [self.view bringSubviewToFront:_popupLabel];
    _popupLabel.numberOfLines =3;
    
    return _popupLabel;
}






//---------------------------------------------------//
//POPUP LABEL FOR ROUTE AFTER FINISHING GET DIRECTION//
//---------------------------------------------------//
- (UILabel *)routeLabel
{
    if( !_routeLabel ) {
        CGFloat height = 64.0;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.view.bounds.size.height - height,
                                                                   self.view.bounds.size.width,
                                                                   height)];
        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.97];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        label.alpha = 0.0;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 1.0;
        label.layer.cornerRadius = 12;
        
        UIImageView * directionImage = [[UIImageView alloc] init];;
        
        directionImage.frame=CGRectMake(6,7,50,50);
        
        [directionImage setImage:[UIImage imageNamed: @"StraightArrow.png"]];

        [label addSubview:directionImage];;

        [self.view addSubview:label];
        
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = \
        [[UITapGestureRecognizer alloc]
         initWithTarget:self action:@selector(routeLabelTapAction:)];
        [label addGestureRecognizer:tapGesture];
        
        _routeLabel = label;
    }
    [self.view bringSubviewToFront:_routeLabel];
    _routeLabel.numberOfLines =0;
    
    return _routeLabel;
}






//--------------------------------------------------//
//LABEL BELOW SCREEN WHEN USER SELECT MEASURE LENGTH//
//--------------------------------------------------//
- (UILabel *)distanceLabel
{
    if( !_distanceLabel ) {
        CGFloat height = 64.0;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.view.bounds.size.height - height,
                                                                   self.view.bounds.size.width,
                                                                   height)];
        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.97];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        label.alpha = 0.0;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 1.0;
        label.layer.cornerRadius = 12;

        [self.view addSubview:label];
        
        _distanceLabel = label;
    }
    [self.view bringSubviewToFront:_distanceLabel];
    _distanceLabel.numberOfLines =0;
    
    return _distanceLabel;
}






//-----------------------------------------------------------//
//WHEN TAP ON BLACK LABEL SLIDE ICON TO GET ROUTE INFO DETAIL//
//-----------------------------------------------------------//
- (void)routeLabelTapAction:(UITapGestureRecognizer *)tapGesture {
    
    NSLog(@"DID TAP");
    
    //PREFORM SEGUE
    [self performSegueWithIdentifier: @"pushToRoute" sender: self];

}





//-----------------------------//
//CHECK SEGUE BEFORE PERFORMING//
//-----------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender

{
    if ([[segue identifier] isEqualToString:@"pushToRoute"]) {
        
        //PASS ARRAY TO CATEGORYVIEW
        RouteViewController *routeviewcontroller = [segue destinationViewController];
        routeviewcontroller.routeView = routeFrom;
    
    }

}





//--------------------------------------------//
//SHOW MESSAGE FOR POPUPLABEL FOR THEME SEARCH//
//--------------------------------------------//
- (void)showWithMessage:(NSString *)message
{
    self.popupLabel.text = message;
    [self.popupLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];

    [UIView animateWithDuration:1.0 animations:^{
        self.popupLabel.alpha = 1.0;
    }];
}





//----------------------------------//
//SHOW MESSAGE FOR ROUTE INFORMATION//
//----------------------------------//
- (void)showWithMessageForDirection:(NSString *)message
{
    UILabel *routeText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 267,
                                                                   9,self.view.bounds.size.width - 65,
                                                                   30)];
    
    UILabel *routeDistance = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 267,
                                                                   35,self.view.bounds.size.width - 65,
                                                                   30)];
    UILabel *tapHere = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 130,
                                                                       35,self.view.bounds.size.width - 200,
                                                                       30)];
    
    routeDistance.text = [NSString stringWithFormat:@"%@",[StaticObjects getDriveDistanceStop]];
    routeDistance.textColor = [UIColor whiteColor];
    routeDistance.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.97];
    [routeDistance setFont:[UIFont fontWithName:@"Arial" size:15]];
    routeDistance.textAlignment = NSTextAlignmentLeft;
    
    tapHere.text = [NSString stringWithFormat:@"Tap Here For Detail"];
    tapHere.textColor = [UIColor whiteColor];
    tapHere.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.97];
    [tapHere setFont:[UIFont fontWithName:@"Arial" size:11]];
    tapHere.textAlignment = NSTextAlignmentRight;
    
    routeText.text = message;
    routeText.textColor = [UIColor whiteColor];
    routeText.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.97];
    [routeText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:22]];
    [routeText setNumberOfLines:0];
    routeText.textAlignment = NSTextAlignmentLeft;

    [self.routeLabel addSubview:routeDistance];
    [self.routeLabel addSubview:routeText];
    [self.routeLabel addSubview:tapHere];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.routeLabel.alpha = 1.0;
    }];
}





//----------------------------------//
//SHOW MESSAGE FOR CALCUATE DISTANCE//
//----------------------------------//
- (void)showWithMessageForCalculateDistance:(NSString *)message
{
    UILabel *routeText = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.distanceLabel.bounds.size.height /3.5,self.view.bounds.size.width,
                                                                   30)];
    
    routeText.text = message;
    routeText.textColor = [UIColor whiteColor];
    routeText.textAlignment = NSTextAlignmentCenter;
    routeText.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.97];
    [routeText setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
    [routeText setNumberOfLines:0];
    
    [self.distanceLabel addSubview:routeText];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.distanceLabel.alpha = 1.0;
    }];
}





//------------------------//
//HIDE BLACK LABEL MESSAGE//
//------------------------//
- (void)hide
{
    
    // Add transition (must be called after myLabel has been displayed)
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionPush;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.popupLabel.layer addAnimation:animation forKey:@"changeTextTransition1"];
    [self.routeLabel.layer addAnimation:animation forKey:@"changeTextTransition2"];
    [self.distanceLabel.layer addAnimation:animation forKey:@"changeTextTransition3"];

    
    // Change the text
    self.popupLabel.alpha = 0.0;
    self.routeLabel.alpha = 0.0;
    self.distanceLabel.alpha = 0.0;

}





//-----------------//
//LOADING INDICATOR//
//-----------------//
-(void)loading{
    
    //SET LOADING INDICATOR
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"Loading...";
    [self.view addSubview:hud];
    [hud show:YES];

}





//-------------------------------------//
//DISPLAY POINT ON MAP FOR THEME SEARCH//
//-------------------------------------//
-(void)themeSearch:(NSNotification *)notification
{
    //DISPLAY ALL THEME
    if ([StaticObjects getDisplayTheme] == YES) {
        
        myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
        
        //ADD GRAPHICLAYER INTO MAP LAYER WITH NAME FOR EASY REMOVING
        [self.mapView addMapLayer:myGraphicsLayer withName:@"AllThemeResult"];
        
        
        //LOOP ACCORDING TO NO. OF COORDIANTE RETRIEVE USING MASHUP API (THEME SEARCH ALL)
        for (int i=0; i<[[StaticObjects getMashCoordinate] count]; i++) {
            
            //SEPARATE COORDINATE INTO X AND Y
            NSArray *tempArray1 = [[[StaticObjects getMashCoordinate] objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            
            //CREATE AGSPOINT WITH COORDINATE RETRIEVED MASHUP API
            AGSPoint* Point =
            [AGSPoint pointWithX:[[tempArray1 objectAtIndex:0] doubleValue]
                               y:[[tempArray1 objectAtIndex:1] doubleValue]
                spatialReference:self.mapView.spatialReference];
            
            //CREATE GRAPHIC
            AGSGraphic *themeGraphic =
            [AGSGraphic graphicWithGeometry:Point
                                     symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithRed:255/255.0f green:19/255.0f blue:22/255.0f alpha:1.0f]]
                                 attributes:nil];
            
            //ADD GRAPIHC TO GRAPHICLAYER
            [myGraphicsLayer addGraphic:themeGraphic];
            
            

        }
        //HIDE LOADING INDICATOR
        [hud hide:YES];
        
        AGSEnvelope * envelope = [[AGSEnvelope alloc]init];
        
        //ZOOM OUT TO SHOW WHOLE MAP
        [self.mapView zoomToEnvelope:[envelope initWithXmin:12069.487845 ymin:21503.949108 xmax:41119.158230 ymax:45086.248499 spatialReference:self.mapView.spatialReference] animated:YES];
        
        //DISPLAY MESSAGE IF NO RESULT FOUND
        if([StaticObjects getMashCoordinate] == 0){
            
            UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"No Result Found"
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [result show];
            
        }
        
        //DISPLAY MESSAGE IF GOT RESULTS
        else{
            
            NSString *tempString = [NSString stringWithFormat:@"%1d Results Found",[[StaticObjects getMashCoordinate] count]];
            
            UIAlertView *result = [[UIAlertView alloc] initWithTitle:tempString
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [result show];
            
        }
    }
    
    //DISPLAY CUSTOM THEME
    else if ([StaticObjects getDisplayTheme] == NO) {
    
        [self.mapView removeMapLayerWithName:@"PolygonTheme"];
        
        myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    
        //ADD GRAPHICLAYER INTO MAP LAYER WITH NAME FOR EASY REMOVING
        [self.mapView addMapLayer:myGraphicsLayer withName:@"CustomThemeResult"];
    
        //ALLOW MEMORY
        NSMutableArray *tempArrayX = [[NSMutableArray alloc]init];
        NSMutableArray *tempArrayY = [[NSMutableArray alloc]init];
    
        //LOOP ACCORDING TO NO. OF COORDIANTE RETRIEVE USING MASHUP API (THEME SEARCH)
        for (int i=0; i<[[StaticObjects getMashCoordinate] count]; i++) {

            //SEPARATE COORDINATE INTO X AND Y
            NSArray *tempArray1 = [[[StaticObjects getMashCoordinate] objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
            //CREATE AGSPOINT WITH COORDINATE RETRIEVED MASHUP API
            AGSPoint* Point =
            [AGSPoint pointWithX:[[tempArray1 objectAtIndex:0] doubleValue]
                           y:[[tempArray1 objectAtIndex:1] doubleValue]
            spatialReference:self.mapView.spatialReference];
        
        //CHECK IF COORDINATE IS CONTAIN INSIDE THE POLYGON
        if([polygon containsPoint:Point] == YES){
            
            //ADD COOR INTO TEMP ARRAY IF YES
            [tempArrayX addObject:[tempArray1 objectAtIndex:0]];
            [tempArrayY addObject:[tempArray1 objectAtIndex:1]];

            }
        
        
        
        }
    
        //LOOP THROUGH TEMP ARRAY AND DISPLAY POINT ON THE MAP INSIDE POLYGON (THEME SEARCH)
        for (int i=0; i<[tempArrayX count]; i++) {
            
            //CREATE AGSPOINT USING TEMP ARRAY
            AGSPoint* themePoint =
            [AGSPoint pointWithX:[[tempArrayX objectAtIndex:i] doubleValue]
                               y:[[tempArrayY objectAtIndex:i] doubleValue]
                spatialReference:self.mapView.spatialReference];
        
        
            //CREATE GRAPHIC
            AGSGraphic *themeGraphic =
            [AGSGraphic graphicWithGeometry:themePoint
                                     symbol:[AGSSimpleMarkerSymbol simpleMarkerSymbolWithColor:[UIColor colorWithRed:255/255.0f green:19/255.0f blue:22/255.0f alpha:1.0f]]
                                 attributes:nil];
        
            //ADD GRAPIHC TO GRAPHICLAYER
            [myGraphicsLayer addGraphic:themeGraphic];

        }
    
            //HIDE LOADING INDICATOR
            [hud hide:YES];
    
            //SET THEME STATUS TO NO
            [StaticObjects setThemeStatus:NO];
    
        //DISPLAY MESSAGE IF NO RESULT FOUND
        if([tempArrayX count] == 0){
        
            UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"No Result Found"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [result show];
    
        }
    
        //DISPLAY MESSAGE IF GOT RESULTS
        else{
        
            NSString *tempString = [NSString stringWithFormat:@"%1d Results Found",[tempArrayX count]];
        
            UIAlertView *result = [[UIAlertView alloc] initWithTitle:tempString
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [result show];
        
        }
    
    }
    
}





//---------------------------------------//
//DISPLAY CALLOUT FOR REVERSE GEOCODE API//
//---------------------------------------//
-(void)displayCallout:(NSNotification *)notification
{
    NSArray  *mapPointArray = [[notification userInfo] objectForKey:@"myArray"];

    //Create an AGSPoint for callout (add +33 so that callout display on top on image)
    AGSPoint* callOutPoint =
    [AGSPoint pointWithX:[[mapPointArray objectAtIndex:0] doubleValue]
                       y:[[mapPointArray objectAtIndex:1] doubleValue]+33
		spatialReference:self.mapView.spatialReference];

    //Hide RouteLabel
    [self hide];
    
    //Remove Pin Image on map
    [self.mapView removeMapLayerWithName:@"PinIcon"];
    
    if ([[StaticObjects getBuilding] isEqual:[NSNull null]]) {

        //DISPLAY CALLOUT
        [self.mapView.callout showCalloutAt:callOutPoint screenOffset:CGPointZero animated:YES];
        self.mapView.callout.accessoryButtonHidden = YES;
        self.mapView.callout.title = @"Address";
        self.mapView.callout.detail = [StaticObjects getAddress];
        self.mapView.callout.autoAdjustWidth = YES;
        
        [StaticObjects setNameOfAddress:[StaticObjects getAddress]];

    }
    else if ([[StaticObjects getAddress] isEqualToString:@"BLK (null) (null) (null)"]){

        //DISPLAY CALLOUT
        [self.mapView.callout showCalloutAt:callOutPoint screenOffset:CGPointZero animated:YES];
        self.mapView.callout.title = @"No Address";
        self.mapView.callout.detail = nil;
        self.mapView.callout.accessoryButtonHidden = YES;
        self.mapView.callout.autoAdjustWidth = YES;
        [StaticObjects setNameOfAddress:@"Destination Address"];
    }
    else{

        //DISPLAY CALLOUT
        [self.mapView.callout showCalloutAt:callOutPoint screenOffset:CGPointZero animated:YES];
        self.mapView.callout.title = [StaticObjects getBuilding];
        self.mapView.callout.detail = [StaticObjects getAddress];
        self.mapView.callout.accessoryButtonHidden = YES;
        self.mapView.callout.autoAdjustWidth = YES;

        //SET NAME OF ADDRESS
        [StaticObjects setNameOfAddress:[StaticObjects getBuilding]];

    }

        //SET COORDINATE
        [StaticObjects setXCoorrdinate:[mapPointArray objectAtIndex:0]];
        [StaticObjects setYCoorrdinate:[mapPointArray objectAtIndex:1]];

        //PERFORM METHOD
        [self performSelector:@selector(searchLocaton:) withObject:@"fromRandomLocation"];
    
        //HIDE LOADING INDICATOR
        [hud hide:YES];
 
    

    }





//----------------------//
//STOP LOADING INDICATOR//
//----------------------//
-(void)stopLoading:(NSNotification *)notification
{
    [hud hide:YES];
}





//-------------------------//
//ONCLICK SLIDE MENU BUTTON//
//-------------------------//
- (IBAction)slideMenu:(id)sender {
    
    //CHECK IF USER IS DOING THEME SEARCH
    if ([StaticObjects getThemeStatus] == YES) {
        
        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Please Select 4 Location On The Map Before Continuing. Press Clear To Cancel Operation"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];
        
    }
    
    //CHECK IF USER IS DOING MEASUREMENT
    else if (calculateDistanceStatus == YES) {
        
        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Please Press Clear To Cancel Operation Before Continuing"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];
        
    }
    
    //CHECK IF USER IS DOING MEASUREMENT
    else if (calculateAreaStatus == YES) {
        
        UIAlertView *result = [[UIAlertView alloc] initWithTitle:@"Please Press Clear To Cancel Operation Before Continuing"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [result show];
        
    }

    
    else{
    
    [self.slidingViewController anchorTopViewTo:ECRight];
    
    }
        
}




//--------------------//
//ONCLICK CLEAR BUTTON//
//--------------------//
- (IBAction)clearBtn:(id)sender {
    

    //REMOVE GRAPHIC
    [self.mapView removeMapLayerWithName:@"PinIcon"];
    [self.mapView removeMapLayerWithName:@"RoutePin"];
    [self.mapView removeMapLayerWithName:@"PolyLine"];
    [self.mapView removeMapLayerWithName:@"PolyLinePublic"];
    [self.mapView removeMapLayerWithName:@"PublicPin"];
    [self.mapView removeMapLayerWithName:@"PolygonTheme"];
    [self.mapView removeMapLayerWithName:@"CustomThemeResult"];
    [self.mapView removeMapLayerWithName:@"AllThemeResult"];
    [self.mapView removeMapLayerWithName:@"calArea"];
    [measureDistanceLayer removeAllGraphics];
    
    //HIDE POPUP MESSAGE
    [self hide];
    
    //THEME SEARCH RESET ALL
    [StaticObjects setThemeStatus:NO];
    themeCounter = 4;
    
    //CALCULATE DISTANCE RESET ALL
    calculateDistanceStatus = NO;
    totalDistance = 0;
    distanceCounter =0;
    [distanceArray removeAllObjects];
    [distancePoint removeAllObjects];
    
    //CALCULATE AREA RESET ALL
    calculateAreaStatus = NO;
    [themeArray removeAllObjects];
    areaCounter =0;
    totalArea =0;
    
    //HIDE CALLOUT
    self.mapView.callout.hidden = YES;
    
    
}





//-----------------------------//
//GET CURRENT LOCATION (BUTTON)//
//-----------------------------//
- (IBAction)currentLocation:(id)sender {

    //SHOW AND MOVE TO CURRENT LOCATION

    if(self.mapView.locationDisplay.isDataSourceStarted == TRUE)
    {
        NSLog(@"STARTED");
    }
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    
    [self.locationManager startUpdatingHeading];

}





//-------------------------------------------//
//IDENTIFY BUTTON TO IDENTIFY LOCATION ON MAP//
//-------------------------------------------//
- (IBAction)identify:(id)sender {
    
    //Check identify status
    if ([StaticObjects getIdentifyStatus] ==NO)
    {
        
        MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        //DISPLAY MESSAGE
        hud1.mode = MBProgressHUDModeText;
        hud1.labelText = @"Identify Location On";
        hud1.margin = 10.f;
        hud1.yOffset = 150.f;
        hud1.removeFromSuperViewOnHide = YES;
        
        //HIDE MESSAGE AFTER DELAY
        [hud1 hide:YES afterDelay:0.9];
        
        [StaticObjects setIdentifyStatus:YES];
    }
    
    //Check identify status
    else if ([StaticObjects getIdentifyStatus] ==YES)
    {
        
        MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        //DISPLAY MESSAGE
        hud1.mode = MBProgressHUDModeText;
        hud1.labelText = @"Identify Location Off";
        hud1.margin = 10.f;
        hud1.yOffset = 150.f;
        hud1.removeFromSuperViewOnHide = YES;
        
        //HIDE MESSAGE AFTER DELAY
        [hud1 hide:YES afterDelay:0.9];

        
        [StaticObjects setIdentifyStatus:NO];
    }
}





//---------------------------------------------------------//
//TWO FINGER ROTATION GESTURE METHOD (CURRENTLY NOT IN USE)//
//---------------------------------------------------------//
- (void)twoFingersRotate:(UIRotationGestureRecognizer *)recognizer
{
    
    // Convert the radian value to show the degree of rotation
    rotation = [recognizer rotation] * (180 / M_PI);
    //[self.mapView setRotationAngle:rotation animated:NO];
   
}


@end
