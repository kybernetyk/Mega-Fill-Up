//
//  LoadingScene.h
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LoadingOperation.h"

@interface LoadingScene : CCScene
{
	NSString *nextSceneClassName;
	LoadingOperation *loadingOperation;
	
	float x;
}
+ (id) nodeWithSceneClassToFollow: (NSString *) className;

@end
