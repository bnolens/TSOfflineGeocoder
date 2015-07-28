//
//  NSMutableArray+QueueAdditions.h
//  shakka.me
//
//  Created by Shay Erlichmen on 25/09/12.
//  Copyright (c) 2012 shakka.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end