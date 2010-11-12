//
//  MoneyViewController.m
//  Mega Fill-Up Lite
//
//  Created by jrk on 6/11/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MoneyViewController.h"
#import "AdMobView.h"
#import "AdMobDelegateProtocol.h"
#import "globals.h"
#import "BCAchievementNotificationCenter.h"
#import "BCAchievementNotificationView.h"

@implementation MoneyViewController
@synthesize houseadButton;
@synthesize iAdView;
@synthesize superViewController;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	can_show_iad = NO;
	can_show_admob = NO;
	
	

	adMobAd = [AdMobView requestAdWithDelegate: self];
	[adMobAd retain];

	[self showAnAd];	
	
	if (!refreshTimer)
		refreshTimer = [[NSTimer scheduledTimerWithTimeInterval: 15.0 
													 target: self 
												   selector: @selector(showAnAd)
												   userInfo: nil 
													repeats: YES] retain];
}

- (void) showAnAd
{
	NSLog(@"is online? %i", g_is_online);
	if (!g_is_online)
	{
		[self showHouseAd];
		
		return;
	}
	
	if (can_show_iad)
	{
		[self showIAd];
		return;
	}
	
	if (can_show_admob)
	{
		[self showAdMob];
		return;
	}
	
	[self showHouseAd];
}

#pragma mark - 
#pragma mark house ads
- (void) showHouseAd
{
	NSLog(@"showing house ad");
	[self hideIAd];
	[self hideAdMob];
	
	[houseadButton setHidden: NO];
	
	lasthousead ++;
	if (lasthousead > 2)
		lasthousead = 0;

	UIImage *img = nil;
	
	img = [UIImage imageNamed: [NSString stringWithFormat: @"housead_%i.png", (lasthousead+1)]];
	
	[houseadButton setImage: img forState: UIControlStateNormal];
}

- (void) hideHouseAd
{
	NSLog(@"hiding house ad");
	[houseadButton setHidden: YES];
}

- (IBAction) openHouseAd: (id) sender
{
	[[BCAchievementNotificationCenter defaultCenter] notifyWithTitle:@"Yo Dawg!" message:@"Sup dawg?" image: [UIImage imageNamed: @"Icon.png"]];
}

#pragma mark -
#pragma mark iad
- (void) showIAd
{
	NSLog(@"showing iAd");
	[self hideHouseAd];
	[self hideAdMob];
	
	CGRect frame;
	frame.origin.x = 0.0;
	frame.origin.y = 0.0;
	frame.size.width = 480;
	frame.size.height = 32;
	
	[iAdView setFrame: frame];
	
}

- (void) hideIAd
{
	CGRect frame;
	frame.origin.x = -480;
	frame.origin.y = 0.0;
	frame.size.width = 480;
	frame.size.height = 32;
	
	[iAdView setFrame: frame];
	NSLog(@"hiding iAd");
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
/*	if (![[GameInfo sharedInstance] isPaused])
	{
		[[GameInfo sharedInstance] setIsPaused: ![[GameInfo sharedInstance] isPaused]];
		NSLog(@"paused: %i",[[GameInfo sharedInstance] isPaused]);
		[[CCDirector sharedDirector] pushScene: [PauseScene node]];
		
	}
*/	
	
	NSLog(@"bannerViewActionShouldBegin:");
	return YES;	
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	can_show_iad = YES;
	[self showAnAd];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	can_show_iad = NO;
	
	NSLog(@"failed to get $$$ iAD: %@",[error localizedDescription]);
}


#pragma mark -
#pragma mark admob
- (void) showAdMob
{
	NSLog(@"showing admob");
	[self hideHouseAd];
	[self hideIAd];
	[adMobAd setHidden: NO];	

	if (!is_admob_showing)
	{
		[self performSelector: @selector(requestAdmob2:) withObject: self afterDelay: 30.0f];
	}
	is_admob_showing = YES;
}

- (void) hideAdMob
{
	[adMobAd setHidden: YES];	
	is_admob_showing = NO;
}






- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return @"a14cd555ce52c23"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	return [self superViewController];
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:0.208 green:0.435 blue:0.659 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1]; // this should be prefilled; if not, provide a UIColor
}

// To receive test ads rather than real ads...

 // Test ads are returned to these devices.  Device identifiers are the same used to register
 // as a development device with Apple.  To obtain a value open the Organizer
 // (Window -> Organizer from Xcode), control-click or right-click on the device's name, and
 // choose "Copy Device Identifier".  Alternatively you can obtain it through code using
 // [UIDevice currentDevice].uniqueIdentifier.
 //
 // For example:
 //    - (NSArray *)testDevices {
 //      return [NSArray arrayWithObjects:
 //              ADMOB_SIMULATOR_ID,                             // Simulator
 //              //@"28ab37c3902621dd572509110745071f0101b124",  // Test iPhone 3GS 3.0.1
 //              //@"8cf09e81ef3ec5418c3450f7954e0e95db8ab200",  // Test iPod 2.2.1
 //              nil];
 //    }
 
 - (NSArray *)testDevices {
 return [NSArray arrayWithObjects: ADMOB_SIMULATOR_ID, nil];
 }
 
 - (NSString *)testAdActionForAd:(AdMobView *)adMobView 
{
 return @"http://www.minyxgames.com"; // see AdMobDelegateProtocol.h for a listing of valid values here
 }


// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView 
{
	NSLog(@"AdMob: Did receive ad");
	// get the view frame
//	CGRect frame = self.view.frame;
	
	// put the ad at the bottom of the screen
	//adMobAd.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 48);
	
	CGRect frame = self.view.frame;
	frame.origin.x = 0.0;
	frame.origin.y = 0.0;
	frame.size.width = 480.0;
	frame.size.height = 32.0;
	
	// put the ad at the bottom of the screen
	//adMobAd.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 48);
	adMobAd.frame = frame;
	
	//		CGAffineTransform makeLandscape = CGAffineTransformMakeRotation(degreesToRadians(0));
	//	makeLandscape = CGAffineTransformTranslate(makeLandscape, -480/2 + 48/2, 320/2 - 48/2 - 12);
	CGAffineTransform makeLandscape = CGAffineTransformMakeScale(1.5, 32.0/48.0);
	
	//CGAffineTransformScale(makeLandscape, 480.0/320, 480.0/320);
	adMobAd.transform = makeLandscape;
	
	
	[self.view addSubview:adMobAd];
	[adMobAd setHidden: YES];
	
	can_show_admob = YES;
	[self showAnAd];
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView 
{
	is_admob_showing = NO;
	can_show_admob = NO;
	NSLog(@"AdMob: Did fail to receive ad");
	[adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
	[adMobAd release];
	adMobAd = nil;
	
//- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay

	// we could start a new ad request here, but in the interests of the user's battery life, let's not
	
	[self performSelector: @selector(requestAdmob:) withObject: self afterDelay: 30.0f];
}

- (void) requestAdmob: (id) trash
{
	can_show_admob = NO;
	NSLog(@"request new admob");
	[adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
	[adMobAd release];
	adMobAd = nil;
	
	adMobAd = [AdMobView requestAdWithDelegate: self];
	[adMobAd retain];
}

- (void) requestAdmob2: (id) trash
{
	can_show_admob = NO;
	NSLog(@"request new admob");
	[adMobAd removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
	[adMobAd release];
	adMobAd = nil;
	
	adMobAd = [AdMobView requestAdWithDelegate: self];
	[adMobAd retain];
	
	[self showAnAd];
}


- (void) refreshAdmob: (id) trash
{
	NSLog(@"refreshing admob ad");
	
}







/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
