//
//  BPMDirectory.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BPMDirectory.h"
#import "BPMPicture.h"
#import "NaviItems.h"

@implementation BPMDirectory

//@synthesize path;
//@synthesize name;
@synthesize subDirs;
@synthesize pics;
//@synthesize keywords;
@synthesize count;
//@synthesize tmpSavedCell;
@synthesize modified;

static CGImageRef folderFrameImage        = NULL;

-(NSString*)description
{
    return path;
}

- (NSString*) type
{
    return @"Folder";
}

- (unsigned int) width
{
    return 1;
}

- (unsigned int) height
{
    return 1;
}

- (BOOL) initLayer
{
    if (layer) return YES;
    
    layer = [[CALayer alloc] init];
//    [layer setGeometryFlipped:YES];
//    view = v;
    
//    [content setTmpSavedCell:self];
    layer.contents = (id)[BPMDirectory folderFrameImage];
    CALayer *imgLayer = [[CALayer alloc] init];
//    NSArray *picCol = [(BPMDirectory*)content pics];
    imgLayer.contents = (id)[(BPMPicture*)[pics objectAtIndex:0] thumbnail];
    
    [self addTitleLayerWithTitle: [self name]];
    
    [layer addSublayer: imgLayer];
    [imgLayer setContentsGravity:kCAGravityResizeAspect];
    imgLayer.anchorPoint = NSZeroPoint;
    
    layer.shadowOpacity = 0.6f;
    layer.shadowRadius = 5;
    //            self.shadowColor = [ImageBrowserCell normalBorderColor];
    
    [imgLayer release];
    
    return YES;
    
}

- (void) loadInfo
{
    if (propertyTree) return;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary *pro;
    NSString *tmpName;
    propertyTree = [[NSMutableDictionary alloc] initWithCapacity:([pics count]+[subDirs count])];
    NSString *plistPath = [path stringByAppendingPathComponent:@"picsInfo.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return;

    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile: plistPath];
    
    //load this dir's info
    pro = [NSMutableDictionary dictionaryWithCapacity:3];
    [pro addEntriesFromDictionary:[plistDic objectForKey:@"self"]];
    [self setProperties:pro];
    [propertyTree setObject:pro forKey:@"self"];
    
    
    for (BPMPicture *pic in pics) {
        tmpName = [pic name];
        pro = [NSMutableDictionary dictionaryWithCapacity:3];
        [pro addEntriesFromDictionary:[plistDic objectForKey:tmpName]];
        [pic setProperties:pro];
        [propertyTree setObject:pro forKey:tmpName];
    }
    
    [pool release];
}

- (void) saveInfo
{
    NSString *plistPath = [path stringByAppendingPathComponent:@"picsInfo.plist"];
    [propertyTree writeToFile:plistPath atomically:YES];
}

+ (CGImageRef) folderFrameImage
{
    if (folderFrameImage) return folderFrameImage;
    
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:[@"folderFrame" stringByDeletingPathExtension] 
                                                        ofType:@"png"];
    NSURL *url = [NSURL fileURLWithPath:imgPath isDirectory:NO];
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    folderFrameImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    CFRelease(source);
    return folderFrameImage;
}


@end
