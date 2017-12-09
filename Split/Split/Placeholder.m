//
//  Placeholder.m
//  Split
//
//  Created by Lee Hanken on 22/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import "Placeholder.h"
#import "FileTableView.h"
#import "AppDelegate.h"

@implementation Placeholder

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
    // Drawing code here.
    [super drawRect:dirtyRect];
}

- (void)mouseDown:(NSEvent*) theEvent {
    FileTableView *tv = (FileTableView *)[((AppDelegate*)[NSApp delegate]) getTableView];
    [tv clicked:self];
}

@end
