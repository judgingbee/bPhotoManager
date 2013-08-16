//
//  PropertyView.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BPMPicture;
@class ImageBrowserView;

#define INFO_MASK_NAME          1
#define INFO_MASK_AUTHOR        2
#define INFO_MASK_DATE          4
#define INFO_MASK_DESC          8
#define INFO_MASK_KEYWORDS      16

//@protocol PropertyViewDelegate <NSObject>
//
//-(void) infoChanged:(unsigned int) info;
//
//@end

@interface PropertyView : NSView{
    IBOutlet NSTextField            *txtName;
    IBOutlet NSTextField            *txtAuthor;
    IBOutlet NSTextField            *txtType;
    IBOutlet NSTextField            *txtImageSize;
    IBOutlet NSTextField            *txtFileSize;
    IBOutlet NSTextField            *txtModifiedDate;
    IBOutlet NSDatePicker           *pickerPicTokenDate;
    IBOutlet NSTextField            *txtDesc;
    IBOutlet NSTokenField           *keysField;
//    IBOutlet id <PropertyViewDelegate> delegate;
    unsigned int                    changedInfo;
}

- (CGFloat)width;
//- (void) displayInfo:(ImageBrowserView*)browser;
- (void) displayInfo:(ImageBrowserView*)browser;
@end
