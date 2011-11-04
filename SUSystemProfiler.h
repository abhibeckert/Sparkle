//
//  SUSystemProfiler.h
//  Sparkle
//
//  Created by Andy Matuschak on 12/22/07.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUSYSTEMPROFILER_H
#define SUSYSTEMPROFILER_H

#import <UIKit/UIKit.h>

@class SUHost;
@interface SUSystemProfiler : NSObject {}
+ (SUSystemProfiler *)sharedSystemProfiler;
- (NSMutableArray *)systemProfileArrayForHost:(SUHost *)host;
@end

#endif
