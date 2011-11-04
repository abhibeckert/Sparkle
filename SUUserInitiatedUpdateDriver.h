//
//  SUUserInitiatedUpdateDriver.h
//  Sparkle
//
//  Created by Andy Matuschak on 5/30/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUUSERINITIATEDUPDATEDRIVER_H
#define SUUSERINITIATEDUPDATEDRIVER_H

#import <UIKit/UIKit.h>
#import "SUUIBasedUpdateDriver.h"

@interface SUUserInitiatedUpdateDriver : SUUIBasedUpdateDriver
{
@private
#ifndef SHIMMER_REFACTOR
	SUStatusController *checkingController;
#endif
	BOOL isCanceled;
}

@end

#endif
