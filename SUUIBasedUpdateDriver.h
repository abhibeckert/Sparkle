//
//  SUUIBasedUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/5/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUUIBASEDUPDATEDRIVER_H
#define SUUIBASEDUPDATEDRIVER_H

#import <UIKit/UIKit.h>
#import "SUBasicUpdateDriver.h"

#ifndef SHIMMER_REFACTOR
@class SUStatusController, SUUpdateAlert;
#else
@class SUUpdateAlert;
#endif

@interface SUUIBasedUpdateDriver : SUBasicUpdateDriver
{
#ifndef SHIMMER_REFACTOR
	SUStatusController *statusController;
	SUUpdateAlert *updateAlert;
#endif
}

#ifndef SHIMMER_REFACTOR
- (void)showModalAlert:(NSAlert *)alert;
#endif
- (IBAction)cancelDownload: (id)sender;
- (void)installAndRestart: (id)sender;

@end

#endif
