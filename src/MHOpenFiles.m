//
//  MHOpenFiles.m
//  ProjectPlus
//
//  Created by Mark Huot on 5/13/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "MHOpenFiles.h"

@implementation MHOpenFiles

static MHOpenFiles *sharedInstance;
static NSMutableArray *objectList = NULL;

+ (MHOpenFiles *)sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [MHOpenFiles new];
    }
    
    return sharedInstance;
}

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
    
    if (!sharedInstance)
    {
        sharedInstance = obj;
    }
    
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

#define MyPrivateTableViewDataType @"MyPrivateTableViewDataType"

- (void)setOutlineView:(NSOutlineView *)theOutlineView
{
    outlineView = theOutlineView;
    [outlineView setIndentationPerLevel:0.0];
    [outlineView registerForDraggedTypes: [NSArray arrayWithObject:MyPrivateTableViewDataType]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
}

- (void)setFileBrowserView:(NSOutlineView *)theFileBrowserView
{
    fileBrowserView = theFileBrowserView;
}

- (void)setDividerView:(NSView *)theDividerView
{
    dividerView = theDividerView;
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

- (void)selectFile:(NSString *)path
{
    int len = [openFiles count];
    int i = 0;
    for (i; i<len; i++)
    {
        NSString *filePath = [openFiles objectAtIndex:i];
        if ([path isEqualToString:filePath])
        {
            [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:(i+1)] byExtendingSelection:NO];
        }
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return (item == nil) ? 1 : [openFiles count];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return (item == @"WORKSPACE") ? YES : NO;
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    return (item == nil) ? @"WORKSPACE" : [openFiles objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return (item == @"WORKSPACE") ? YES : NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return (item == @"WORKSPACE") ? NO : YES;
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSURL *url = [NSURL fileURLWithPath:item];
    return [url lastPathComponent];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (item == @"WORKSPACE")
    {
        [cell setImage:nil];
    }
    
    else
    {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:item];
        [icon setSize:NSMakeSize(16.0, 16.0)];
        [cell setImage:icon];
    }
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

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pasteboard declareTypes:[NSArray arrayWithObject:MyPrivateTableViewDataType] owner:self];
    //[pboard setData:data forType:MyPrivateTableViewDataType];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    if ([item isEqualToString:@"WORKSPACE"])
    {
        return NSDragOperationMove;
    }
    
    return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
    return YES;
}

- (void)resizeViews
{
    float neededHeight = ([outlineView numberOfRows] * [outlineView rowHeight]) + (6.0 * [outlineView numberOfRows]) + 2.0;
    
    NSView *openFilesCustomView = (NSView *)[[outlineView superview] superview];    
    NSView *drawerView = [openFilesCustomView superview];
    float y = [drawerView frame].size.height - neededHeight;
    float w = [openFilesCustomView frame].size.width;
    
	[[openFilesCustomView animator] setFrame:NSMakeRect(0.0, y, w, neededHeight)];
    
    [[[[fileBrowserView superview] superview] animator] setFrame:NSMakeRect(0, 0, w, [drawerView frame].size.height - neededHeight - 2.0)];
    
    [[dividerView animator] setFrameOrigin:NSMakePoint(0, [drawerView frame].size.height - neededHeight - 2.0)];
}

- (void)dealloc
{
    [super dealloc];
}

@end