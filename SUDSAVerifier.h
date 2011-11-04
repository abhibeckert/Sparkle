//
//  SUDSAVerifier.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/16/06.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#ifndef SUDSAVERIFIER_H
#define SUDSAVERIFIER_H

#import <UIKit/UIKit.h>

// For the paranoid folks!
@interface SUDSAVerifier : NSObject {}
+ (BOOL)validatePath:(NSString *)path withEncodedDSASignature:(NSString *)encodedSignature withPublicDSAKey:(NSString *)pkeyString;
@end

#endif
