//
//  MHOpenFiles.m
//  ProjectPlus
//
//  Created by Mark Huot on 5/13/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MHOpenFiles.h"

@implementation MHOpenFiles

static NSMutableArray *objectList = NULL;

+ (id)objectForTabs:(id)theTabs
{
    if (!objectList) {
        objectList = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    MHOpenFiles *item;
    for (item in objectList)
    {
        if ([[item tabView] isEqualTo:theTabs])
        {
            return item;
        }
    }
    
    MHOpenFiles *obj = [[MHOpenFiles alloc] initForTabs:theTabs];
    [objectList addObject:obj];
    return obj;
}

- (id)initForTabs:(id)theTabs
{
    self = [super init];
    if (self) {
        tabView = theTabs;
        openFiles = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

- (void)setOutlineView:(NSOutlineView *)theOutlineView
{
    outlineView = theOutlineView;
    [outlineView expandItem:[outlineView itemAtRow:0]];
}

- (void)setFileBrowserView:(NSOutlineView *)theFileBrowserView
{
    fileBrowserView = theFileBrowserView;
}

- (void)setImageView:(NSImageView *)theImageView
{
    imageView = theImageView;
}

- (id)tabView
{
    return tabView;
}

- (void)setTabView:(id)theTabView
{
    tabView = theTabView;
}

- (void)addFile:(NSString *)path
{
    [openFiles addObject:path];
    [outlineView reloadData];
    [self resizeViews];
}

- (void)removeFile:(NSString *)path
{
    [openFiles removeObject:path];
    [outlineView reloadData];
    [self resizeViews];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return [openFiles count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    return (item == nil) ? [openFiles objectAtIndex:index] : nil;
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSURL *url = [NSURL fileURLWithPath:item];
    return [url lastPathComponent];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:item];
    [icon setSize:NSMakeSize(16.0, 16.0)];
    [cell setImage:icon];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	// if we actually deselected everything by clicking outside the list then
	// stop right here.
	if ([outlineView selectedRow] == -1) {
		return;
	}
	
	// get object
	id item = [outlineView itemAtRow:[outlineView selectedRow]];
    [tabView selectTabWithIdentifier:item];
}

- (void)resizeViews
{
    float neededHeight = ([outlineView numberOfRows] * [outlineView rowHeight]) + (6.0 * [outlineView numberOfRows]);
    
    NSView *openFilesCustomView = (NSView *)[[outlineView superview] superview];    
    NSView *drawerView = [openFilesCustomView superview];
    float y = [drawerView frame].size.height - neededHeight;
    
    float w = [openFilesCustomView frame].size.width;
    
	[[openFilesCustomView animator] setFrame:NSMakeRect(0.0, y, w, neededHeight)];
    
    [[[[fileBrowserView superview] superview] animator] setFrameSize:NSMakeSize(w, [drawerView frame].size.height - neededHeight)];
    
    [[imageView animator] setFrameOrigin:NSMakePoint(0, [drawerView frame].size.height - neededHeight - 17)];
}

- (void)dealloc
{
    [super dealloc];
}

@end