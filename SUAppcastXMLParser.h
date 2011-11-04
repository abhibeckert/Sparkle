//
//  SUAppcastXMLParser.h
//  Sparkle
//
//  Created by Abhi Beckert on 2011-11-03.
//  Copyright (c) Abhi Beckert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SUAppcastXMLParser : NSObject <NSXMLParserDelegate>
{
  NSMutableArray *items;
  NSMutableDictionary *currentItem;
  NSMutableString *currentStringValue;
}

- (id)initWithData:(NSData *)data;

@end
