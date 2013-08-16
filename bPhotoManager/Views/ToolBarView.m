//
//  ToolBarView.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/07/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ToolBarView.h"
#import <AppKit/NSGraphics.h>

@implementation ToolBarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSArray *colorArray = [[[NSArray alloc] initWithObjects:
                              [NSColor colorWithDeviceWhite:0.9 alpha:1],
                              [NSColor colorWithDeviceWhite:0.5 alpha:1],
                              nil] autorelease];
        gradient = [[NSGradient alloc] initWithColors:colorArray];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [gradient drawInRect:[self bounds] angle:270.0];
}

@end
