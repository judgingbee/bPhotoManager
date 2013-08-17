//
//  ImageBrowserView.h
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ImageBrowserCell;
@class ImageBrowserView;

@protocol ImageBrowserViewDataSource

@required
-(NSString*)name;
-(NSArray*)pics;
//-(unsigned short) type;

//load proteries
- (void) loadInfo;
- (void) saveInfo;

@property (assign, readwrite) BOOL modified;

@optional
-(NSArray*)subDirs;
@end

@protocol ImageBrowserViewDelegate

- (void) browserView:(ImageBrowserView*)aBrowserView cellSelected:(ImageBrowserCell*)aCell;
- (void) browserView:(ImageBrowserView*)aBrowserView cellDeselected:(ImageBrowserCell*)aCell;

@end

//@protocol ImageBrowserViewCellContent
//
////- (id) tmpSavedCell;
////- (void) setTmpSavedCell;
//
//@property (retain, readwrite)   id tmpSavedCell;
//
//@end

//const CGFloat MinCellWidth = 20;

@interface ImageBrowserView : NSView {
    NSObject <ImageBrowserViewDataSource>
                        *dataSource;
    IBOutlet id <ImageBrowserViewDelegate>
                        delegate;
    CGFloat             minInterSpace;
    CGFloat             minCellWidth;
    CGFloat             maxCellWidth;
    CGFloat             zoomValue;
    CALayer             *layer;
    int                 toLoadCnt;
    int                 loadedCnt;
    BOOL                isMinSized;
    NSMutableArray      *selectedCells;
    CALayer             *selectRectLayer;
    CGPoint             downPoint;
    NSMutableArray      *cells;
    NSCondition         *cond;
    
    BOOL                needComputeMaxRate;
    
}

@property (retain, readwrite) id <ImageBrowserViewDataSource> dataSource;
@property (assign, readwrite) CGFloat minInterSpace;
@property (assign, readwrite) CGFloat zoomValue;
@property (assign, readwrite) CGFloat minCellWidth;
@property (assign, readwrite) CGFloat maxCellWidth;
@property (readonly) BOOL isMinSized;
@property (readonly)        NSArray *selectedCells;

- (void) reloadData;


-(void)testAction;
@end
