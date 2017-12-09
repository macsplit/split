//
//  FileTableView.h
//  Split
//
//  Created by Lee Hanken on 21/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileTableView : NSTableView <NSTableViewDataSource> {
}

-(void)clicked:(id)sender;

@end
