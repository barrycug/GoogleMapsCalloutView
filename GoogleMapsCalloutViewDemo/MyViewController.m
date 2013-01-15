//
//  MyViewController.m
//  GoogleMapsCalloutViewDemo
//
//  Created by Ryan Maxwell on 15/01/13.
//  Copyright (c) 2013 Ryan Maxwell. All rights reserved.
//

#import "MyViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <SMCalloutView/SMCalloutView.h>

static const CGFloat CalloutYOffset = 45.0f;

static const CGFloat DefaultZoom = 12.0f;

/* Paris */
static const CLLocationDegrees DefaultLatitude = 48.856132;
static const CLLocationDegrees DefaultLongitude = 2.339004;

@interface MyViewController () <GMSMapViewDelegate>
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.calloutView = [[SMCalloutView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button    addTarget:self
                  action:@selector(calloutAccessoryButtonTapped:)
        forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;
    
	
    GMSCamera camera = GMSCameraMake(DefaultLatitude, DefaultLongitude, DefaultZoom);
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds
                                     camera:camera];
    self.mapView.delegate = self;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self addMarkersToMap];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    self.emptyCalloutView = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.mapView startRendering];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView stopRendering];
}

- (void)addMarkersToMap {
    
    NSArray *markers = @[
        @{
            @"title": @"Eiffel Tower",
            @"latitude": @48.8584,
            @"longitude": @2.2946
        },
        @{
            @"title": @"La Louvre",
            @"latitude": @48.8609,
            @"longitude": @2.3363
        },
        @{
            @"title": @"Arc de Triomphe",
            @"latitude": @48.8738,
            @"longitude": @2.2950
        },
        @{
            @"title": @"Notre Dame de Paris",
            @"latitude": @48.8530,
            @"longitude": @2.3498
        }
    ];
    
    UIImage *pinImage = [UIImage imageNamed:@"Pin"];
    
    for (NSDictionary *marker in markers) {
        GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
        
        options.position = CLLocationCoordinate2DMake([marker[@"latitude"] doubleValue], [marker[@"longitude"] doubleValue]);
        options.title = marker[@"title"];
        options.icon = pinImage;
        
        options.infoWindowAnchor = CGPointMake(0.5, 0.25);
        options.groundAnchor = CGPointMake(0.5, 1.0);
        
        [self.mapView addMarkerWithOptions:options];
    }
}


- (void)calloutAccessoryButtonTapped:(id)sender {
    if (self.mapView.selectedMarker) {
        
        NSString *message = [NSString stringWithFormat:@"Show info for %@", self.mapView.selectedMarker.title];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(id<GMSMarker>)marker {
    CLLocationCoordinate2D anchor = marker.position;
    
    CGPoint point = [mapView.projection pointForCoordinate:anchor];
    
    self.calloutView.title = marker.title;
    
    self.calloutView.calloutOffset = CGPointMake(0, -CalloutYOffset);
    
    self.calloutView.hidden = NO;
    
    CGRect calloutRect = CGRectZero;
    calloutRect.origin = point;
    calloutRect.size = CGSizeZero;
    
    [self.calloutView presentCalloutFromRect:calloutRect
                                 inView:mapView
                      constrainedToView:mapView
               permittedArrowDirections:SMCalloutArrowDirectionDown
                               animated:YES];
    
    return self.emptyCalloutView;
}

- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCamera)position {
    /* move callout with map drag */
    if (pMapView.selectedMarker != nil && !self.calloutView.hidden) {
        CLLocationCoordinate2D anchor = [pMapView.selectedMarker position];
        
        CGPoint pt = [pMapView.projection pointForCoordinate:anchor];
        
        /* objectAtIndex:3 is the bottomAnchor ImageView, aka the triangle. */
        UIImageView *iv = (self.calloutView.subviews)[3];
        CGFloat widthadjust = iv.frame.size.width / 2;
        CGFloat cx = iv.frame.origin.x + widthadjust;
        pt.x -= cx;
        pt.y -= iv.frame.size.height - 11 + CalloutYOffset;
        self.calloutView.frame = (CGRect) {.origin = pt, .size = self.calloutView.frame.size };
    } else {
        self.calloutView.hidden = YES;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.calloutView.hidden = YES;
}

@end