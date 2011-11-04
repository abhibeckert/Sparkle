//
//  SUWindowController.h
//  Sparkle
//
//  Created by Andy Matuschak on 2/13/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUWINDOWCONTROLLER_H
#define SUWINDOWCONTROLLER_H

#import <UIKit/UIkit.h>

@class SUHost;
@interface SUWindowController : NSWindowController { }
// We use this instead of plain old NSWindowController initWithWindowNibName so that we'll be able to find the right path when running in a bundle loaded from another app.
- (id)initWithHost:(SUHost *)host windowNibName:(NSString *)nibName;
@end

#endif
