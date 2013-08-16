//
//  BPMPicture.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPMDirectory.h"

@interface BPMPicture: ImageBrowserCell{
    CGImageSourceRef    imgSource;
    CGImageRef          image;
    CGImageRef          thumbnail;
//    BOOL                imageFileMissing;
}

@property (readonly)            CGImageRef      thumbnail;
@property (readonly)            CGImageRef      image;
//@property (readwrite, assign)   BOOL            imageFileMissing;

@end
