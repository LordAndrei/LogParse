//
//  LogLine.m
//  LogParse
//
//  Created by Andrei Freeman on 11/21/14.
//  Copyright (c) 2014 LordAndrei.com. All rights reserved.
//

#import "LogLine.h"

static NSDateFormatter *dateInFormatter;
static NSDateFormatter *dateOutFormatter;
static NSDateFormatter *dateReportFormatter;
static NSUInteger logLineCounter;

NSString *kLogLineConst = @"HTTP/";
NSString *kBasePath = @"/Library/Server/Web/Data/Sites/lordandrei";

@interface LogLine ()
#pragma mark Properties
@property (strong, nonatomic) NSString *rawLine; // parsableLine;
@property (strong, nonatomic) NSArray *parsedArray; // parsedArray from rawLine;
@property (nonatomic) NSUInteger recIdx; // AutoInc
@property (strong, nonatomic) NSString* ipAddr; // #1
@property (strong, nonatomic) NSDate *timeStamp; // 4 + 5 + 6
@property (strong, nonatomic) NSString *cmdHttp; // 7
@property (strong, nonatomic) NSURL *urlPath; // 8 as per below
@property (strong, nonatomic) NSString *httpVer; // 9 - "^HTTP/" // 1.0 | 1.1
@property (nonatomic) NSUInteger returnCode; // 10
@property (nonatomic) NSInteger dataSize; // 11 : -1 for none, 0 for 0
@property (strong, nonatomic) NSURL *urlRefer; // 12
@property (strong, nonatomic) NSString *userAgent; // 14
@property (strong, nonatomic) NSString *resource; // 17

@end

@implementation LogLine

#pragma mark Initialisers

//////////////////////////////////////////////////////
// + (void) initialize
//////////////////////////////////////////////////////

+ (void) initialize
{
    dateInFormatter = [[NSDateFormatter alloc] init];
    dateOutFormatter = [[NSDateFormatter alloc] init];
    dateReportFormatter = [[NSDateFormatter alloc] init];
    dateInFormatter.dateFormat = @"dd/MMM/yyyy HH:mm:ss Z";
    dateOutFormatter.dateFormat = @"yyyy.MM.dd..HH.mm.ss v";
    dateReportFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss Z";
    logLineCounter = 0;
    
}


//////////////////////////////////////////////////////
// + (LogLine*) LogLineFromParsableLine:(NSString*) parsableLine
//////////////////////////////////////////////////////

+ (LogLine*) LogLineFromParsableLine:(NSString*) parsableLine
{
    return [[self alloc] initWithParsableLine:parsableLine];
}

//////////////////////////////////////////////////////
// - (id) initWithParsableLine:(NSString*) parsableLine
//////////////////////////////////////////////////////

- (id) initWithParsableLine:(NSString*) parsableLine
{
    if (self = [self init]) {
        self.rawLine = parsableLine;
        if (self.parse != YES) {
            return nil;
        }
    }
    return self;
}

//////////////////////////////////////////////////////
// - (id) init
//////////////////////////////////////////////////////

- (id) init
{
    if (self = [super init]) {
        self.returnCode = 0;
    }
    return self;
}

#pragma mark -
#pragma mark KeyPaths


//////////////////////////////////////////////////////
// - (NSArray *) keyPaths
//////////////////////////////////////////////////////

- (NSArray *)keyPaths
{
    NSArray *result = [NSArray arrayWithObjects:
//                       @"rawLine",
//                       @"parsedArray",
                       @"recIdx",
                       @"ipAddr",
                       @"timeStamp",
                       @"cmdHttp",
                       @"urlPath",
                       @"httpVer",
                       @"returnCode",
                       @"dataSize",
                       @"urlRefer",
                       @"userAgent",
                       @"resource",
                       nil];
    
    return result;
}

//////////////////////////////////////////////////////
// - (NSString *) descriptionForKeyPaths
//////////////////////////////////////////////////////

- (NSString *)descriptionForKeyPaths
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"\n\n"];
    [desc appendFormat:@"Class name: %@\n", NSStringFromClass([self class])];
    
    NSArray *keyPathsArray = [self keyPaths];
    for (NSString *keyPath in keyPathsArray) {
        if ([keyPath isEqualToString:@"timeStamp"]) {
            [desc appendString:@"timeStamp: "];
            [desc appendString:[dateOutFormatter stringFromDate:self.timeStamp]];
            [desc appendString:@"\n"];
//            [desc appendFormat:@"timeStamp: %@\n", [dateOutFormatter stringFromDate:self.timeStamp]];
        } else {
            [desc appendFormat: @"%@: %@\n", keyPath, [self valueForKey:keyPath]];
        }
    }
    
    return [NSString stringWithString:desc];
}

//////////////////////////////////////////////////////
// - (NSString *) description
//////////////////////////////////////////////////////

- (NSString *)description
{
    return [self descriptionForKeyPaths];
}

#pragma mark -
#pragma mark File Display

- (void) printInstanceData
{
    NSLog(@"%@", [self getInstanceData]);
}

+ (NSString*) getInstanceDataHeader
{
    return @"Idx\tTS\tRC\tIP\tRES";
}

- (NSString*) getInstanceData;
{
    NSMutableString *displayString = [NSMutableString stringWithCapacity:255];
    [displayString appendFormat:@"%05lu", (unsigned long)self.recIdx];
    [displayString appendString:@"\t"];
    [displayString appendString:[dateReportFormatter stringFromDate:self.timeStamp]];
    [displayString appendString:@"\t"];
    [displayString appendFormat:@"%lu", (unsigned long)self.returnCode];
    [displayString appendString:@"\t"];
    
    NSString *loadedIP = self.ipAddr;
    if (loadedIP == nil) {
        loadedIP = @" ";
    }
    [displayString appendString:loadedIP];
    [displayString appendString:@"\t"];
    
    NSString *loadedRes = self.resource;
    if (loadedRes == nil) {
        loadedRes = @" ";
    }
    [displayString appendString:loadedRes];
    
    return displayString.copy;
}

#pragma mark -
#pragma mark Parsers

- (BOOL) parseParsableLine
{
    self.parsedArray = [LogLine parseParsableLine:self.rawLine];
    return YES;
}

- (BOOL) parseParsedArray
{
    BOOL didSucceed = YES;

    if (self.parsedArray.count < 15) {
        didSucceed = NO;
        return didSucceed;
    }
    
    self.recIdx = logLineCounter;
    if (logLineCounter == 74618) {
        NSLog(@"Hitting Breakpoint");
    }
    self.ipAddr = self.parsedArray[1];
    NSString *timeStamp = [NSString stringWithFormat:@"%@ %@ %@",
                           self.parsedArray[4],
                           self.parsedArray[5],
                           self.parsedArray[6]];
    self.timeStamp = [dateInFormatter dateFromString:timeStamp];
    self.cmdHttp = self.parsedArray[7];
    if ([self.cmdHttp isEqualToString:@"-"]) {
        self.returnCode += ((NSString*) self.parsedArray[8]).integerValue;
        return didSucceed;
    }
    self.urlPath = [self parseURL:self.parsedArray[8]];
    
    NSString *rawHttpVer = self.parsedArray[9];
    if (rawHttpVer.length > kLogLineConst.length) {
        self.httpVer = [rawHttpVer substringFromIndex:kLogLineConst.length];
    } else {
        didSucceed = NO;
        return didSucceed;
    }
    
    self.returnCode += ((NSString*) self.parsedArray[10]).integerValue;
    
    NSString *rawDataSize = self.parsedArray[11];
    NSInteger dataSize = -1;
    if (![rawDataSize isEqualToString:@"-"]) {
        dataSize = rawDataSize.integerValue;
    }
    
    self.dataSize = dataSize;
    NSString *referringURL = self.parsedArray[12];
    if (referringURL.length > 5) {
        self.urlRefer = [NSURL URLWithString:referringURL];
    }
    
    self.userAgent = self.parsedArray[14];
    
    NSString *rawResource = self.parsedArray[17];
    if (rawResource.length > kBasePath.length) {
        self.resource = [rawResource substringFromIndex:kBasePath.length];
    } else {
        didSucceed = NO;
        return didSucceed;
    }
    
    if (didSucceed == YES) {
        logLineCounter++;
    }
    return didSucceed;
}

- (BOOL) parse
{
    BOOL didSucceed = YES;
    didSucceed &= [self parseParsableLine];
    if (didSucceed) {
        [self parseParsedArray];
    }
    return didSucceed;
}



- (NSURL*) parseURL:(NSString*) aPath {
    
    NSURL *aURL = nil;
    
    @try {
        aURL = [[NSURL alloc] initWithScheme:@"http"
                                        host:@"www.lordandrei.com"
                                        path:aPath];

    }
    @catch (NSException *exception) {
        self.returnCode +=9000;
        NSLog(@"\nBAD URL\n%@", self.rawLine);
        NSLog(@"\nException: %@\n", exception);
        if ([exception.name isEqualToString:NSInvalidArgumentException]) {
            aURL = nil;
        } else {
            self.returnCode += 90000;
        }
    }
    
    if (aURL == nil) {
        @try {
            aURL = [NSURL URLWithString:aPath];
        }
        @catch (NSException *exception) {
            self.returnCode += 900000;
            NSLog(@"\nException: %@\n", exception);
            aURL = nil;
        }
    }
/*
    if (aPath.length > 4) {
        NSString* substring = [aPath substringToIndex:4];
        if ([substring isEqualToString:@"http"]) {
            aURL = [NSURL URLWithString:aPath];
        }
    }
    
    if (aURL == nil) {
        aURL = [[NSURL alloc] initWithScheme:@"http"
                                        host:@"www.lordandrei.com"
                                        path:aPath];
    }
  */  
    return aURL;

}

#pragma mark -
#pragma mark Class Mutation Utilities

+ (NSArray*) parseParsableLine:(NSString*) parsableLine
{
    /*
     * 1) Separate line on quote marks
     * 2) Walk array removing initial and final spacing first
     * 3) Create new MutableArray
     * 4) First 5 lines Seperate lines on space; push results onto new array
     * 5) Push line 6 (userAgent) onto new array
     * 6) 7th line seperate on space and push onto new array
     */
    
    // 1) Separate line on quote marks
    NSArray *initialSplit = [parsableLine componentsSeparatedByString:@"\""];
    
    // 2) Walk array removing initial and final spacing first
    NSMutableArray *trimmedArray = [NSMutableArray arrayWithCapacity:initialSplit.count];
    for (NSString *aLine in initialSplit) {
        NSArray *deSpacingArray = [aLine componentsSeparatedByString:@" "];
        if (deSpacingArray.count == 1) {
            [trimmedArray addObject:aLine];
            continue;
        }
        
        if (((NSString*)deSpacingArray[0]).length == 0) {
            deSpacingArray = [deSpacingArray subarrayWithRange:NSMakeRange(1, deSpacingArray.count - 1)];
        }
        
        if (((NSString*)deSpacingArray.lastObject).length == 0) {
            deSpacingArray = [deSpacingArray subarrayWithRange:NSMakeRange(0, deSpacingArray.count - 1)];
        }
        
        NSString *deSpacedLine = [deSpacingArray componentsJoinedByString:@" "];
        
        [trimmedArray addObject:deSpacedLine];
    }
    
    // 3) Create new MutableArray
    NSMutableArray *finalParsedArray = [NSMutableArray arrayWithCapacity:20];
    
    // 4) First 5 lines Seperate lines on space; push results onto new array
    for (NSUInteger counter = 0; counter < 5; counter++) {
        NSArray *miniParse = [((NSString*)trimmedArray[counter]) componentsSeparatedByString:@" "];
        [finalParsedArray addObjectsFromArray:miniParse];
    }
    
    [finalParsedArray addObject:trimmedArray[5]];
    [finalParsedArray addObjectsFromArray:[((NSString*)trimmedArray.lastObject) componentsSeparatedByString:@" "]];
    
    return finalParsedArray.copy;
    
}

@end
