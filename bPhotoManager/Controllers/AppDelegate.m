//
//  AppDelegate.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/07/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [mainWindowController showWindow:self];
    
    NSLog(@"app did finish lanching");
}


@end
