//
//  FacebookSubmitController.m
//  Super Fill Up
//
//  Created by jrk on 26/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "FacebookSubmitController.h"
#import "FBConnect.h"
#import "SBJSON.h"
#import "FlurryAPI.h"

@implementation FacebookSubmitController
@synthesize score;
@synthesize level;
@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


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


- (void)dealloc 
{
	NSLog(@"facebook lol dealloc");
	[facebook release];
	facebook = nil;
	
    [super dealloc];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
	NSLog(@"we're here!");
	dismissing = NO;
	[self shareOverFarmville];
//	[self dismissModalViewControllerAnimated: YES];

}

#define APP_ID @"128002613920013"
#define API_KEY @"1c3b539f2ef8179b4151bb35ff26ce10"

#pragma mark -
#pragma mark farmville
- (void) shareOverFarmville
{
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
	if (!facebook)
	{
		facebook = [[Facebook alloc] init];
		
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		NSString *token = [defs objectForKey: @"fbtoken"];
		if (token)
		{
			NSLog(@"found token: %@", token);
			[facebook setAccessToken: token];	
		}
		
		NSArray *perms = [NSArray arrayWithObjects:@"publish_stream",@"offline_access", nil];
		[facebook authorize: APP_ID permissions: perms delegate: self];
		
		return;
	}
	[self share2];
}

- (void)fbDidLogin
{
	NSLog(@"fb login");
	if ([facebook accessToken])
	{
		NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
		[defs setObject: [facebook accessToken] forKey: @"fbtoken"];
		[defs synchronize];
	}
	
	unlock_orientation = NO;
	[self share2];	
}

- (void) killme
{
	if (!dismissing)
	{	
		dismissing = YES;
	//	[self dismissModalViewControllerAnimated: NO];	
		[delegate facebookSubmitControllerDidFinish: self];
	}
}

/**
 * Called when the user dismiss the dialog without login
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
	[FlurryAPI logEvent:@"Facebook - User Canclled Without Login"];
	NSLog(@"fb nologin");
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs removeObjectForKey: @"fbtoken"];
	[defs synchronize];
	
	isPostingOnFB = NO;
	[facebook release];
	facebook = nil;
	unlock_orientation = NO;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];

	[self killme];	
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName: @"MXCanEnableFacebookButton" object: nil];


}

/**
 * Called when the user is logged out
 */
- (void)fbDidLogout
{
	[FlurryAPI logEvent:@"Facebook - Logout"];
	NSLog(@"fb logout");
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs removeObjectForKey: @"fbtoken"];
	[defs synchronize];
	
	unlock_orientation = NO;
	isPostingOnFB = NO;	
	[facebook release];
	facebook = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];

	[self killme];	

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName: @"MXCanEnableFacebookButton" object: nil];
	
}


- (void) share2
{
	[FlurryAPI logEvent:@"Facebook - Share Request"];
	NSString *modename = @"(Classic Mode)";
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		modename = @"(Gravity Mode)";
	

	unlock_orientation = NO;
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
								   API_KEY, @"api_key",
								   [NSString stringWithFormat: @"My Mega Fill-Up %@ score is %i!",modename,score] , @"message",
								   nil];
	/*	NSString *action_links = @"[{\"text\":\"How Evil Are You???\",\"href\":\"http://itunes.apple.com/us/app/how-evil-are-you/id393122123?mt=8\"}]";
	 [params setObject:action_links forKey:@"action_links"];
	 
	 
	 NSLog(@"post params: %@", params);*/
	
	NSString *picurl = [NSString stringWithString: @"http://www.minyxgames.com/mega-fill-up/icon_90.png"];
	//NSString *picurl = [NSString stringWithString: @"http://www.minyxgames.com/mega-fill-up/not_awesome_face.png"];
	NSString *captionText = [NSString stringWithFormat: @"{*actor*} reached level %i and scored %i points on Mega Fill-Up %@!",level, score,modename];
	

	NSString *hiscore_key = @"personal_classic_high_score";
	if (g_GameInfo.gameMode == GRAVITY_MODE)
		hiscore_key = @"personal_gravity_high_score";
	
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *personalHighScore = [defs objectForKey: hiscore_key];
	NSInteger personal_high_score = [personalHighScore integerValue];
	
	NSString *descString = nil;
	if (score >= personal_high_score)
	{
		descString = @"This is a new personal high score!";
		//picurl = @"http://www.minyxgames.com/mega-fill-up/awesome_face.png";
	}
	else
	{
		descString = [NSString stringWithFormat: @"His/her personal high score is: %i!", personal_high_score];
	}
	

	
	//media
	NSMutableDictionary *media_entry = [NSMutableDictionary dictionary];
	[media_entry setObject: @"image" forKey: @"type"];
	[media_entry setObject: picurl forKey: @"src"];
	[media_entry setObject: @"http://www.facebook.com/apps/application.php?id=128002613920013" forKey: @"href"];
	NSArray *media = [NSArray arrayWithObject: media_entry];
	
	//attachment
	NSMutableDictionary *attachment = [NSMutableDictionary dictionary];
	[attachment setObject: @"http://www.facebook.com/apps/application.php?id=128002613920013" forKey: @"href"];
	[attachment setObject: captionText forKey: @"caption"];
	[attachment setObject: descString forKey: @"description"];
	[attachment setObject: media forKey: @"media"];
	
	
	//actionlinks
	NSMutableDictionary *action_link = [NSMutableDictionary dictionary];
	[action_link setObject: @"Mega Fill Up for iPhone" forKey: @"text"];
	[action_link setObject: @"http://itunes.apple.com/app/id401504746"  forKey: @"href"];
	NSArray *action_links = [NSArray arrayWithObject: action_link];
	
	SBJSON *json = [[[SBJSON alloc] init] autorelease];
	
	NSString *strAttachment = [json stringWithObject: attachment];
	NSString *strActionLinks = [json stringWithObject: action_links];
	
	[params setObject: strAttachment forKey: @"attachment"];
	[params setObject: strActionLinks forKey: @"action_links"];
	
	NSLog(@"attachment: %@",strAttachment);
	NSLog(@"links: %@",strActionLinks);
	
	[facebook retain];
	[facebook requestWithMethodName: @"stream.publish" andParams: params andHttpMethod: @"POST" andDelegate: self];
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	[FlurryAPI logEvent:@"Facebook - Share Request - Did Fail"];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs removeObjectForKey: @"fbtoken"];
	[defs synchronize];
	
	NSLog(@"FB REQ DID FAIL: %@", [error localizedDescription]);
	[facebook autorelease];
	[facebook release];
	facebook = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook",nil) 
													message:NSLocalizedString(@"Couldn't post to Facebook. Please try again!",nil)
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release]; 
	isPostingOnFB = NO;
	unlock_orientation = NO;

	[self killme];	
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName: @"MXCanEnableFacebookButton" object: nil];
	

}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result
{
	[FlurryAPI logEvent:@"Facebook - Share Request - Did Succeed"];
	NSLog(@"FB REQ SUCCESS: %@", [[[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding] autorelease]);
	unlock_orientation = NO;
	//dont re enable on success
	//	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	//	[center postNotificationName: @"MXCanEnableFacebookButton" object: nil];
	
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Facebook",nil) 
													message:NSLocalizedString(@"Update successfully posted!",nil)
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release]; 
	[facebook autorelease];
	isPostingOnFB = NO;

	[self killme];	
}


/*- (void)dialogDidComplete:(FBDialog *)dialog
 {
 NSLog(@"dialog completed!");	
 
 NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
 NSInteger num = [defs integerForKey: @"facebookSent"];
 num++;
 [defs setInteger: num forKey: @"facebookSent"];
 [defs synchronize];
 
 if ([[[self currentJoke] jokeText] containsString: @"A-Team" ignoringCase: YES])
 {
 [defs setBool: YES forKey: @"ateam_facebook"];
 [defs synchronize];
 }
 
 DeineMuddaAppDelegate *del = [[UIApplication sharedApplication] delegate];
 [del currentUnlockLevel]; //trigger any achievement changes!
 
 
 }*/

- (void) fbDialogLogin:(NSString *) token expirationDate:(NSDate *) expirationDate
{
	NSLog(@"token: %@",token);
}

- (void) fbDialogNotLogin:(BOOL) cancelled
{
	[FlurryAPI logEvent:@"Facebook - fbDialogNotLogin"];
	unlock_orientation = NO;
	
	NSLog(@"cancel!");
	isPostingOnFB = NO;
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName: @"MXCanEnableFacebookButton" object: nil];
	
	[self killme];	
}


@end
