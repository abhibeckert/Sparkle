//
//  SUAppcastXMLParser.m
//  Sparkle
//
//  Created by Abhi Beckert on 2011-11-03.
//  Copyright (c) Abhi Beckert. All rights reserved.
//

#import "SUAppcastXMLParser.h"
#import "SULog.h"

@implementation SUAppcastXMLParser

- (id)initWithData:(NSData *)data
{
  if (!(self = [super init]))
    return nil;
  
  items = [[NSMutableArray alloc] init];
  
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
  parser.delegate = self;
  [parser parse];
  [parser release];
  
  return self;
}

- (void)dealloc
{
  [items release];
  items = nil;
  [currentItem release];
  
  [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributes
{
  if ([elementName isEqualToString:@"item"]) {
    [currentItem release];
    currentItem = [[NSMutableDictionary alloc] init];
    return;
  }
  
  if (!currentItem)
    return;
  
  if ([[NSArray arrayWithObjects:@"title", @"description", nil] containsObject:elementName]) {
    [currentStringValue release];
    currentStringValue = [[NSMutableString alloc] init];
    return;
  }
  
  SULog(@"startElement %@ %@", elementName, attributes);
//  
//  if ([elementName isEqualToString:@"way"]) {
//    [mapParserCurrentWay release], mapParserCurrentWay = nil;
//    mapParserCurrentWay = [[NSMutableDictionary alloc] initWithCapacity:2];
//    [mapParserCurrentWay setValue:[NSMutableArray array] forKey:@"nodes"];
//    return;
//  }
//  
//  if (mapParserCurrentWay && [elementName isEqualToString:@"nd"]) {
//    NSMutableArray *nodes = [mapParserCurrentWay valueForKey:@"nodes"];
//    NSDictionary *node = [mapNodes valueForKey:[attributes valueForKey:@"ref"]];
//    if (node)
//      [nodes addObject:node];
//    return;
//  }
//  
//  if (mapParserCurrentWay && [elementName isEqualToString:@"tag"]) {
//    if ([[attributes valueForKey:@"k"] isEqualToString:@"highway"])
//      [mapParserCurrentWay setValue:[attributes valueForKey:@"v"] forKey:[attributes valueForKey:@"k"]];
//    return;
//  }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
  if (!currentItem)
    return;
  
  if ([elementName isEqualToString:@"item"]) {
    [items addObject:[[currentItem copy] autorelease]];
    NSLog(@"added item %@", currentItem);
    [currentItem release];
    currentItem = nil;
    return;
  }
  
  if ([[NSArray arrayWithObjects:@"title", @"description", nil] containsObject:elementName]) {
    [currentItem setValue:[[currentStringValue copy] autorelease]  forKey:elementName];
    return;
  }
  
  SULog(@"end element %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  if (!currentStringValue) {
      // currentStringValue is an NSMutableString instance variable
      currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
  }
  [currentStringValue appendString:string];
}

@end
