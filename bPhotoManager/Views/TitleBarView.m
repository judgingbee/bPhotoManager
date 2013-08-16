//
//  TitleBarView.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TitleBarView.h"

@implementation TitleBarView

@synthesize title;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        colorArray = [[NSMutableArray alloc] init];
        [colorArray addObject:[NSColor colorWithDeviceWhite:0.3 alpha:1]];
        [colorArray addObject:[NSColor colorWithDeviceWhite:0.1 alpha:1]];
        [colorArray addObject:[NSColor colorWithDeviceWhite:0.3 alpha:1]];
        gradient = [[NSGradient alloc] initWithColors:colorArray];
        
        attr = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:15], NSFontAttributeName, 
                [NSColor colorWithDeviceWhite:0.8 alpha:1], NSForegroundColorAttributeName,
                nil];
        [attr retain];
        
        theShadow = [[NSShadow alloc] init];
        [theShadow setShadowOffset:NSMakeSize(0.0, 0.0)];
        [theShadow setShadowBlurRadius:12.0];
        
        // Use a partially transparent color for shapes that overlap.
        [theShadow setShadowColor:[[NSColor whiteColor]
                                   colorWithAlphaComponent:0.9]];
        
        [self setTitle:@"iPhoto"];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    
//    [[NSColor darkGrayColor] set]; 
//    NSRectFill(dirtyRect); 
    
    [gradient drawInRect:dirtyRect angle:270.0];
    [self drawTitle];
}

- (void) drawTitle
{
    [theShadow set];
    int w = self.bounds.size.width - [title sizeWithAttributes:attr].width;
    int h = self.bounds.size.height - [title sizeWithAttributes:attr].height;
    NSPoint pos = {w/2, h/2};
    [title drawAtPoint:pos withAttributes:attr];
}
@end
