//
//  SUAppcast.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "SUAppcast.h"
#import "SUConstants.h"
#import "SULog.h"
#import "SUAppcastXMLParser.h"

#ifndef SHIMMER_REFACTOR
@interface NSXMLElement (SUAppcastExtensions)
- (NSDictionary *)attributesAsDictionary;
@end

@implementation NSXMLElement (SUAppcastExtensions)
- (NSDictionary *)attributesAsDictionary
{
	NSEnumerator *attributeEnum = [[self attributes] objectEnumerator];
	NSXMLNode *attribute;
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

	while ((attribute = [attributeEnum nextObject]))
		[dictionary setObject:[attribute stringValue] forKey:[attribute name]];
	return dictionary;
}
@end
#endif

@interface SUAppcast (Private)
- (void)reportError:(NSError *)error;
#ifndef SHIMMER_REFACTOR
- (NSXMLNode *)bestNodeInNodes:(NSArray *)nodes;
#endif
@end

@implementation SUAppcast

- (void)dealloc
{
	[items release];
	items = nil;
	[userAgentString release];
	userAgentString = nil;
	[downloadData release];
	downloadData = nil;
	[downloadConnection release];
	downloadConnection = nil;
	
	[super dealloc];
}

- (NSArray *)items
{
	return items;
}

- (void)fetchAppcastFromURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    if (userAgentString)
        [request setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
    
    [downloadData release];
    downloadData = nil;
    
    [downloadConnection release];
    downloadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [downloadData release];
  downloadData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [downloadData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  [downloadConnection release];
  downloadConnection = nil;
  
	NSError *error = nil;
	
	SUAppcastXMLParser *xmlParser = nil;
	BOOL failed = NO;
	NSArray *xmlItems = nil;
	NSMutableArray *appcastItems = [NSMutableArray array];
	
	if (downloadData)
	{
    xmlParser = [[[SUAppcastXMLParser alloc] initWithData:downloadData] autorelease];
    
		[downloadData release];
		downloadData = nil;
	}
	else
	{
		failed = YES;
	}
#ifndef SHIMMER_REFACTOR
    if (nil == xmlParser)
    {
        failed = YES;
    }
    else
    {
        xmlItems = [xmlParser nodesForXPath:@"/rss/channel/item" error:&error];
        if (nil == xmlItems)
        {
            failed = YES;
        }
    }
    
	if (failed == NO)
    {
		
		NSEnumerator *nodeEnum = [xmlItems objectEnumerator];
		NSXMLNode *node;
		NSMutableDictionary *nodesDict = [NSMutableDictionary dictionary];
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		while (failed == NO && (node = [nodeEnum nextObject]))
        {
			// First, we'll "index" all the first-level children of this appcast item so we can pick them out by language later.
            if ([[node children] count])
            {
                node = [node childAtIndex:0];
                while (nil != node)
                {
                    NSString *name = [node name];
                    if (name)
                    {
                        NSMutableArray *nodes = [nodesDict objectForKey:name];
                        if (nodes == nil)
                        {
                            nodes = [NSMutableArray array];
                            [nodesDict setObject:nodes forKey:name];
                        }
                        [nodes addObject:node];
                    }
                    node = [node nextSibling];
                }
            }
            
            NSEnumerator *nameEnum = [nodesDict keyEnumerator];
            NSString *name;
            while ((name = [nameEnum nextObject]))
            {
                node = [self bestNodeInNodes:[nodesDict objectForKey:name]];
				if ([name isEqualToString:@"enclosure"])
				{
					// enclosure is flattened as a separate dictionary for some reason
					NSDictionary *encDict = [(NSXMLElement *)node attributesAsDictionary];
					[dict setObject:encDict forKey:@"enclosure"];
					
				}
                else if ([name isEqualToString:@"pubDate"])
                {
					// pubDate is expected to be an NSDate by SUAppcastItem, but the RSS class was returning an NSString
					NSDate *date = [NSDate dateWithNaturalLanguageString:[node stringValue]];
					if (date)
						[dict setObject:date forKey:name];
				}
				else if ([name isEqualToString:@"sparkle:deltas"])
				{
					NSMutableArray *deltas = [NSMutableArray array];
					NSEnumerator *childEnum = [[node children] objectEnumerator];
					NSXMLNode *child;
					while ((child = [childEnum nextObject])) {
						if ([[child name] isEqualToString:@"enclosure"])
							[deltas addObject:[(NSXMLElement *)child attributesAsDictionary]];
					}
					[dict setObject:deltas forKey:@"deltas"];
				}
				else if (name != nil)
				{
					// add all other values as strings
					[dict setObject:[[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:name];
				}
            }
            
			NSString *errString;
			SUAppcastItem *anItem = [[[SUAppcastItem alloc] initWithDictionary:dict failureReason:&errString] autorelease];
            if (anItem)
            {
                [appcastItems addObject:anItem];
			}
            else
            {
				SULog(@"Sparkle Updater: Failed to parse appcast item: %@.\nAppcast dictionary was: %@", errString, dict);
            }
            [nodesDict removeAllObjects];
            [dict removeAllObjects];
		}
	}
	
	if ([appcastItems count])
    {
		NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
		[appcastItems sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		items = [appcastItems copy];
	}
	
	if (failed)
    {
        [self reportError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUAppcastParseError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:SULocalizedString(@"An error occurred while parsing the update feed.", nil), NSLocalizedDescriptionKey, nil]]];
	}
    else if ([delegate respondsToSelector:@selector(appcastDidFinishLoading:)])
    {
        [delegate appcastDidFinishLoading:self];
	}
#endif
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  [downloadData release];
  downloadData = nil;
  
  [downloadConnection release];
  downloadConnection = nil;
    
	[self reportError:error];
}

- (void)reportError:(NSError *)error
{
	if ([delegate respondsToSelector:@selector(appcast:failedToLoadWithError:)])
	{
		[delegate appcast:self failedToLoadWithError:[NSError errorWithDomain:SUSparkleErrorDomain code:SUAppcastError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:SULocalizedString(@"An error occurred in retrieving update information. Please try again later.", nil), NSLocalizedDescriptionKey, [error localizedDescription], NSLocalizedFailureReasonErrorKey, nil]]];
	}
}

#ifndef SHIMMER_REFACTOR
- (NSXMLNode *)bestNodeInNodes:(NSArray *)nodes
{
	// We use this method to pick out the localized version of a node when one's available.
    if ([nodes count] == 1)
        return [nodes objectAtIndex:0];
    else if ([nodes count] == 0)
        return nil;
    
    NSEnumerator *nodeEnum = [nodes objectEnumerator];
    NSXMLElement *node;
    NSMutableArray *languages = [NSMutableArray array];
    NSString *lang;
    NSUInteger i;
    while ((node = [nodeEnum nextObject]))
    {
        lang = [[node attributeForName:@"xml:lang"] stringValue];
        [languages addObject:(lang ? lang : @"")];
    }
    lang = [[NSBundle preferredLocalizationsFromArray:languages] objectAtIndex:0];
    i = [languages indexOfObject:([languages containsObject:lang] ? lang : @"")];
    if (i == NSNotFound)
        i = 0;
    return [nodes objectAtIndex:i];
}
#endif

- (void)setUserAgentString:(NSString *)uas
{
	if (uas != userAgentString)
	{
		[userAgentString release];
		userAgentString = [uas copy];
	}
}

- (void)setDelegate:del
{
	delegate = del;
}

@end
