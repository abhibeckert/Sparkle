//
//  SUAutomaticUpdateAlert.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/18/06.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUAUTOMATICUPDATEALERT_H
#define SUAUTOMATICUPDATEALERT_H

#ifndef SHIMMER_REFACTOR
#import "SUWindowController.h"
#endif

typedef enum
{
	SUInstallNowChoice,
	SUInstallLaterChoice,
	SUDoNotInstallChoice
} SUAutomaticInstallationChoice;

@class SUAppcastItem, SUHost;
@interface SUAutomaticUpdateAlert : SUWindowController {
	SUAppcastItem *updateItem;
	id delegate;
	SUHost *host;
}

- (id)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)hostBundle delegate:delegate;
- (IBAction)installNow:sender;
- (IBAction)installLater:sender;
- (IBAction)doNotInstall:sender;

@end

@interface NSObject (SUAutomaticUpdateAlertDelegateProtocol)
- (void)automaticUpdateAlert:(SUAutomaticUpdateAlert *)aua finishedWithChoice:(SUAutomaticInstallationChoice)choice;
@end

#endif
