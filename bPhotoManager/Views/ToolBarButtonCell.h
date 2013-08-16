//
//  ToolBarButtonCell.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToolBarButtonCell : NSButtonCell{
    NSMutableArray *colorArray;
    NSGradient *gradient;
    NSBezierPath *path;
    NSShadow *theShadow;
}

@end
