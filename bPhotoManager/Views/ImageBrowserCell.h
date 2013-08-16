//
//  ImageBrowserCell.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ImageBrowserView.h"

@interface ImageBrowserCell : NSObject {
    CALayer                 *layer;
    NSString                *path;
    NSString                *name;
//    NSArray                 *keywords;
//    NSString                *desc;
    NSDate                  *modifiedDate;
//    NSDate                  *picTakenDate;
    NSMutableDictionary     *properties;
    unsigned int            width;
    unsigned int            height;
    NSString                *type;
    unsigned long long      bytes;
    
}

@property (readonly)            CALayer         *layer;
@property (retain, readwrite)   NSString        *path;
@property (retain, readwrite)   NSString        *name;
@property (readonly)            NSArray         *keywords;
@property (retain, readwrite)   NSString        *desc;
@property (retain, readwrite)   NSString        *author;
@property (readonly)            NSDate          *modifiedDate;
@property (retain, readwrite)   NSDate          *picTakenDate;
@property (readonly)            unsigned int    width;
@property (readonly)            unsigned int    height;
@property (readonly)            NSString        *type;
@property (readonly)            unsigned long long    bytes;
@property (retain, readwrite)   NSMutableDictionary *properties;

//initializer
- (id) initWithPath:(NSString*)fullPath;
- (BOOL) initLayer;
- (void) setKeywords:(NSArray *)keys;

- (void)addTitleLayerWithTitle:(NSString*)title;
+ (CGColorRef) normalBorderColor:(BOOL)folder;
+ (CGColorRef) highLightBorderColor:(BOOL)folder;
@end

