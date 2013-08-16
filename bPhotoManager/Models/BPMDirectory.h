//
//  BPMDirectory.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBrowserView.h"
#import "ImageBrowserCell.h"
@class NaviItem;

@interface BPMDirectory: ImageBrowserCell <ImageBrowserViewDataSource> {
    NSMutableArray          *subDirs;
    NSMutableArray          *pics;
    NSMutableDictionary     *propertyTree; //all properties of subdir and pics in this dir
    int                     count;
    BOOL                    modified;
}

@property (retain, readwrite) NSMutableArray *subDirs;
@property (retain, readwrite) NSMutableArray *pics;
@property (assign, readwrite) int           count;
@property (assign, readwrite) BOOL          modified;

@end
