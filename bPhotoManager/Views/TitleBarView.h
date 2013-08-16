//
//  TitleBarView.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface TitleBarView : NSView {
    NSMutableArray *colorArray;
    NSGradient *gradient;
    NSString *title;
    NSDictionary *attr;
    
    NSShadow *theShadow;
}

@property(retain, readwrite) NSString *title;
@end
