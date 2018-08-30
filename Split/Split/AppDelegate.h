//
//  AppDelegate.h
//  Split
//
//  Created by Lee Hanken on 20/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <dispatch/dispatch.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    int pieces;
    unsigned long long sourceSize;
    NSString *Source;
    NSString *ChunkSize;
    NSString *Destination;
    NSMutableArray *Source2;
    NSString *Destination2;
    IBOutlet NSTextField *src;
    IBOutlet NSTextField *dst;
    IBOutlet NSTableView *src2;
    IBOutlet NSTextField *dst2;
    IBOutlet NSTextField *step;
    IBOutlet NSWindow *splitWindow;
    IBOutlet NSWindow *joinWindow;
    IBOutlet NSPanel *progress;
    IBOutlet NSTextField *placeholder;
    IBOutlet NSProgressIndicator *progressBar;
    IBOutlet NSTextField *chunkfield;
    dispatch_queue_t DispatchQueue;
    
    BOOL inputEnabled;
    BOOL inputEnabled2;
    
    NSThread *thread;
}

-(void)setSourceSize:(unsigned long long) sz;
-(unsigned long long)getSourceSize;

@property BOOL inputEnabled;
@property BOOL inputEnabled2;
@property NSThread* thread;
@property NSString* ChunkSize;
@property int pieces;

- (IBAction) split:(id)sender;
- (IBAction) showSplit:(id)sender;
- (IBAction) showJoin:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) step:(id)sender;

-(void)doSplit;
-(void)doJoin;
-(NSTableView*) getTableView;
-(NSTextField*) getPlaceholder;

@end
