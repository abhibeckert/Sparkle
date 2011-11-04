//
//  SUAutomaticUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUAUTOMATICUPDATEDRIVER_H
#define SUAUTOMATICUPDATEDRIVER_H

#import <UIKit/UIKit.h>
#import "SUBasicUpdateDriver.h"

#ifndef SHIMMER_REFACTOR
@class SUAutomaticUpdateAlert;
#endif
@interface SUAutomaticUpdateDriver : SUBasicUpdateDriver
{
@private
	BOOL postponingInstallation, showErrors;
#ifndef SHIMMER_REFACTOR
	SUAutomaticUpdateAlert *alert;
#endif
}

@end

#endif
