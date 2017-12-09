//
//  AppDelegate.m
//  Split
//
//  Created by Lee Hanken on 20/07/2012.
//  Copyright (c) 2012 Lee Hanken. All rights reserved.
//

#include <stdio.h>
#import "AppDelegate.h"
#import "DataSource.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self setChunkSize: @""];
    sourceSize = 0;
    
}

-(void) closeWindow: (NSNotification *)note {
    if (((NSWindow*)[note object]) == splitWindow)
        [self clearSplit];
    if (((NSWindow*)[note object]) == joinWindow)
        [self clearJoin];
}

-(void)awakeFromNib
{
    [self setInputEnabled:YES];
    [self setInputEnabled2:YES];
    [self setPieces:2];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(closeWindow:)
               name:NSWindowWillCloseNotification
             object:nil];
}

-(NSString*) getChunkSize {
    NSString * units;
    int unitIndex=1;
    unsigned long long bytes=0,num2;
    float num;
    if ([self pieces]>0 && sourceSize>0)
    {
        bytes = (sourceSize / ((unsigned long long) [self pieces])); //4755
        num = (float)bytes;
        while (num >1000) {
            num/=1000;
            unitIndex++;
        }
        if ((((int)num)/10)==0) { //9.123 9.127       4.755
            num *=1000;           //9123 9127           4755
            unitIndex--;                                //4780
            num +=5;                //9128 9132
            num = num - ((int)num %10); //912 913       
            
        }
        else if ((((int)num)/100)==0) { // 91.234 91.284
            num *=1000;                 // 91234 91284
            unitIndex--;
            num +=50;                   // 91284 91334
            num = num - ((int)num %100);// 91200 91300
        }
        else                            //912.345 912.945
            num +=0.5;                    //912.845 913.445
                                        //912      913
        num2 = (unsigned long long)num;
        
        if (unitIndex==1) units=@"bytes";
        if (unitIndex==2) units=@"Kb";
        if (unitIndex==3) units=@"Mb";
        if (unitIndex==4) units=@"Gb";
        if (unitIndex==5) units=@"Tb";
        if (unitIndex>5) units=@"?";
        
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: num2]];
        
        if ([units isEqualToString:@""] || [numberString isEqualToString:@"0"]) return @"";
        else
            return [NSString stringWithFormat:@"%@ %@",numberString,units];
    }
        else
    return @"";
}

-(void)setSourceSize:(unsigned long long) sz {
    sourceSize = sz;
    if ([self pieces]>1 && sourceSize>0) {
        [self setChunkSize: [self getChunkSize ]];
    }
    else
        [self setChunkSize:@""];
}

- (IBAction) step:(id)sender {
    if ([self pieces]<2) [self setPieces:2];
    if ([self pieces]>1 && sourceSize>0) {
        [self setChunkSize: [self getChunkSize ]]; 
    }
    else
        [self setChunkSize:@""];
}

-(unsigned long long)getSourceSize {
    return sourceSize;
}

-(NSTableView*) getTableView {
    return src2;
}

-(NSTextField*) getPlaceholder {
    return placeholder;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction) split:(id)sender {
    [self setInputEnabled:NO];
    [self setInputEnabled2:NO];
    
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(doSplit) object:nil];
    //NSLog(@"%f",[thread threadPriority]);
    //[thread setThreadPriority:0.9];
    [thread start];
    
}

- (IBAction) join:(id)sender {
    [self setInputEnabled2:NO];
    [self setInputEnabled:NO];
    
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(doJoin) object:nil];
    //[thread setThreadPriority:0.9];
    [thread start];
    
}

- (IBAction) showSplit:(id)sender {
    BOOL current;
    current = [splitWindow isVisible];
    [splitWindow setIsVisible:YES];
    if (current == NO) {
        [self setChunkSize:@""];
        sourceSize=0;
        [chunkfield setNeedsDisplay:YES];
    }
}

- (IBAction) showJoin:(id)sender {
    [joinWindow setIsVisible:YES];
}

- (IBAction) cancel:(id)sender {
    [progress orderOut:nil];
    [NSApp endSheet:progress];
    [thread cancel];
}

-(void)clearJoin {
    [(DataSource*)[src2 dataSource] clear];
    [src2 reloadData];
    [dst2 setStringValue:@""];
}

-(void)clearSplit {
    [src setStringValue:@""];
    [dst setStringValue:@""];
    [self setPieces:2];
    [step setNeedsDisplay:YES];
    [self setChunkSize:@""];
    [self setSourceSize:0];
    [chunkfield setNeedsDisplay:YES];
}

-(void)doJoin {
    [NSApp beginSheet:progress modalForWindow:joinWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
    
    unsigned long long bytestoread = 1024*1024;
    Source2 = [((DataSource*)[src2 dataSource]) getFiles];
    NSLog(@"%@",Source2);
    Destination2 = [dst2 stringValue];
    NSString* outpath;
    if ([Source2 count]<2) NSBeep();
    else {
        unsigned long long totalsize=0;
        unsigned long long bytesthathavebeenread=0;
        for (int i=0; i<[Source2 count];i++)
        {
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[Source2 objectAtIndex:i] error: NULL];
            unsigned long long itemSize = [attrs fileSize];
            totalsize += itemSize;
        }
        
        NSString* firstfile = [Source2 objectAtIndex:0];
        NSArray *parts = [firstfile componentsSeparatedByString:@"/"];
        NSString *SourceX = [parts objectAtIndex:[parts count]-1];
        NSString* theFileName = [[SourceX lastPathComponent] stringByDeletingPathExtension];
        outpath = [NSString stringWithFormat:@"%@/%@",Destination2,theFileName];
        [[NSFileManager defaultManager] createFileAtPath:outpath contents:nil attributes:nil];
        NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:outpath];
        
        
        for (int i=0; i<[Source2 count];i++)
        {
            
            
            NSFileHandle *input = [NSFileHandle fileHandleForReadingAtPath:[Source2 objectAtIndex:i]];
            NSData * buffer;
            do {
                @autoreleasepool {
            buffer = [input readDataOfLength:bytestoread];
                bytesthathavebeenread += [buffer length];
            if ([buffer length]>0) [output writeData:buffer];
                
                    //[NSThread sleepForTimeInterval: 0.001];
                    
                double prog = (double)((bytesthathavebeenread*100)/totalsize);
                [progressBar setDoubleValue:prog];
                
                if ([thread isCancelled]) {
                    [progress orderOut:nil];
                    [NSApp endSheet:progress];
                    [self setInputEnabled:YES];
                    [self setInputEnabled2:YES];
                    [NSThread exit];
                }
                }
            } while ([buffer length] > 0);
            [input closeFile];
            
        }
        
        [output closeFile];
    }
    
    [self setInputEnabled2:YES];
    [self setInputEnabled:YES];
    [progress orderOut:nil];
    [NSApp endSheet:progress];
}

-(void)doSplit {
    
    [NSApp beginSheet:progress modalForWindow:splitWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
    
    Source = [src stringValue];
    Destination = [dst stringValue];
    int p = [self pieces];
    
    if (([Source  length] > 0) && ([Destination  length] > 0) && (p > 1)){
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:Source]==NO) NSBeep();
    else {
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath: Source error: NULL];
        unsigned long long size = [attrs fileSize];
        if (size==0) size=1; //stop divide by zero crash
        
        NSLog(@"Size: %lli",size);
        
        unsigned long long bytesreadinchunk = 0,bytesreadtotal=0,bytestoread=0;
        unsigned long long chunksize = (size/p);
        if (size%p) chunksize++;
        NSLog(@"Chunk size: %lli",chunksize);
        
        unsigned long long buffersize = 1024*1024*32;
        while (buffersize>chunksize) buffersize /=8;
        
        NSLog(@"Buffer size: %lli",buffersize);
        
        NSFileHandle *data = [NSFileHandle fileHandleForReadingAtPath:Source ];
        
        NSArray *parts = [Source componentsSeparatedByString:@"/"];
        NSString *SourceX = [parts objectAtIndex:[parts count]-1];
        
        int chunk=1;
        
        NSMutableString *outpath = [NSMutableString stringWithFormat:@"%@/%@.0%i%i",Destination,SourceX,(chunk/10),(chunk%10)];
        [[NSFileManager defaultManager] createFileAtPath:outpath contents:nil attributes:nil];
        NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:outpath];
        NSLog(@"%@",outpath);
        
        NSData* buffer;
        
        do {
            @autoreleasepool {
            if ((chunksize - bytesreadinchunk) < buffersize)
                bytestoread=(unsigned long long)(chunksize-bytesreadinchunk);
            else
                bytestoread=(unsigned long long)buffersize;
                NSLog(@"Attempting to read %lld into buffer",bytestoread);
            buffer = [data readDataOfLength:bytestoread];
            bytesreadinchunk += [buffer length];
            bytesreadtotal += [buffer length];
                NSLog(@"Read %lld of %lld",bytesreadtotal,size);
            [output writeData:buffer];
            if (bytesreadinchunk>=chunksize) { chunk++;
                [output closeFile];
                if ([buffer length]!=0 && bytesreadtotal<size) {
                outpath = [NSMutableString stringWithFormat:@"%@/%@.0%i%i",Destination,SourceX,(chunk/10),(chunk%10)];
                [[NSFileManager defaultManager] createFileAtPath:outpath contents:nil attributes:nil];
                output = [NSFileHandle fileHandleForWritingAtPath:outpath];
                NSLog(@"%@",outpath);
                bytesreadinchunk=0;
                }
            }
                
            //[NSThread sleepForTimeInterval: 0.001];
            
        double prog = (double)((bytesreadtotal*100)/size);
        [progressBar setDoubleValue: prog];
            if ([thread isCancelled]) {
                [progress orderOut:nil];
                [NSApp endSheet:progress];
                [self setInputEnabled:YES];
                [self setInputEnabled2:YES];
                [NSThread exit];
            }
        }
        }
        while ([buffer length]!=0 && bytesreadtotal<size);
        [output closeFile];
        [data closeFile];
        }
    }
    else{
        NSBeep();
        NSLog(@"%@ %@ %i",Source ,Destination,p);
    }
    [progress orderOut:nil];
    [NSApp endSheet:progress];
    [self setInputEnabled:YES];
    [self setInputEnabled2:YES];
}

@end
