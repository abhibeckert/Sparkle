//
//  SUUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/7/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUUPDATEDRIVER_H
#define SUUPDATEDRIVER_H

#import <UIKit/UIKit.h>

extern NSString * const SUUpdateDriverFinishedNotification;

@class SUHost, SUUpdater;
@interface SUUpdateDriver : NSObject
{
	SUHost *host;
	SUUpdater *updater;
	NSURL *appcastURL;
	
	BOOL finished;
}

- initWithUpdater:(SUUpdater *)updater;
- (void)checkForUpdatesAtURL:(NSURL *)URL host:(SUHost *)host;
- (void)abortUpdate;
- (BOOL)finished;

@end

#endif
