//
//  LoadingOperation.h
//  Super Fill Up
//
//  Created by jrk on 14/10/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoadingOperation : NSOperation
{
	id _delegate;
}

@property (readwrite, assign) id delegate;

@end
