//
//  FileTableView.m
//  Split
//
//  Created by Lee Hanken on 21/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import "FileTableView.h"
#import "DataSource.h"
#import "AppDelegate.h"
#import "Placeholder.h"

@implementation FileTableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
   
    if ([[((DataSource*)[self dataSource]) getFiles] count] == 0)
    {
        Placeholder *p = (Placeholder *)[((AppDelegate *)[NSApp delegate]) getPlaceholder];
        [p setStringValue: @"click to choose"];
    }
    else
    {
        Placeholder *p = (Placeholder *)[((AppDelegate *)[NSApp delegate]) getPlaceholder];
        [p setStringValue: @""];
    }
    
    // Drawing code here.
    [super drawRect:dirtyRect];
}

- (void)mouseDown:(NSEvent*) theEvent {
    // your code here
    [self clicked:self];
}

- (void)clicked:(id)sender {
    if ([self isEnabled]) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowsMultipleSelection:YES];
        [panel setCanChooseDirectories:NO];
        [panel setTreatsFilePackagesAsDirectories:YES];
        [panel runModal];
        
        NSArray *sortedArray;
        sortedArray = [[panel URLs] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(NSURL*)a path];
            NSString *second = [(NSURL*)b path];
            return [first compare:second];
        }];
        
        for (int i=0;i<[panel.URLs count];i++)
        {
            [((DataSource*)[self dataSource]) add:[[sortedArray objectAtIndex:i] path]];
        }[self reloadData];
    }
}


@end
