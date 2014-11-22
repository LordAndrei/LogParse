//
//  LogLine.h
//  LogParse
//
//  Created by Andrei Freeman on 11/21/14.
//  Copyright (c) 2014 LordAndrei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogLine : NSObject

@property (readonly) NSUInteger recIdx; // AutoInc

+ (LogLine*) LogLineFromParsableLine:(NSString*) parsableLine;
- (id) initWithParsableLine:(NSString*) parsableLine;

- (void) printInstanceData;
- (NSString*) getInstanceData;
+ (NSString*) getInstanceDataHeader;

@end
