//
//  MainWindowController.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPMGlobalData.h"
#import <Quartz/Quartz.h>
#import "NaviItems.h"
#import "PropertyView.h"
@class TitleBarView;
@class PropertyView;
@class SeparatorCell;
@class ImageBrowserView;

@interface MainWindowController : NSWindowController{
    MainWindowController *mainWindowController;
    CGFloat                     naviWidth;
    IBOutlet NSSplitView        *splitView;
    IBOutlet NSOutlineView      *outlineView;
    IBOutlet ImageBrowserView   *browerView;
    IBOutlet TitleBarView       *titleView;
    IBOutlet PropertyView       *propertyView;
    IBOutlet NSSlider           *slider;
    
    
	SeparatorCell				*separatorCell;	// the cell used to draw a separator line in the outline view
    NSMutableDictionary         *placesBuffer;
    NSMutableArray              *naviItems;
    NaviItem                    *favouriteItems;
    NaviItem                    *albumItems;
    NaviItem                    *explorerItems;
    
    //TEST AREA
    BPMDirectory                *testDir;
}


- (IBAction)showProperty:(id)sender;
- (IBAction)setBrowserZoom:(id)sender;
- (void) loadNavigatorItems;

//TEST AREA
- (IBAction)test1Action:(id)sender;
- (IBAction)test2Action:(id)sender;

@end
