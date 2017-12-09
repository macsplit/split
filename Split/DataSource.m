//
//  DataSource.m
//  Split
//
//  Created by Lee Hanken on 21/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

- init {
    files = [[NSMutableArray alloc] init];
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [files count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [files objectAtIndex:rowIndex];
    //NSLog(@"%@",[files objectAtIndex:rowIndex]);
}

-(void)add:(NSString*)filename {
    [files addObject:filename];

    //NSLog(@"%lu",[files count]);
}

-(NSMutableArray*) getFiles {
    return files;
}

-(void)clear {
    files = [[NSMutableArray alloc] init];
}

@end
