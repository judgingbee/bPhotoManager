//
//  MainWindowController.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "BPMDirectory.h"
#import "BPMPicture.h"
#import "BPMGlobalData.h"
#import "TitleBarView.h"
#import "PropertyView.h"
#import "MainWindowController.h"
#import "SeparatorCell.h"
#import "ImageAndTextCell.h"
#import "NaviItems.h"
#import "ImageBrowserView.h"
#import "ImageBrowserCell.h"

@implementation MainWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //initialize image file extension
    [BPMGlobalData initializeImgExt];
    //Load directory
//    rootDir = [[BPMDirectory alloc] initWithPath:@"/Users/bjn/Pictures"];
//    [rootDir setCount: [self loadDirectory:rootDir]];
    
    //    //browser appearance
//    [browerView setCellsStyleMask:IKCellsStyleShadowed|IKCellsStyleOutlined];
//    [browerView setIntercellSpacing: (NSSize){30,1}];
//    
//    BackgroundLayer *bgLayer = [[[BackgroundLayer alloc] 
//                                 initWithImage:@"browserBG1.png"]autorelease];
//    bgLayer.owner = browerView;
//    
//    [browerView setBackgroundLayer:bgLayer];
    
	// apply our custom ImageAndTextCell for rendering the first column's cells
	NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"COL"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:YES];
	[tableColumn setDataCell:imageAndTextCell];
    
	separatorCell = [[SeparatorCell alloc] init];
    [separatorCell setEditable:NO];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(selectionChanged:) 
               name:NSOutlineViewSelectionDidChangeNotification 
             object:outlineView];

    [NSThread detachNewThreadSelector:@selector(loadNavigatorItemsInBackgroundThread:) toTarget:self withObject:nil];
    
    [slider setFloatValue: [browerView zoomValue]];
    
    NSLog(@"window did loaded");
}


#pragma mark - Initializing
- (int) loadDirectory:(NaviItem*)item
{
    BPMDirectory        *pDir       = [item obj];
    NSString            *rootPath   = [pDir path];
    NSFileManager       *fm         = [[NSFileManager alloc] init];
    NSMutableArray      *subDir     = [[NSMutableArray alloc] init];
    NSMutableArray      *pics       = [[NSMutableArray alloc] init];
    int cnt = 0;
    
    NSArray *files = [fm contentsOfDirectoryAtPath:rootPath error:nil];
    
    if ([files count] == 0) {
        [fm release];
        [subDir release];
        [pics release];
        return 0;
    }
    
    BOOL                isDir;
    NSString            *tmpPath;
    BPMDirectory        *tmpDir;
    NaviItem            *tmpItem;
    for (NSString *str in files) {
        tmpPath = [rootPath stringByAppendingPathComponent:str];
        [fm fileExistsAtPath:tmpPath isDirectory:&isDir];
        
        if (isDir) {
            tmpDir   = [[[BPMDirectory alloc] initWithPath:tmpPath] autorelease];
            tmpItem  = [[[NaviItem alloc] init] autorelease];
            [tmpItem setType:NAVITYPE_DIR];
            [tmpItem setObj:tmpDir];
            [subDir addObject:tmpItem];
        } else {
            if (![imgExt containsObject:[tmpPath pathExtension]])
                continue;
            
            [pics addObject: [[[BPMPicture alloc] 
                                initWithPath:tmpPath] 
                               autorelease]];
            
        }
    }
    
    if (pics) cnt += [pics count];
    
    for (NaviItem *it in subDir) {
        int ret = [self loadDirectory:it];
        cnt = cnt + ret;
    }
    if ([subDir count] > 0)
        [pDir setSubDirs:subDir];
    if ([pics count] > 0)
        [pDir setPics:pics];
    [pDir setCount:cnt];
    
    [fm release];
    [subDir release];
    [pics release];
    return cnt;
}

- (void) loadNavigatorItemsInBackgroundThread:(id)unusedObject {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self loadNavigatorItems];
    [pool release];
}


- (void) loadNavigatorItems
{
    /*  =================================
        read property list
        ================================= */
    naviItems = [[NSMutableArray alloc] init];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"NaviItems.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"NaviItems" ofType:@"plist"];
    }
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile: plistPath];
    
    /* =================================
        set items variables
       ================================= */
    NSArray *keys = [plistDic allKeys];
    for (NSString *k in keys) {
        if ([k isEqualToString:@"ALBUMS"]) {
            //just load album titles, to load details when click album titles
            [self loadAlbumTitles: [plistDic objectForKey: @"ALBUMS"]];
            [self loadAlbumDetails];
            
        } else if ([k isEqualToString:@"FAVOURITES"]) {
            [self loadFavourites: [plistDic objectForKey: @"FAVOURITES"]];
            
        } else if ([k isEqualToString:@"CURPLACE"]) {
            [self loadExplorer: [plistDic objectForKey:@"CURPLACE"]];
        }
    }

    [self performSelectorOnMainThread:@selector(displayNaviItems:) 
                           withObject:[plistDic objectForKey:@"SELECTEDPATH"] 
                        waitUntilDone:YES];
    
}

-(void) displayNaviItems:(NSString*)selectedPath
{
    
    [outlineView reloadData];
    
    NaviItem *item;
    for (item in naviItems) {
        [outlineView expandItem:item];
    }
    
    item = [self findItem: selectedPath];
    [self selectItem: item];
    
}

- (void) loadAlbumTitles:(NSArray*) albumNames
{
    albumItems = [[[NaviItem alloc] init] autorelease];
    [albumItems setType: NAVITYPE_ALBUM_G];
    [naviItems addObject:albumItems];
    
    NSMutableArray *albs = [[[NSMutableArray alloc] init] autorelease];
    Album *alb;
    NaviItem *albItem;
    for (NSString *nm in albumNames) {
        alb = [[[Album alloc] init] autorelease];
        [alb setName:nm];
        
        albItem = [[[NaviItem alloc] init] autorelease];
        [albItem setType:NAVITYPE_ALBUM];
        [albItem setObj:alb];
        [albs addObject:albItem];
    }
    [albumItems setObj: albs];
}
- (void) loadAlbumDetails
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Albums.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Albums" ofType:@"plist"];
    }
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile: plistPath];
    
    NSArray *picPaths;
    NSMutableArray *picObjs;
    NSDictionary *dic;
    Album *album;
    NaviItem *albumItem;
    NSString *path;
    for (albumItem in [albumItems obj]) {
        album = [albumItem obj];
        dic = [plistDic objectForKey: [album name]];
        picPaths = [dic objectForKey:@"pics"];
        picObjs = [[NSMutableArray alloc] init];
        for (path in picPaths)
            [picObjs addObject:[[[BPMPicture alloc] initWithPath:path] autorelease]];
        [album setPics:picObjs];
        [picObjs release];
    }

}

- (void) loadFavourites:(NSDictionary*) favourites
{
    favouriteItems = [[[NaviItem alloc] init] autorelease];
    [favouriteItems setType: NAVITYPE_FAV_G];
    [naviItems addObject:favouriteItems];

    NSMutableArray *favItems = [[[NSMutableArray alloc] init] autorelease];
    NSArray *nms = [favourites allKeys];

    NaviItem *favItem;
    Favourite *fav;
    NSString *path;
    for (NSString *nm in nms) {
        path = [favourites objectForKey:nm];
        fav = [[[Favourite alloc] init] autorelease];
        [fav setName:nm];
        [fav setPath:path];
        
        favItem = [[[NaviItem alloc] init] autorelease];
        [favItem setType: NAVITYPE_FAV];
        [favItem setObj:fav];
        
        [favItems addObject: favItem];
    }
    
    [favouriteItems setObj:favItems];
}

- (void) loadExplorer:(NSString *)path
{
    BPMDirectory *dir       = [[[BPMDirectory alloc] initWithPath:path] autorelease];
    NaviItem *dirItem       = [[[NaviItem alloc] init] autorelease];
    explorerItems  = [[[NaviItem alloc] init] autorelease];
    
    [dirItem setType:NAVITYPE_DIR];
    [dirItem setObj: dir];
    [self loadDirectory:dirItem];
    [explorerItems setType:NAVITYPE_EXP_G];
    [explorerItems setObj:dirItem];
    
    [naviItems addObject:explorerItems];
}

- (NaviItem*) findItem:(NSString*)path
{
    NaviItem *curItem = [explorerItems obj];
    NSArray *pathComps = [path pathComponents];
    
    NSString *rootPath = [(BPMDirectory*)[curItem obj] path];
    NSArray *rootPathComps = [rootPath pathComponents];
    NSString *curPath = rootPath;
    NSString *tmpPath;
    BPMDirectory *tmpDir;
    NSArray  *subDirs;
    int i, j;
    
    for (i = (int)[rootPathComps count]; i < [pathComps count]; i++) {
        curPath = [curPath stringByAppendingPathComponent: [pathComps objectAtIndex:i]];
        
        subDirs = [(BPMDirectory*)[curItem obj] subDirs];
        for (j = 0; j < [subDirs count]; j++) {
            tmpDir = (BPMDirectory*)[[subDirs objectAtIndex:j] obj];
            tmpPath = [tmpDir path];
            if ([curPath isEqualToString:tmpPath]) {
                curItem = [subDirs objectAtIndex:j];
                break;
            }
        }
        if (j > [subDirs count]) return nil;
        
    }
    
    return curItem;
    
}

- (NaviItem*) parentOfItem:(NaviItem*)item
{
    if ([item type] != NAVITYPE_DIR) return nil;
    
    NSString *path = [(BPMDirectory*)[item obj] path];
    path = [path stringByDeletingLastPathComponent];
    
    return [self findItem:path];
}

- (void)selectItem:(NaviItem*)item {
    NSInteger itemIndex = [outlineView rowForItem:item];
    if (itemIndex < 0) {
        [outlineView expandItem: [self parentOfItem:item]];
        itemIndex = [outlineView rowForItem:item];
        if (itemIndex < 0)
            return;
    }
    
    [outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: itemIndex] byExtendingSelection: NO];
}

#pragma mark - Window Delegate

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    NSView *v = [[splitView subviews] objectAtIndex:0];
    naviWidth = [v bounds].size.width;
    
    if ([browerView isMinSized]) {
        NSSize curSize = [sender frame].size;
        if (curSize.width > frameSize.width) {
            return curSize;
        } 
    }
    
    return frameSize;
}

- (void)windowDidResize:(NSNotification *)notification
{
    [splitView setPosition:naviWidth ofDividerAtIndex:0];
}


#pragma mark - Outline Data Source

//Returns the child item at the specified index of a given item
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        return [naviItems objectAtIndex:index];
    }
    
    if ([(NaviItem*)item type] & NAVITYPE_DIR)
        return [[(BPMDirectory*)[(NaviItem*)item obj] subDirs] objectAtIndex:index];
    else if ([(NaviItem*)item type] & NAVITYPE_EXP_G)
        return [item obj];
    else
        return [[(NaviItem*)item obj] objectAtIndex:index];
}

//Returns a Boolean value that indicates whether the a given item is expandable.
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    switch ([(NaviItem*)item type]) {
        case NAVITYPE_ALBUM_G:
        case NAVITYPE_EXP_G:
        case NAVITYPE_FAV_G:
            return YES;
            break;
            
        case NAVITYPE_DIR:
//            NSLog(@"subdir: %@", [[[(NaviItem*)item obj] subDirs] count]);
            if ([(BPMDirectory*)[(NaviItem*)item obj] subDirs])
                return YES;
            else
                return NO;
            break;

        default:
            return NO;
            break;
    }
    
}

//Returns the number of child items encompassed by a given item.
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item) return [naviItems count];
        
    switch ([(NaviItem*)item type]) {
        case NAVITYPE_DIR:
            return [[(BPMDirectory*)[(NaviItem*)item obj] subDirs] count];
            
        case NAVITYPE_EXP_G:
            return 1;
            
        default:
            return [(NSArray*)[(NaviItem*)item obj] count];
    }
}

//Invoked by outlineView to return the data object associated with the specified item.
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    BPMDirectory *dir;
    switch ([(NaviItem*)item type]) {
        case NAVITYPE_ALBUM:
            return [(Album*)[(NaviItem*)item obj] name];
            break;
            
        case NAVITYPE_ALBUM_G:
            return @"ALBUMS";
            break;
            
        case NAVITYPE_FAV:
            return [(Favourite*)[(NaviItem*)item obj] name];
            break;
            
        case NAVITYPE_FAV_G:
            return @"FAVOURITES";
            break;
        
        case NAVITYPE_DIR:
            dir = (BPMDirectory*)[(NaviItem*)item obj];
            return [NSString stringWithFormat:@"%@(%d)", [dir name], [dir count]];
            break;
            
        case NAVITYPE_EXP_G:
            return @"EXPLORER";
            break;
            
        default:
            return @"unknow";
            break;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if ([(NaviItem*)item type] & (NAVITYPE_ALBUM_G | NAVITYPE_EXP_G | NAVITYPE_FAV_G))
        return YES;
    else
        return NO;
}


#pragma mark - Outline View Delegate

//Returns a Boolean value that indicates whether the outline view should select a given item.
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if ([(NaviItem*)item type] & (NAVITYPE_ALBUM_G | NAVITYPE_EXP_G | NAVITYPE_FAV_G))
        return NO;
    else
        return YES;
}

- (void) selectionChanged:(NSNotification*)note
{
    NaviItem *selItem = [outlineView itemAtRow:[outlineView selectedRow]];
    id <ImageBrowserViewDataSource> ds;
    
    switch ([selItem type]) {
        case NAVITYPE_DIR:
        case NAVITYPE_ALBUM:
            //Title setting
            ds = [selItem obj];
            [titleView setTitle: [ds name]];
            [titleView setNeedsDisplay:YES];
            //Browser data source
            [browerView setDataSource:ds];
            [browerView reloadData];
            break;
            
        case NAVITYPE_FAV:
            
        default:
            break;
    }
    
    
}


#pragma mark -  Actions

- (IBAction)showProperty:(id)sender;
{
    NSButton *btn = sender;
    NSRect rect = [splitView frame];
    
    CGFloat wid = [outlineView frame].size.width;
    
    if ([btn state] == NSOnState) {
        //        [splitView addSubview:propertyView];
        
        rect.size.width -= [propertyView width];
        [splitView setFrame:rect];
        [[splitView superview] addSubview:propertyView];
        
        rect.origin.x = rect.size.width;
        rect.size.width = [propertyView width];
        [propertyView setFrame:rect];
        [propertyView displayInfo:browerView];
    } else {
        //        [[[splitView subviews] objectAtIndex:2] removeFromSuperview];
        [propertyView removeFromSuperview];
        rect.size.width += [propertyView width];
        [splitView setFrame:rect];
    }
    //    [splitView setNeedsDisplay:YES];
    [splitView setPosition:wid ofDividerAtIndex:0];
//    NSLog(@"superview:%@", propertyView.superview);
}

- (IBAction)setBrowserZoom:(id)sender
{
    CGFloat browserZoom = [browerView zoomValue];
    CGFloat sliderZoom = [slider floatValue];
    if ([browerView isMinSized] && browserZoom < sliderZoom)
        [slider setFloatValue:browserZoom];
    else
        [browerView setZoomValue:sliderZoom];
}

#pragma mark -  Image Browser View Delegate

- (void) browserView:(ImageBrowserView*)aBrowserView cellSelected:(ImageBrowserCell*)aCell
{
    [propertyView displayInfo:aBrowserView];
}

- (void) browserView:(ImageBrowserView*)aBrowserView cellDeselected:(ImageBrowserCell*)aCell
{
    [propertyView displayInfo:aBrowserView];
}

#pragma mark -  Image Browser View Delegate
- (void) infoChanged
{
    [[browerView dataSource] setModified:YES];
}

#pragma mark - TEST AREA
- (IBAction)test1Action:(id)sender
{
//    ImageBrowserCell *cell;
//    
//    NSArray *subLayers = [[browerView layer] sublayers];
//    
//    if ([subLayers count] > 0)
//        for (CALayer *lay in subLayers)
//            [lay removeFromSuperlayer];
//    
//    BPMPicture *pic = [[BPMPicture alloc] initWithPath:@"/Users/bjn/Pictures/Wallpapers/01.jpg" Parent:nil];
//    
//    cell = [[ImageBrowserCell alloc] initWithType:ImageBrowserCellTypeImage Content:pic];
//    NSRect imageBounds = NSMakeRect(0, 0, 200,  200);
////    cell.bounds = imageBounds;
//    cell.frame = imageBounds;
////    CGPoint randomPoint = CGPointMake(500,500);
////    cell.position = randomPoint;
//    [[browerView layer] addSublayer:cell];

    NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"COL"];
	ImageAndTextCell *imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	[imageAndTextCell setEditable:YES];
	[tableColumn setDataCell:imageAndTextCell];

    
    NaviItem *it = [self findItem: @"/Users/bjn/Pictures"];
    NSLog(@"item:%@", it);
    [outlineView expandItem: it];
}

- (IBAction)test2Action:(id)sender
{
//    for (CALayer *layer in [[browerView layer] sublayers]) {
//        NSRect frame = [layer frame];
//        NSLog(@"x:%f, y:%f, w:%f, h:%f",frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
//    }
    
    [browerView testAction];
}


@end
