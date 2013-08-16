//
//  AppDelegate.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/07/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPMGlobalData.h"
#import <Quartz/Quartz.h>

@class PropertyView;
@class MainWindowController;

@class TitleBarView;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MainWindowController *mainWindowController;
    //TEST AREA
    BPMDirectory *testDir;
}
@property (assign) IBOutlet NSWindow *window;
@end
