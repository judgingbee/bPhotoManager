//
//  ImageBrowserView.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageBrowserView.h"
#import "ImageBrowserCell.h"
#import "BPMDirectory.h"
#import "BPMPicture.h"
#import "NaviItems.h"

@implementation ImageBrowserView

@synthesize dataSource;
@synthesize minInterSpace;
@synthesize minCellWidth;
@synthesize maxCellWidth;
@synthesize isMinSized;
@synthesize selectedCells;

#pragma mark - Initializing

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
	
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
//    NSBezierPath* aPath = [NSBezierPath bezierPath];
//    
//    [aPath moveToPoint:NSMakePoint(1.0, 1.0)];
//    [aPath lineToPoint:NSMakePoint(1000.0, 1000.0)];
//    [aPath closePath];
//    [aPath setLineWidth:1];
//    [aPath stroke];
}

- (void)awakeFromNib
{
    [self setPostsFrameChangedNotifications:YES];
    [self setPostsBoundsChangedNotifications:NO];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(sizeChanged:) 
               name:NSViewFrameDidChangeNotification 
             object:self];
    
    layer = [[CALayer alloc] init];
    [self setWantsLayer:YES];
    [self setLayer: layer];
//    [layer setGeometryFlipped:YES];
//    [self displayIsFlipped];
    // geometryFlipped property of layer dont work , so I decide not use it.
    // and conver the coordinate manually
//    layer.transform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
    
    selectRectLayer = [[CALayer alloc] init];
    CGColorRef tmpRef =CGColorCreateGenericRGB(0, 0.6, 1, 0.8);
    selectRectLayer.borderColor = tmpRef;
    CFRelease(tmpRef);
    selectRectLayer.borderWidth = 1;
    tmpRef = CGColorCreateGenericRGB(0, 0.6, 1, 0.4);
    selectRectLayer.backgroundColor = tmpRef;
    CFRelease(tmpRef);
    
    zoomValue = 0.2f;
    minCellWidth = 80;
    maxCellWidth = 500;
    minInterSpace = 50;
    
    selectedCells = [[NSMutableArray alloc] init];
    cells  = [[NSMutableArray alloc] init];
    
    cond = [[NSCondition alloc] init];
}

#pragma mark - Appearance processing

- (void) sizeChanged:(NSNotification*)note
{
    [self reLayout];
}

- (void) setZoomValue:(CGFloat)zoom
{
    if (zoom > 1) 
        zoomValue = 1;
    else if (zoom < 0)
        zoomValue = 0;
    else 
        zoomValue = zoom;
    
    [self reLayout];
}

- (CGFloat) zoomValue
{
    return zoomValue;
}

- (void) selectCell:(ImageBrowserCell*)cell
{
    if ([selectedCells containsObject:cell]) 
        return;
    
    if ([cell class] == [BPMPicture class]) {
        [cell layer].borderColor = [ImageBrowserCell highLightBorderColor:NO];
        
    } else if ([cell class] == [BPMDirectory class]) {
        [cell layer].shadowColor = [ImageBrowserCell highLightBorderColor:YES];
    }
    
    [selectedCells addObject:cell];
    
    [delegate browserView:self cellSelected:cell];
}

- (void) selectCells:(NSArray*)selCells
{
    for (ImageBrowserCell *c in selCells) {
        [self selectCell:c];
    }
}

- (void) deselectCell:(ImageBrowserCell*)cell
{
    NSInteger index = [selectedCells indexOfObject:cell];
    if (index == (NSInteger)NSNotFound)
        return;
    
    if ([cell class] == [BPMPicture class]) {
        [cell layer].borderColor = [ImageBrowserCell normalBorderColor:NO];
        
    } else if ([cell class] == [BPMDirectory class]) {
        [cell layer].shadowColor = [ImageBrowserCell normalBorderColor:YES];
        
    }
    
    [selectedCells removeObjectAtIndex:index];
    
    [delegate browserView:self cellDeselected:cell];
}

- (void) deselectCells:(NSArray*)selCells
{
    for (ImageBrowserCell *c in [selCells reverseObjectEnumerator]) {
        [self deselectCell:c];
    }
}

#pragma mark - Loading data

- (void) reloadData
{
    //remove current cells (layers)
    if ([cells count] > 0)
        for (ImageBrowserCell *c in [cells reverseObjectEnumerator])
            [self removeCell:c];
    
    toLoadCnt = loadedCnt = 0;
    if ([dataSource respondsToSelector:@selector(subDirs)]) {
        //display folders
        NSArray *subDirs = [dataSource subDirs];
        toLoadCnt += [subDirs count];
        for (NaviItem *dirItem in subDirs)
            [NSThread detachNewThreadSelector:@selector(loadCell:) toTarget:self withObject:[dirItem obj]];
        
    }
    
    //add new cells(layers) in threads
    NSArray *pics = [dataSource pics];
    toLoadCnt += [pics count];
    for (BPMPicture *pic in pics)
        [NSThread detachNewThreadSelector:@selector(loadCell:) toTarget:self withObject:pic];
    
    [NSThread detachNewThreadSelector:@selector(loadInfo) toTarget:dataSource withObject:nil];
    if ([dataSource respondsToSelector:@selector(subDirs)])
        for (NaviItem *dirItem in [dataSource subDirs])
            [NSThread detachNewThreadSelector:@selector(loadInfo) toTarget:[dirItem obj] withObject:nil];

}

-(void) loadCell:(ImageBrowserCell*)cell
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [cell initLayer];
    [cond lock];
    loadedCnt++;
    [cond unlock];
    
    if (loadedCnt < toLoadCnt) return;
    
    ImageBrowserCell *c;
    if ([dataSource class] == [BPMDirectory class])
        for (NaviItem *item in [dataSource subDirs]) {
            c = [item obj];
            [self addCell:c];
        }
    for (c in [dataSource pics]) {
        [self addCell:c];
    }
    [self performSelectorOnMainThread:@selector(relayoutOnMainThread:) withObject:nil waitUntilDone:NO];
    
    [pool release];
}

- (void) relayoutOnMainThread:(id)unusedObject
{
    [self reLayout];
}

- (void) addCell:(ImageBrowserCell*)cell
{
    [cells addObject:cell];
    [layer addSublayer: [cell layer]];
}

- (void) removeCell:(ImageBrowserCell*)cell
{
    [cells removeObject:cell];
    [[cell layer] removeFromSuperlayer];
}

- (void) reLayout
{
    NSLog(@"relayout");
    int cellsCnt = (int)[cells count];
    if (cellsCnt == 0) return;
    
    ImageBrowserCell *cell;
    CGFloat rate, maxRate, rateDiff;
    CGFloat x = 0, y = 0;
    
    CGFloat width = self.bounds.size.width;
    CGFloat cellWidth = ((maxCellWidth-minCellWidth)*zoomValue)+minCellWidth;
    isMinSized = NO;
    if (cellWidth+(minInterSpace*2)+50 > width) isMinSized = YES;
    if (cellWidth+(minInterSpace*2) > width) return;

    CGFloat n = floorf( (width - minInterSpace) / (cellWidth + minInterSpace));
    CGFloat interSpace = (width - n*cellWidth) / (n+1);
    
    for (int i = 0; i < ceilf(cellsCnt/n); i++) {
        x = interSpace;
        y += interSpace;
        
        // get max rate (heightDivWidth)
        cell = [cells objectAtIndex:(i*n)];
        maxRate = (CGFloat)[cell height]/(CGFloat)[cell width];
        for (int j = (i*n)+1; (j<(i+1)*n)&&(j<cellsCnt); j++) {
            cell = [cells objectAtIndex:j];
            rate = (CGFloat)[cell height]/(CGFloat)[cell width];
            if (maxRate < rate) maxRate  = rate;
        }
        
        // set cell frame of a row
        for (int j = 0; (j<n)&&((i*n)+j<cellsCnt); j++) {
            cell = [cells objectAtIndex:(i*n)+j];
            rate = (CGFloat)[cell height]/(CGFloat)[cell width];
            rateDiff = maxRate - rate;
            [[cell layer] setFrame: CGRectMake(x+((cellWidth + interSpace)*j), 
                                       y+(rateDiff*cellWidth/2), 
                                       cellWidth, cellWidth*rate)];
            if ([cell class] == [BPMDirectory class]) {
                CALayer *subLayer = [[[cell layer] sublayers] objectAtIndex:1];
                CGFloat delta= cellWidth*0.1;
                [subLayer setFrame:CGRectMake(delta, delta, 
                                             cellWidth-(delta*2), (cellWidth)-(delta*2))];
            }
        }
        
        y += (maxRate*cellWidth);
    }
//    NSView *v = [(NSScrollView*)self.superview documentView];
//    NSRect b = v.bounds;
//    b.size.height = y+interSpace;
//    [v setFrame:b];
    CGFloat visibleHeight = [self visibleRect].size.height;
    if (y+interSpace > visibleHeight)
        [self setFrame:NSMakeRect(0, 0, width, y+interSpace)];
    else
        [self setFrame:NSMakeRect(0, 0, width, visibleHeight)];
        
//    [[((NSScrollView*)self.superview.superview) scroll] scrollPoint:NSZeroPoint];
//    [((NSScrollView*)self.superview.superview) refl];
    [self scrollPoint:NSMakePoint(0, self.bounds.size.height)];
}

#pragma mark - Mouse event

- (void)mouseDown:(NSEvent *)theEvent
{
    downPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//    [layer setGeometryFlipped:YES];
    [self displayIsFlipped];
//    downPoint.y = layer.bounds.size.height - downPoint.y;
//    不知道为什么在MacbookAir（MacOS 10.7）里面需要上面的那一句，

    
//    CGPoint curPoint = NSPointToCGPoint(location);
//    
//    NSLog(@"curpoint:x:%f, y:%f", curPoint.x, curPoint.y);
//    NSLog(@"location:x:%f, y:%f", location.x, location.y);
    
    
//    CALayer *cell = [layer hitTest:location];
//-------------------------
    ImageBrowserCell *cell = nil;
    CALayer *lay;
    for (ImageBrowserCell *curCell in cells) {
        lay = [curCell layer];
        CGPoint p = [layer convertPoint:downPoint toLayer:lay];
//        p.y = layer.bounds.size.height - p.y;
//        NSLog(@"p:x:%f, y:%f", p.x, p.y);
        if ([lay containsPoint:p]) {
            cell = curCell;
            break;
        }
    }
    if (cell) {
        if ([theEvent modifierFlags] & NSShiftKeyMask) {
            if([selectedCells containsObject:cell])
                [self deselectCell:cell];
            else
                [self selectCell:cell];
               
        } else {
            if ([selectedCells count] == 1 && [selectedCells containsObject:cell])
                [self deselectCell:cell];
            else {
                [self deselectCells:selectedCells];
                [self selectCell:cell];
            }
        }
    } else
        [self deselectCells:selectedCells];
    
    
//    //-------------------------
//    CALayer *cell = [[layer sublayers] objectAtIndex:3];
//    CGPoint p = [layer convertPoint:curPoint toLayer:cell.presentationLayer ];
//    NSLog(@"p:x:%f, y:%f", p.x, p.y);
//    cell.borderWidth=1;
//    NSLog(@"contains:%d", [cell.presentationLayer containsPoint:p]);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    [selectRectLayer removeFromSuperlayer];
    [CATransaction commit];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    
}

- (void)mouseExited:(NSEvent *)theEvent
{
    
    
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [layer addSublayer:selectRectLayer];
    NSPoint currentPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//    currentPoint.y = layer.bounds.size.height - currentPoint.y;
//    不知道为什么在MacbookAir（MacOS 10.7）里面需要上面的那一句，
    float minX = MIN(downPoint.x, currentPoint.x);
    float maxX = MAX(downPoint.x, currentPoint.x);
    float minY = MIN(downPoint.y, currentPoint.y);
    float maxY = MAX(downPoint.y, currentPoint.y);
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    selectRectLayer.frame = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    [CATransaction commit];
    
    
    for (ImageBrowserCell *cell in cells) {
        if([cell layer] == selectRectLayer) continue;
        
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue
//                         forKey:kCATransactionDisableActions];
        if (CGRectIntersectsRect([cell layer].frame, selectRectLayer.frame))
            [self selectCell:cell];
        else
            [self deselectCell:cell];
//        [CATransaction commit];
        
    }
//    selectRectLayer.opacity = 1;
}

-(void)testAction
{
    NSLog(@"selected cell cnt:%lu", [selectedCells count]);
}

-(void)displayIsFlipped
{
    if ([layer isGeometryFlipped]) {
        NSLog(@"layer is Flipped.");
    } else {
        NSLog(@"layer is not Flipped.");
    }
}

@end
