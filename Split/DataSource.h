//
//  DataSource.h
//  Split
//
//  Created by Lee Hanken on 21/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DataSource : NSObject <NSTableViewDataSource> {
    NSMutableArray *files;
}

-(NSMutableArray*) getFiles;

-(void)add:(NSString*)filename;
-(void)clear;

@end
