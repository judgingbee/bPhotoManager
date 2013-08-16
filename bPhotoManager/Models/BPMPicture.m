//
//  BPMPicture.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BPMPicture.h"
#import <Quartz/Quartz.h>

@implementation BPMPicture

//@synthesize path;
//@synthesize desc;
//@synthesize keywords;
//@synthesize imgSource;
//@synthesize thumbnail;
//@synthesize tmpSavedCell;
//@synthesize type;
//@synthesize width;
//@synthesize height;
//@synthesize bytes;
//@synthesize modifiedDate;
//@synthesize picTakenDate;
//@synthesize imageFileMissing;
static CGImageSourceRef notFoundCellImage        = NULL;

- (id) initWithPath:(NSString*)fullPath
{
    self = [super initWithPath:fullPath];
    if (!self) return nil;
    
    imgSource           = NULL;
    thumbnail           = nil;
    image               = nil;
//    imageFileMissing    = NO;
    
    return self;
    
}

- (BOOL) initLayer
{
    if (layer) return YES;
    
    layer = [[CALayer alloc] init];
    [layer setGeometryFlipped:YES];
    
    layer.contents = (id)[self thumbnail];
    
    //border
    layer.anchorPoint = CGPointZero;
    [layer setBorderWidth:4];
    [layer setBorderColor: [ImageBrowserCell normalBorderColor:NO]];
    layer.shadowOpacity = 0.8f;

    return YES;
}

-(NSString*)description
{
    return name;
}

#pragma mark - properities
- (CGImageRef) image
{
    if (!image)
        image = CGImageSourceCreateImageAtIndex(imgSource, 0, NULL);
    
    return image;
}

- (CGImageRef) thumbnail
{
    if (!imgSource)
        [self createImageSource];
    
    if (!thumbnail) {
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 // Ask ImageIO to create a thumbnail from the file's image data, if it can't find a suitable existing thumbnail image in the file.  We could comment out the following line if only existing thumbnails were desired for some reason (maybe to favor performance over being guaranteed a complete set of thumbnails).
                                 [NSNumber numberWithBool:YES], (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                 [NSNumber numberWithInt:640], (NSString *)kCGImageSourceThumbnailMaxPixelSize,
                                 nil];
        thumbnail = CGImageSourceCreateThumbnailAtIndex(imgSource, 0, (CFDictionaryRef)options);
        [options release];
    }
    
    return thumbnail;
}

- (void) createImageSource
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        imgSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        return;
    }
    
    imgSource = [BPMPicture notFoundCellImage];
}


- (NSString*) name
{
    return name;
}

- (void) setName:(NSString*)nm
{
    if(!nm) return;
    
    NSString * newPaht = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:nm];
    [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPaht error:nil];
//    if (!ret) return NO;
    
    [nm retain];
    [name release];
    name = nm;
//    return YES;
}

- (NSString*)type
{
    if (type) return type;
    
    if (!imgSource)
        [self createImageSource];
        
    NSString* uti = (NSString*)CGImageSourceGetType(imgSource);
    type = [ImageIOLocalizedString(uti) retain];
    return type;
}

static NSString* ImageIOLocalizedString (NSString* key)
{
    static NSBundle* b = nil;
    
    if (b==nil)
        b = [NSBundle bundleWithIdentifier:@"com.apple.ImageIO.framework"];
    
    return [b localizedStringForKey:key value:key table: @"CGImageSource"];
}

- (unsigned int) width
{
    if (width) return width;
    [self getImgSizeProprities];
    return width;
}

- (unsigned int) height
{
    if (height) return height;
    [self getImgSizeProprities];
    return height;
}

- (void) getImgSizeProprities
{
    CFDictionaryRef props = CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL);
    CFNumberRef w = (CFNumberRef)CFDictionaryGetValue(props, kCGImagePropertyPixelWidth);
    CFNumberRef h = (CFNumberRef)CFDictionaryGetValue(props, kCGImagePropertyPixelHeight);
    
    CFNumberGetValue(w, kCFNumberNSIntegerType, &width);
    CFNumberGetValue(h, kCFNumberNSIntegerType, &height);
    
    CFRelease(props);
}

- (unsigned long long) bytes
{
    if (!imgSource) return 0;
    if (bytes) return bytes;
    [self getImgFileProprities];
    return bytes;
}

- (NSDate*) modifiedDate
{
    if (modifiedDate) return modifiedDate;
    if (!imgSource) {
        modifiedDate = [NSDate dateWithTimeIntervalSince1970:0];
        return modifiedDate;
    }
    [self getImgFileProprities];
    return modifiedDate;
}

- (void) getImgFileProprities
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *pros = [fm attributesOfItemAtPath:path error:nil];
    
    bytes = [(NSNumber*)[pros objectForKey:NSFileSize] unsignedLongLongValue];
    modifiedDate = [[pros objectForKey:NSFileModificationDate] retain];
}

+ (CGImageSourceRef) notFoundCellImage
{
    if (notFoundCellImage) return notFoundCellImage;
    
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:[@"file_not_found" stringByDeletingPathExtension] 
                                                        ofType:@"png"];
    NSURL *url = [NSURL fileURLWithPath:imgPath isDirectory:NO];
    notFoundCellImage = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    return notFoundCellImage;
}


@end
