//
//  SUInstaller.m
//  Sparkle
//
//  Created by Andy Matuschak on 4/10/08.
//  Copyright Andy Matuschak, Abhi Beckert. All rights reserved.
//

#import "SUInstaller.h"
#import "SUPlainInstaller.h"
#import "SUPackageInstaller.h"
#import "SUHost.h"
#import "SUConstants.h"
#import "SULog.h"


@implementation SUInstaller

static NSString*	sUpdateFolder = nil;

+(NSString*)	updateFolder
{
	return sUpdateFolder;
}

+ (BOOL)isAliasFolderAtPath:(NSString *)path
{
#ifndef SHIMMER_REFACTOR
	FSRef fileRef;
	OSStatus err = noErr;
	Boolean aliasFileFlag, folderFlag;
	NSURL *fileURL = [NSURL fileURLWithPath:path];
	
	if (FALSE == CFURLGetFSRef((CFURLRef)fileURL, &fileRef))
		err = coreFoundationUnknownErr;
	
	if (noErr == err)
		err = FSIsAliasFile(&fileRef, &aliasFileFlag, &folderFlag);
	
	if (noErr == err)
		return (BOOL)(aliasFileFlag && folderFlag);
	else
		return NO;	
#else
  return NO;
#endif
}


+ (void)installFromUpdateFolder:(NSString *)inUpdateFolder overHost:(SUHost *)host delegate:delegate synchronously:(BOOL)synchronously versionComparator:(id <SUVersionComparison>)comparator
{
	// Search subdirectories for the application
	NSString	*currentFile,
				*newAppDownloadPath = nil,
				*bundleFileName = [[host bundlePath] lastPathComponent],
				*alternateBundleFileName = [[host name] stringByAppendingPathExtension:[[host bundlePath] pathExtension]];
	BOOL isPackage = NO;
	NSString *fallbackPackagePath = nil;
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: inUpdateFolder];
	
	[sUpdateFolder release];
	sUpdateFolder = [inUpdateFolder retain];
	
	while ((currentFile = [dirEnum nextObject]))
	{
		NSString *currentPath = [inUpdateFolder stringByAppendingPathComponent:currentFile];		
		if ([[currentFile lastPathComponent] isEqualToString:bundleFileName] ||
			[[currentFile lastPathComponent] isEqualToString:alternateBundleFileName]) // We found one!
		{
			isPackage = NO;
			newAppDownloadPath = currentPath;
			break;
		}
		else if ([[currentFile pathExtension] isEqualToString:@"pkg"] ||
				 [[currentFile pathExtension] isEqualToString:@"mpkg"])
		{
			if ([[[currentFile lastPathComponent] stringByDeletingPathExtension] isEqualToString:[bundleFileName stringByDeletingPathExtension]])
			{
				isPackage = YES;
				newAppDownloadPath = currentPath;
				break;
			}
			else
			{
				// Remember any other non-matching packages we have seen should we need to use one of them as a fallback.
				fallbackPackagePath = currentPath;
			}
		}
		else
		{
			// Try matching on bundle identifiers in case the user has changed the name of the host app
			NSBundle *incomingBundle = [NSBundle bundleWithPath:currentPath];
			if(incomingBundle && [[incomingBundle bundleIdentifier] isEqualToString:[[host bundle] bundleIdentifier]])
			{
				isPackage = NO;
				newAppDownloadPath = currentPath;
				break;
			}
		}
		
		// Some DMGs have symlinks into /Applications! That's no good!
		if ([self isAliasFolderAtPath:currentPath])
			[dirEnum skipDescendents];
	}
	
	// We don't have a valid path. Try to use the fallback package.

	if (newAppDownloadPath == nil && fallbackPackagePath != nil)
	{
		isPackage = YES;
		newAppDownloadPath = fallbackPackagePath;
	}
	
	if (newAppDownloadPath == nil)
	{
		[self finishInstallationWithResult:NO host:host error:[NSError errorWithDomain:SUSparkleErrorDomain code:SUMissingUpdateError userInfo:[NSDictionary dictionaryWithObject:@"Couldn't find an appropriate update in the downloaded package." forKey:NSLocalizedDescriptionKey]] delegate:delegate];
	}
	else
	{
		[(isPackage ? [SUPackageInstaller class] : [SUPlainInstaller class]) performInstallationWithPath:newAppDownloadPath host:host delegate:delegate synchronously:synchronously versionComparator:comparator];
	}
}

+ (void)mdimportHost:(SUHost *)host
{
	// *** GETS CALLED ON NON-MAIN THREAD!
	
	SULog( @"mdimporting" );
#ifndef SHIMMER_REFACTOR
	NSTask *mdimport = [[[NSTask alloc] init] autorelease];
	[mdimport setLaunchPath:@"/usr/bin/mdimport"];
	[mdimport setArguments:[NSArray arrayWithObject:[host installationPath]]];
	@try
	{
		[mdimport launch];
		[mdimport waitUntilExit];
	}
	@catch (NSException * launchException)
	{
		// No big deal.
		SULog(@"Sparkle Error: %@", [launchException description]);
	}
#endif
}


#define		SUNotifyDictHostKey		@"SUNotifyDictHost"
#define		SUNotifyDictErrorKey	@"SUNotifyDictError"
#define		SUNotifyDictDelegateKey	@"SUNotifyDictDelegate"

+ (void)finishInstallationWithResult:(BOOL)result host:(SUHost *)host error:(NSError *)error delegate:delegate
{
	if (result)
	{
		[self mdimportHost:host];
		if ([delegate respondsToSelector:@selector(installerFinishedForHost:)])
			[delegate performSelectorOnMainThread: @selector(installerFinishedForHost:) withObject: host waitUntilDone: NO];
	}
	else
	{
		if ([delegate respondsToSelector:@selector(installerForHost:failedWithError:)])
			[self performSelectorOnMainThread: @selector(notifyDelegateOfFailure:) withObject: [NSDictionary dictionaryWithObjectsAndKeys: host, SUNotifyDictHostKey, error, SUNotifyDictErrorKey, delegate, SUNotifyDictDelegateKey, nil] waitUntilDone: NO];
	}		
}


+(void)	notifyDelegateOfFailure: (NSDictionary*)dict
{
	[[dict objectForKey: SUNotifyDictDelegateKey] installerForHost: [dict objectForKey: SUNotifyDictHostKey] failedWithError: [dict objectForKey: SUNotifyDictErrorKey]];
}

@end
