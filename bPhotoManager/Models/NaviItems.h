//
//  Album.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBrowserView.h"

#define NAVITYPE_ALBUM      1
#define NAVITYPE_FAV        2
#define NAVITYPE_DIR        4
#define NAVITYPE_ALBUM_G    8
#define NAVITYPE_FAV_G      16
#define NAVITYPE_EXP_G      32


/* --------------------- NaviItem ----------------------*/
@interface NaviItem : NSObject {
    unsigned short  type;
    id              obj;
}

@property (assign, readwrite) unsigned short type;
@property (retain, readwrite) id obj;

@end


/* ---------------------- ALBUM ------------------------*/
@interface Album : NaviItem <ImageBrowserViewDataSource> {
    NSString        *name;
    NSMutableArray  *pics;      //save BPMPicture objects
    NSString        *desc;
}

@property (retain, readwrite) NSString          *name;
@property (retain, readwrite) NSString          *desc;
@property (retain, readwrite) NSMutableArray    *pics;

@end


/* -------------------- FAVOURITE ----------------------*/
@interface Favourite : NaviItem {
    NSString        *name;
    NSString        *path;
}

@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSString *path;

@end