//
//  SUBasicUpdateDriver.h
//  Sparkle,
//
//  Created by Andy Matuschak on 4/23/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUBASICUPDATEDRIVER_H
#define SUBASICUPDATEDRIVER_H

#import <UIKit/UIKit.h>
#import "SUUpdateDriver.h"

@class SUAppcastItem, SUUnarchiver, SUAppcast, SUUnarchiver, SUHost;
@interface SUBasicUpdateDriver : SUUpdateDriver {
	SUAppcastItem *updateItem;
	SUAppcastItem *nonDeltaUpdateItem;
	
#ifndef SHIMMER_REFACTOR
	NSURLDownload *download;
#endif
	NSString *downloadPath;
	NSString *tempDir;
	
	NSString *relaunchPath;
}

- (void)checkForUpdatesAtURL:(NSURL *)URL host:(SUHost *)host;

- (void)appcastDidFinishLoading:(SUAppcast *)ac;
- (void)appcast:(SUAppcast *)ac failedToLoadWithError:(NSError *)error;

- (BOOL)isItemNewer:(SUAppcastItem *)ui;
- (BOOL)hostSupportsItem:(SUAppcastItem *)ui;
- (BOOL)itemContainsSkippedVersion:(SUAppcastItem *)ui;
- (BOOL)itemContainsValidUpdate:(SUAppcastItem *)ui;
- (void)didFindValidUpdate;
- (void)didNotFindUpdate;

- (void)downloadUpdate;
#ifndef SHIMMER_REFACTOR
- (void)download:(NSURLDownload *)d decideDestinationWithSuggestedFilename:(NSString *)name;
- (void)downloadDidFinish:(NSURLDownload *)d;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
#endif

- (void)extractUpdate;
- (void)unarchiverDidFinish:(SUUnarchiver *)ua;
- (void)unarchiverDidFail:(SUUnarchiver *)ua;
- (void)failedToApplyDeltaUpdate;

- (void)installWithToolAndRelaunch:(BOOL)relaunch;
- (void)installerForHost:(SUHost *)host failedWithError:(NSError *)error;

- (void)installWithToolAndRelaunch:(BOOL)relaunch;
- (void)cleanUpDownload;

- (void)abortUpdate;
- (void)abortUpdateWithError:(NSError *)error;

@end

#endif
