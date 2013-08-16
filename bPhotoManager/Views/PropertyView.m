//
//  PropertyView.m
//  bPhotoManager
//
//  Created by 家寧 畢 on 12/08/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PropertyView.h"
#import "BPMPicture.h"
#import "BPMDirectory.h"
#import "ImageBrowserView.h"

@implementation PropertyView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
//        bgLayer = [[[BackgroundLayer alloc]  initWithImage:@"browserBG.png"]autorelease];
//        bgLayer.owner = self;
//        
//        [self setLayer:bgLayer];
//        [self setWantsLayer:YES];
        changedInfo = 0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor colorWithDeviceWhite:0.2 alpha:1] set];
    NSRectFill(dirtyRect); 
    int height = [self bounds].size.height;
    NSBezierPath *p = [NSBezierPath bezierPath];
    [p setLineWidth:0];
    [p moveToPoint:NSMakePoint(1, 0)];
    [p lineToPoint:NSMakePoint(1, height)];
    [[NSColor colorWithDeviceWhite:1 alpha:0.7] set];
    [p stroke];
    [p moveToPoint:NSMakePoint(0, 0)];
    [p lineToPoint:NSMakePoint(0, height)];
    [[NSColor blackColor] set];
    [p stroke];
}

- (void) awakeFromNib
{
//    [[keysField cell] setWraps:YES];

}

- (CGFloat)width
{
    return 250;
}


- (void) displayInfo:(ImageBrowserView*)browser
{
    if (self.superview == nil) return;
    changedInfo = 0;
//    if ([cells count] == 0) {
//        NSString *initStr = @"";
//        [txtName setStringValue:initStr];
//        [txtType setStringValue:initStr];
//        [txtDesc setStringValue:initStr];
//        [txtFileSize setStringValue:initStr];
//        [txtImageSize setStringValue:initStr];
//        [txtModifiedDate setStringValue:initStr];
//        [pickerPicTokenDate setDateValue:[NSDate dateWithTimeIntervalSince1970:0]];
//        [keysField setObjectValue:[NSArray array]];
//        return;
//    }
    
    NSArray *cells = [browser selectedCells];
    ImageBrowserCell *cell;
    if ([cells count] == 0) 
        cell = (ImageBrowserCell*)[browser dataSource];
    else 
        cell = [cells objectAtIndex:0];

    NSString            *name                   = [cell name];
    NSString            *author2,   *author     = [cell author];
    NSString            *type2,     *type       = [cell type];
    NSString            *desc2,     *desc       = [cell desc];
    NSArray             *keywords2, *keywords   = [cell keywords];
    unsigned long long  bytes2,     bytes       = [cell bytes];
    NSDate              *modiDate2, *modiDate   = [cell modifiedDate];
    NSDate              *picDate2,  *picDate    = [cell picTakenDate];
    unsigned int        width2,     width       = [cell width];
    unsigned int        height2,    height      = [cell height];
    
    BOOL stop[9] = {NO, NO, NO, NO, NO, NO, NO, NO, NO};
    
    if ([cells count]>1) {
        name = @"----";
        [txtName setEditable:NO];
    } else
        [txtName setEditable:YES];
    
    if (!desc) desc = @"";
    if (!author) author = @"";
    for (int i=1; i<[cells count]; i++) {
        cell = [cells objectAtIndex:i];
        
        if (!stop[0]) {
            type2 = [cell type];
            if (![type isEqualToString:type2]) {
                type = @"----";
                stop[0] = YES;
            }
        }
        
        if (!stop[1]) {
            desc2 = [cell desc];
            if (![desc isEqualToString:desc2]) {
                desc = @"";
                stop[1] = YES;
            }
        }
        
        if (!stop[2]) {
            keywords2 = [cell keywords];
            keywords = [self array:keywords andArray:keywords2];
            if ([keywords count] == 0)
                stop[2] = YES;
        }
        
        if (!stop[3]) {
            bytes2 = [cell bytes];
            bytes += bytes2;
        }
        
        if (!stop[4]) {
            modiDate2 = [cell modifiedDate];
            if (![modiDate isEqualToDate:modiDate2]) {
                modiDate = nil;
                stop[4] = YES;
            }
        }
        
        if (!stop[5]) {
            picDate2 = [cell modifiedDate];
            if (![picDate isEqualToDate:picDate2]) {
                picDate = nil;
                stop[5] = YES;
            }
        }
        
        if (!stop[6]) {
            width2 = [cell width];
            if (width != width2) {
                width = 0;
                stop[6] = YES;
            }
        }
        
        if (!stop[7]) {
            height2 = [cell height];
            if (height != height2) {
                height = 0;
                stop[7] = YES;
            }
        }
        
        if (!stop[8]) {
            author2 = [cell author];
            if (![author isEqualToString:author2]) {
                author = @"";
                stop[8] = YES;
            }
        }
        
    }
    
    [txtName setStringValue:name];
    [txtAuthor setStringValue:author];
    [txtType setStringValue:type];
    [txtDesc setStringValue:desc];
    [txtFileSize setStringValue:[self bytesToString:bytes]];
//    [keysField setEditable:NO];
    [keysField setObjectValue:keywords];
    if ([keywords count]>1) [self resizeTokenField];

    if (modiDate) 
        [txtModifiedDate setStringValue:[NSDateFormatter localizedStringFromDate:modiDate
                                                                       dateStyle:NSDateFormatterShortStyle
                                                                       timeStyle:NSDateFormatterNoStyle]];
    else 
        [txtModifiedDate setStringValue:@"----"];
    
    if (picDate) [pickerPicTokenDate setDateValue:picDate];
    else [pickerPicTokenDate setDateValue:[NSDate dateWithTimeIntervalSince1970:0]];

    NSString *sw, *sh;
    sw = width == 0  ? @"--" : [NSString stringWithFormat:@"%d", width];
    sh = height == 0 ? @"--" : [NSString stringWithFormat:@"%d", height];
    [txtImageSize setStringValue:[NSString stringWithFormat:@"%@ x %@", sw, sh]];
    
    NSWindow *win = [self window];
//    [win makeFirstResponder:txtDesc];
    NSObject *responder = [win firstResponder];

    if ( [responder isKindOfClass:[NSTextView class]] &&
        [win fieldEditor:NO forObject:nil] != nil ) {
        responder = [(NSTextView*)responder delegate];
    }    
    if (responder == txtName || 
        responder == txtDesc ||
        responder == keysField) {
        NSText* fieldEditor = [win fieldEditor:YES forObject:responder];
        [fieldEditor setSelectedRange:NSMakeRange([[fieldEditor string] length],0)];
    }

    
    
//    [[self window] makeFirstResponder:txtName];
//    NSText* fieldEditor = [[self window] fieldEditor:YES forObject:txtName];
//    [fieldEditor setSelectedRange:NSMakeRange(0,0)];
//    [txtType setStringValue:[cell type]];
//    
//    NSString *desc = [cell desc];
//    if (!desc) desc = @"";
//    [txtDesc setStringValue:desc];
    
//    NSArray *keys = [cell keywords];
//    if (!keys) keys = [NSArray arrayWithObject:nil];
//    [keysField setObjectValue:keys];
//    [keysField setObjectValue:[cell keywords]];
//    
//    if ([cell class] == [BPMPicture class]) {
//        [txtImageSize setStringValue:[NSString stringWithFormat:@"%d x %d", [cell width], [cell height]]];
////        unsigned long long bytes = [pic bytes];
//        NSString *unit;
//        float value = [cell bytes];
//        int i = 0;
//        for (i = 0; value > 1024; i++)
//            value /=1024;
//        
//        if (i==1) unit = @"KB";
//        if (i==2) unit = @"MB";
//        
//        if (i==0) {
//            [txtFileSize setStringValue:[NSString stringWithFormat:@"%d Bytes", (int)value]];
//        } else {
//            [txtFileSize setStringValue:[NSString stringWithFormat:@"%.2f %@", value, unit]];
//        }
////        [txtModifiedDate setStringValue:[[cell modifiedDate] descriptionWithCalendarFormat:@"yyyy-MM-dd 'at' HH:mm"
////                                                                                  timeZone:nil 
////                                                                                    locale:nil]];
//        [txtModifiedDate setStringValue:[[cell modifiedDate] description]];
//        
//    } else {
//        [txtImageSize setStringValue:@"----"];
//        [txtFileSize setStringValue:@"get Folder size?"];
//        [txtModifiedDate setStringValue:@"----"];
//    }
}

- (NSString*) bytesToString:(unsigned long long)byteCnt
{
    NSString *unit=@"";
    float value = byteCnt;
    int i = 0;
    for (i = 0; value > 1024; i++)
        value /=1024;
    
    if (i==1) unit = @"KB";
    if (i==2) unit = @"MB";
    
    if (i==0) {
        return [NSString stringWithFormat:@"%d Bytes", (int)value];
    } else {
        return [NSString stringWithFormat:@"%.2f %@", value, unit];
    }

}

-(NSArray*) array:(NSArray*)array1 andArray:(NSArray*)array2
{
    NSMutableArray *result = [NSArray array];
    
    for (NSString *str1 in array1)
        for (NSString *str2 in array2)
            if ([str1 isEqualToString:str2]){
                [result addObject:str1];
                break;
            }
    return result;
}

#pragma mark - Controls Delegate
- (void)controlTextDidChange:(NSNotification *)aNotification;
{
    id obj = [aNotification object];
    
    if (obj == keysField) {
        [self resizeTokenField];
    }
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
    id obj = [aNotification object];
    
    if (obj == txtName) {
        NSLog(@"editing name: %@", [txtName stringValue]);
    } else if (obj == txtAuthor) {
        NSLog(@"editing author: %@", [txtAuthor stringValue]);
    } else if (obj == txtDesc) {
        NSLog(@"editing desc: %@", [txtDesc stringValue]);
    } else if (obj == keysField) {
        NSLog(@"editing keys: %@", [keysField objectValue]);
    }
    
    
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    unsigned int info;
    id obj = [aNotification object];
    
    if (obj == txtName) {
        info = INFO_MASK_NAME; 
        NSLog(@"edited name: %@", [txtName stringValue]);
    } else if (obj == txtAuthor) {
        info = INFO_MASK_AUTHOR;
        NSLog(@"edited author: %@", [txtAuthor stringValue]);
    } else if (obj == txtDesc) {
        info = INFO_MASK_AUTHOR;
        NSLog(@"edited desc: %@", [txtDesc stringValue]);
    } else if (obj == keysField) {
        info = INFO_MASK_AUTHOR;
        NSLog(@"edited keys: %@", [keysField objectValue]);
    }
    
}
- (void) resizeTokenField
{
    
    NSRect oldTokenFieldFrame = [keysField frame];
    NSRect fieldBounds = [keysField bounds];
    fieldBounds.size.width -= 2;
    fieldBounds.size.height = 500;
    NSSize cellSize= [[keysField cell] cellSizeForBounds:fieldBounds];
    [keysField setFrame:NSMakeRect(oldTokenFieldFrame.origin.x,
                                    oldTokenFieldFrame.origin.y+ oldTokenFieldFrame.size.height-
                                    cellSize.height-2,
                                    oldTokenFieldFrame.size.width,
                                    cellSize.height+2)];
//    [keysField setSelectable:YES];
     
}

@end
