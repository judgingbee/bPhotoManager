//
//  Album.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NaviItems.h"
#import "BPMDirectory.h"

/* --------------------- NaviItem ----------------------*/
@implementation NaviItem

@synthesize type;
@synthesize obj;

- (NSString*) description
{
    switch (type) {
        case NAVITYPE_DIR:
            return [(BPMDirectory*)obj path];
            break;
            
        default:
            return @"unknow type";
    }
}

@end


/* ---------------------- ALBUM ------------------------*/
@implementation Album

@synthesize name;
@synthesize desc;
@synthesize pics;

- (void) loadInfo
{
    
}

- (void) saveInfo
{
    
}

//- (NSArray*) subDirs { return nil; }

-(unsigned short) type { return NAVITYPE_ALBUM; }
@end

/* -------------------- FAVOURITE ----------------------*/
@implementation Favourite

@synthesize name;
@synthesize path;

@end