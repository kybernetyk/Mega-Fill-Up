//
//  MoneyViewController.h
//  Mega Fill-Up Lite
//
//  Created by jrk on 6/11/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdMobView.h"
#import "AdMobDelegateProtocol.h"
#import <iAd/iAd.h>

@interface MoneyViewController : UIViewController <AdMobDelegate>
{
	BOOL can_show_iad;
	BOOL can_show_admob;
	
	int lasthousead;
	
	
	UIButton *houseadButton;
	
	NSTimer *refreshTimer;
	
	
	ADBannerView *iAdView;
	AdMobView *adMobAd;
	BOOL is_admob_showing;
	
	UIViewController *superViewController;
}

@property (readwrite, retain) IBOutlet UIButton *houseadButton;
@property (readwrite, retain) IBOutlet ADBannerView *iAdView;
@property (readwrite, assign) UIViewController *superViewController;

- (IBAction) openHouseAd: (id) sender;

@end
