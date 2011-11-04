//
//  SUScheduledUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUSCHEDULEDUPDATEDRIVER_H
#define SUSCHEDULEDUPDATEDRIVER_H

#import <UIKit/UIKit.h>
#import "SUUIBasedUpdateDriver.h"

@interface SUScheduledUpdateDriver : SUUIBasedUpdateDriver
{
@private
	BOOL showErrors;
}

@end

#endif
