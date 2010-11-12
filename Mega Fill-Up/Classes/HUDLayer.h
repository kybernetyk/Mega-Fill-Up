//
//  HUDLayer.h
//  Super Fill Up
//
//  Created by jrk on 8/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HUDLayer : CCLayer 
{
	NSInteger 	level;
	NSInteger 	lives;
	NSInteger 	balls;
	float 		fill;
	
	CCLabelBMFont *levelLabel;
	CCLabelBMFont *livesLabel;
	CCLabelBMFont *ballsLabel;
	CCLabelBMFont *fillLabel;
}

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger lives;
@property (nonatomic, assign) NSInteger balls;
@property (nonatomic, assign) float fill;

- (void) updateLabels;

@end
