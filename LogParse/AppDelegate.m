//
//  AppDelegate.m
//  LogParse
//
//  Created by Andrei Freeman on 11/21/14.
//  Copyright (c) 2014 LordAndrei.com. All rights reserved.
//

#import "AppDelegate.h"
#import "LogLine.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    NSMutableString *buildString = [NSMutableString string];
    [buildString appendString:[LogLine getInstanceDataHeader]];
    [buildString appendString:@"\n"];
    
    NSError *anError = nil;
    NSString *fileAccess = [NSString stringWithContentsOfFile:@"/Users/lordandrei/Documents/Apolo/logs/access_log.1415836800"
                                                     encoding:NSUTF8StringEncoding
                                                        error:&anError];
    NSArray *arrayRawLogLines = [fileAccess componentsSeparatedByString:@"\n"];
    NSLog(@"Located %lu entries\n\n", (unsigned long)arrayRawLogLines.count);

    for (NSString *rawLogLine in arrayRawLogLines) {
        LogLine *aLogLine = [LogLine LogLineFromParsableLine:rawLogLine];
        if (aLogLine.recIdx % 5000 == 0) {
            [aLogLine printInstanceData];
        }
        [buildString appendString:[aLogLine getInstanceData]];
        [buildString appendString:@"\n"];
    }
    
    NSLog(@"\n\nSaving...");
    [buildString writeToFile:@"/Users/lordandrei/Documents/Apolo/logs/access_log.1415836800.rep.txt"
                  atomically:NO
                    encoding:NSUTF8StringEncoding
                       error:&anError];
    NSLog(@"\n\nSaved");
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
