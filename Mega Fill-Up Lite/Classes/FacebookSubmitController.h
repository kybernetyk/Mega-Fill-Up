//
//  FacebookSubmitController.h
//  Super Fill Up
//
//  Created by jrk on 26/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "FBConnect.h"

@interface FacebookSubmitController : UIViewController 
{
	Facebook *facebook;
	id delegate;
	NSInteger score;
	NSInteger level;
	BOOL isPostingOnFB;
	BOOL unlock_orientation;
	BOOL dismissing;
	
}

@property (readwrite, assign) NSInteger score;
@property (readwrite, assign) NSInteger level;
@property (readwrite, assign) id delegate;
- (void) shareOverFarmville;

@end
