//
//  BPMGlobalData.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BPMGlobalData.h"

NSDictionary        *picsByKeywords;
NSSet               *imgExt;

NSString * const EXPLORER_SELDIR    = @"SelectedDirLastTime";
NSString * const EXPLORER_ROOTDIR   = @"DisplayedFavourateDir";



@implementation BPMGlobalData


+ (void) initializeImgExt
{
    if (imgExt) return;
    
    imgExt = [[NSSet setWithObjects: IMG_EXTEND_STR , nil] retain];
}
@end
