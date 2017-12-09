//
//  FileTextField2.m
//  Split
//
//  Created by Lee Hanken on 20/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import "FileTextField2.h"

@implementation FileTextField2

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
    // your code here
    if  ([self isEnabled]) {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel runModal];
    [self setStringValue: panel.URL.path];
    }
}


@end
