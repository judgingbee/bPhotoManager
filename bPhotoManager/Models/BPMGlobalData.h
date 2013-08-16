//
//  BPMGlobalData.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPMDirectory.h"

#define IMG_EXTEND_STR @"jpg",@"bmp",@"png",@"icns"

//defaults entry names
extern NSString * const EXPLORER_SELDIR;
extern NSString * const EXPLORER_ROOTDIR;


extern NSDictionary     *picsByKeywords;
extern NSSet            *imgExt;

@interface BPMGlobalData : NSObject 

+ (void) initializeImgExt;
@end
