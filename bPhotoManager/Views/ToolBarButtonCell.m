//
//  ToolBarButtonCell.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ToolBarButtonCell.h"

@implementation ToolBarButtonCell

- (void) awakeFromNib
{
//    [self prepareDrawing];
    [self setBordered:NO];
}


- (void) prepareDrawingWithColor1:(NSColor *)c1 Color2:(NSColor *)c2 
{
    // Initialization code here.
    colorArray = [[NSMutableArray alloc] init];
    [colorArray addObject:c1];
    [colorArray addObject:c2];
    gradient = [[NSGradient alloc] initWithColors:colorArray];
//    [gradient retain];
    
    //        line = [NSBezierPath bezierPath];
//    path = [[NSBezierPath alloc] init];
//    [path retain];
//    NSRect r = [[self controlView] bounds];
//    r.origin.x += 4;
//    r.origin.y += 4;
//    r.size.height -= 8;
//    r.size.width -= 8;
//    [path appendBezierPathWithRoundedRect: r xRadius:5 yRadius:5]; 
//    [path closePath];
    
//    NSLog(@"prepared drawing");
}



- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    // other stuff might happen here
//    [super drawWithFrame:cellFrame inView:controlView];
    
//    if ([self showsFirstResponder]) {
//        // showsFirstResponder is set for us by the NSControl that is drawing  us.
//        NSRect focusRingFrame = cellFrame;
//        focusRingFrame.size.height -= 2.0;
//        [NSGraphicsContext saveGraphicsState];
//        NSSetFocusRingStyle(NSFocusRingOnly);
//        [[NSBezierPath bezierPathWithRect: NSInsetRect(focusRingFrame,4,4)] fill];
//        [NSGraphicsContext restoreGraphicsState];
//    }
    // other stuff might happen here
    
//    NSLog(@"cell drawWithFrame");
    
    
    path = [NSBezierPath bezierPath];
    NSRect rect = [controlView bounds];
//    [[NSColor clearColor] set]; 
//    [[NSColor colorWithDeviceRed:0.5059 green:0.7451 blue:0.1961 alpha:0.5] set];
//    
//    NSRectFill([controlView bounds]); 
    
    [self prepareDrawingWithColor1:[NSColor colorWithDeviceWhite:0.9 alpha:1] 
                            Color2:[NSColor colorWithDeviceWhite:0.5 alpha:1]];
    [path appendBezierPathWithRect:[controlView bounds]];
    [gradient drawInBezierPath:path angle:90];
    
    [path removeAllPoints];
    rect.origin.x += 3;
    rect.origin.y += 3;
    rect.size.height -= 6;
    rect.size.width -= 6;
    [path appendBezierPathWithRoundedRect: rect xRadius:3 yRadius:3]; 
    
    if ([self state] == NSOnState) {
        [NSGraphicsContext saveGraphicsState];
        
        // Create the shadow below and to the right of the shape.
        theShadow = [[NSShadow alloc] init];
        [theShadow setShadowOffset:NSMakeSize(1.0, -1.0)];
        [theShadow setShadowBlurRadius:1.0];
        
        // Use a partially transparent color for shapes that overlap.
        [theShadow setShadowColor:[[NSColor whiteColor]
                                   colorWithAlphaComponent:0.2]];
        
        [theShadow set];
        
        
        [self prepareDrawingWithColor1:[NSColor grayColor] Color2:[NSColor grayColor]];
        [[NSColor darkGrayColor] set];
        [path setLineWidth:2.0];
        [path stroke];
        [gradient drawInBezierPath:path angle:90];
        
        [NSGraphicsContext restoreGraphicsState];
        [theShadow release];
    } else {
//        [self prepareDrawingWithColor1:[NSColor colorWithDeviceWhite:0.9 alpha:1] 
//                                Color2:[NSColor colorWithDeviceWhite:0.5 alpha:1]];
    }
    
    [[[self controlView] superview] setNeedsDisplay:YES];
//    
//    if([self isEnabled])  
//    {     
//        // draw inner part of button first 
//        // 画button的灰色渐变部分 
//        NSLog(@"draw gradient");
//        [gradient drawInBezierPath:path angle:90.0];
//        
//        // draw focus ring second 
//        // 当当前button被click时，画那个黄色的圈圈 
//        // if the button is highlighted, then draw a ring around the button 
//        if([self isHighlighted]) // 当button被click时，isHighlighted返回YES 
//        {   
//            NSLog(@"high light, draw line");
//            [[NSColor yellowColor] set];
//            [path setLineWidth: 3.0f]; 
//            [path stroke];         
//        }  
//        else 
//        { 
////            // button没有被click，那就检查是否为默认的button 
////            // otherwise, check if it is a default button 
////            id btnControl = [self controlView]; 
////            
////            if ([btnControl respondsToSelector: @selector(keyEquivalent)] && [[btnControl keyEquivalent] isEqualToString: @"\r"]) 
////            {  
////                // 如果是默认button 
////                NSView *superView = controlView; 
////                NSView *tempView = nil; 
////                for (tempView = superView; tempView != nil; tempView = [tempView superview]) 
////                    superView = tempView; 
////                // 找到当前window的contentview 
////                if (superView) 
////                { 
////                    [self setMIsFound:NO]; 
////                    [self travelSubViews: superView]; 
////                } 
////                
////                // 看当前window中有没有被click的button，没有就把自己这个默认button画一个黄圈 
////                if (![self mIsFound]) 
////                { 
////                    [[self colorVlaueWithRed: 246 green: 186 blue: 55] set]; 
////                    [path setLineWidth: 3.0f]; 
////                    [path stroke]; 
////                } 
////                
////                [self setMIsFound:NO]; 
////            } 
//        } 
//        
//    }  
//    else  
//    {         
//        [[NSColor darkGrayColor] set];
//        [path fill];
//    } 
//    
//    [path release]; 
//    
    // 画button的text，这里忽略不画 
    if([self imagePosition] != NSImageOnly) {         
        [self drawTitle: [self attributedTitle] withFrame: cellFrame inView: [self controlView]]; 
    } 
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super highlight:flag withFrame:cellFrame inView:controlView];
}


@end
