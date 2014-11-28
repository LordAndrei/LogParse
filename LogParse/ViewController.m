//
//  ViewController.m
//  LogParse
//
//  Created by Andrei Freeman on 11/21/14.
//  Copyright (c) 2014 LordAndrei.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet NSTextField *countProcess;
@property (weak) IBOutlet NSTextField *countError;
@property (weak) IBOutlet NSPathControl *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
