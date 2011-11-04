//
//  SUAppcast.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUAPPCAST_H
#define SUAPPCAST_H

@class SUAppcastItem;
@interface SUAppcast : NSObject
{
@private
	NSArray *items;
	NSString *userAgentString;
	id delegate;
	NSMutableData *downloadData;
	NSURLConnection *downloadConnection;
}

- (void)fetchAppcastFromURL:(NSURL *)url;
- (void)setDelegate:delegate;
- (void)setUserAgentString:(NSString *)userAgentString;

- (NSArray *)items;

@end

@interface NSObject (SUAppcastDelegate)
- (void)appcastDidFinishLoading:(SUAppcast *)appcast;
- (void)appcast:(SUAppcast *)appcast failedToLoadWithError:(NSError *)error;
@end

#endif
