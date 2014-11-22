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

    //    NSString *logRawLine = @"www.lordandrei.com 173.75.40.109 - - 18/Nov/2014 22:52:56 -0500 \"GET /blog/wp-admin/load-scripts.php?c=1&load%5B%5D=jquery-core,jquery-migrate,utils,jquery-ui-core,jquery-ui-widget,jquery-ui-mouse,jquery-ui-resizable,jquery-ui-draggable,jquery-&load%5B%5D=ui-button,jquery-ui-position,jquery-ui-dialog&ver=3.8.1 HTTP/1.1\" 200 61374 \"http://www.lordandrei.com/blog/wp-admin/edit.php\" \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25\" 1645 61837 /Library/Server/Web/Data/Sites/lordandrei/blog/wp-admin/load-scripts.php";
    
//    LogLine* aLogLine = [LogLine LogLineFromParsableLine:logRawLine];
//    NSLog(@"aLogLine: %@", aLogLine);
//    [aLogLine printInstanceData];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
