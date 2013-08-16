//
//  ImageBrowserCell.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageBrowserCell.h"
#import "NaviItems.h"
#import "BPMPicture.h"
#import "BPMDirectory.h"
#import "ImageBrowserView.h"

static CGColorRef normalBorderColor             = NULL;
static CGColorRef highlightBorderColor          = NULL;
static CGColorRef normalBorderColorFolder       = NULL;
static CGColorRef highlightBorderColorFolder    = NULL;

@implementation ImageBrowserCell

@synthesize layer;
@synthesize path;
@synthesize name;
//@synthesize keywords;
//@synthesize desc;
@synthesize modifiedDate;
//@synthesize picTakenDate;
@synthesize width;
@synthesize height;
@synthesize type;
@synthesize bytes;
@synthesize properties;

- (id) initWithPath:(NSString*)fullPath
{
    self = [super init];
    if (!self) return nil;
    
    if (!fullPath)
        return nil;
    layer = nil;
    path = [fullPath retain];
    name = [[fullPath lastPathComponent] retain];
    
    type         = nil;
    width        = 0;
    height       = 0;
    bytes        = 0;
    modifiedDate = nil;
    properties  = nil;
    
    return self;
}

- (BOOL) initLayer { return NO; }

- (NSString*) author { return [properties objectForKey:@"author"]; }
- (void) setAuthor:(NSString *)author { [self setProperity:author forKey:@"author"]; }

- (NSString*) desc { return [properties objectForKey:@"desc"]; }
- (void) setDesc:(NSString *)desc { [self setProperity:desc forKey:@"desc"]; }

- (NSArray*) keywords { return [properties objectForKey:@"keywords"]; }
- (void) setKeywords:(NSArray *)keys { [self setProperity:keys forKey:@"keywords"]; }

- (NSData*) picTakenDate { return [properties objectForKey:@"date"]; }
- (void) setPicTakenDate:(NSDate *)picTakenDate { [self setProperity:picTakenDate forKey:@"date"]; }

- (void) setProperity:(id)properity forKey:(NSString*)key
{    
    //delete all repeated elements
    if ([key isEqualToString:@"keywords"]) {
        NSSet *set = [NSSet setWithArray:(NSArray*)properties];
        properties = (id)[set allObjects];
    }
    [properties setObject:properity forKey:key];
}

- (void)addTitleLayerWithTitle:(NSString*)title
{
    if (layer == nil) return;
    
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.string = title;
//    txtLayer.zPosition = 100;
    txtLayer.fontSize = 12;
    txtLayer.foregroundColor = CGColorGetConstantColor(kCGColorBlack);
//    [txtLayer setShadowOpacity:0.5f];
//    [txtLayer setShadowOffset:CGSizeMake(0.5, 0.5)];
    
    NSFont *font = [NSFont systemFontOfSize:txtLayer.fontSize];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           font, NSFontAttributeName, 
//                           [NSColor blackColor], NSForegroundColorAttributeName, 
//                           1, NSStrokeWidthAttributeName,
                           nil];
    NSSize size = [title sizeWithAttributes:attrs];
    // Ensure that the size is in whole numbers:
    size.width = ceilf(size.width)+16;
    size.height = ceilf(size.height)+5;
//    txtLayer.bounds = CGRectMake(0, 0, size.width, size.height);
//    CGFloat superHeight = txtLayer.superlayer.bounds.size.height;
    txtLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    txtLayer.borderWidth = 1;
    [layer addSublayer:txtLayer];
    layer.layoutManager=[CAConstraintLayoutManager layoutManager];
    [txtLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                       relativeTo:@"superlayer"
                                                        attribute:kCAConstraintMidX]];
//    [txtLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY
//                                                       relativeTo:@"superlayer"
//                                                        attribute:kCAConstraintMaxY]];
//    [txtLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
//                                                       relativeTo:@"superlayer"
//                                                        attribute:kCAConstraintWidth]];
}

+ (CGColorRef) normalBorderColor:(BOOL)folder
{
    if (folder) {
        if (!normalBorderColorFolder)
            normalBorderColorFolder = CGColorCreateGenericRGB(0, 0, 0, 1);
        return normalBorderColorFolder;
    } else {
        if (!normalBorderColor)
            normalBorderColor = CGColorCreateGenericRGB(1, 1, 1, 1);
        return normalBorderColor;
    }
}

+ (CGColorRef) highLightBorderColor:(BOOL)folder
{
    if (folder) {
        if (!highlightBorderColorFolder)
            highlightBorderColorFolder = CGColorCreateGenericRGB(1, 0.6, 0, 1);
        return highlightBorderColorFolder;
    } else {
        if (!highlightBorderColor)
            highlightBorderColor = CGColorCreateGenericRGB(1, 1, 0.4, 1);
        return highlightBorderColor;
    }

}


@end
