/*
 The MIT License
 
 Copyright (c) 2012 Shay Erlichmen
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "RadixTree.h"
#import "RadixTreeNode.h"
#import "Visitor.h"
#import "NSMutableArray+QueueAdditions.h"

@interface RadixTree() {
    RadixTreeNode *_root;

    NSUInteger _count;
}

-(BOOL)insert:(NSString *)key node:(RadixTreeNode *)node value:(id)value;
-(RadixTreeNode *)searchPefix:(NSString*)key node:(RadixTreeNode *)node;
-(void)getNodes:(RadixTreeNode *)parent keys:(NSMutableArray*) keys recordLimit:(int)limit;
-(NSString*)complete:(NSString *)key node:(RadixTreeNode*)node base:(NSString *)base;
@end

/**
 * Implementation for Radix tree {@link RadixTree}
 * 
 * @author Tahseen Ur Rehman (tahseen.ur.rehman {at.spam.me.not} gmail.com)
 * @author Javid Jamae 
 * @author Dennis Heidsiek
 */

@implementation RadixTree

/**
 * Create a Radix Tree with only the default node root.
 */
-(id) init {
    self = [super init];
    if (self) {
        _root = [[RadixTreeNode alloc] init];
        _root.key = @"";
        _count = 0;
    }

    return self;
}

-(void)visit:(NSString *)prefix visitor:(Visitor *)visitor parent:(RadixTreeNode *)parent node:(RadixTreeNode *)node {
    
    int numberOfMatchingCharacters = [node numberOfMatchingCharacters:prefix];
    
    // if the node key and prefix match, we found a match!
    if (numberOfMatchingCharacters == (signed)prefix.length && numberOfMatchingCharacters == (signed)node.key.length) {
        [visitor visit:prefix parent:parent node:node];
        
    } else if (node.key.length == 0 || (numberOfMatchingCharacters < (signed)prefix.length && numberOfMatchingCharacters >= (signed)node.key.length)) {
        // either we are at the root
        // OR we need to traverse the children
        NSString *newText = [prefix substringFromIndex:(unsigned)numberOfMatchingCharacters];
        
        for (RadixTreeNode *child in node.children) {
            // recursively search the child nodes
            if ([child.key characterAtIndex:0] == [newText characterAtIndex:0]) {
                [self visit:newText visitor:visitor parent:node node:child];
                break;
            }
        }
    }
}

-(void)visit:(NSString *)key visitor:(Visitor*)visitor {
    if (_root != nil) {
        [self visit:key visitor:visitor  parent:nil  node:_root];
    }
}


-(id)find:(NSString *)key {
    Visitor *visitor = [[Visitor alloc] initWithBlock:^(Visitor *visitor, NSString *key, RadixTreeNode *parent, RadixTreeNode *node) {

        if (node.isReal) {
            visitor.result = node.value;
        }
    }];
    
    [self visit:key visitor:visitor];
    
    return visitor.result;
}

-(BOOL)delete:(NSString *)key {
    
    /**
     * Merge a child into its parent node. Operation only valid if it is
     * only child of the parent node and parent node is not a real node.
     *
     * @param parent
     *            The parent Node
     * @param child
     *            The child Node
     */
    void(^mergeNodes)(RadixTreeNode *parent, RadixTreeNode *child) = ^(RadixTreeNode *parent, RadixTreeNode *child){
        parent.key = [parent.key  stringByAppendingString:child.key];
        parent.isReal = child.isReal;
        parent.value = child.value;
        parent.children = child.children;
    };
    
    Visitor *visitor = [[Visitor alloc] initWithBlock:^(Visitor *visitor, NSString *key, RadixTreeNode *parent, RadixTreeNode *node) {
        
        visitor.result = [NSNumber numberWithBool:node.isReal];

        // if it is a real node
        if (visitor.result) {
            // If there no children of the node we need to
            // delete it from the its parent children list
            if (node.children.count == 0) {
                for (int i=0;i<parent.children.count;++i) {
                    RadixTreeNode *currentNode = parent.children[i];
                    if ([currentNode.key isEqualToString:node.key]) {
                        [parent.children removeObjectAtIndex:i];
                        break;
                    }                
                }

                // if parent is not real node and has only one child
                // then they need to be merged.
                if (parent.children.count == 1 && parent.isReal == NO) {
                    mergeNodes(parent, parent.children[0]);
                }
            } else if (node.children.count == 1) {
                // we need to merge the only child of this node with
                // itself
                mergeNodes(node, node.children[0]);
            } else { // we jus need to mark the node as non real.
                node.isReal = NO;
            }
        }
    }];
        
    [self visit:key visitor:visitor];
    if (visitor.result) {
        _count--;
    }
                        
    return [visitor.result boolValue];
}

/*
 * (non-Javadoc)
 * @see ds.tree.RadixTree#insert(java.lang.String, java.lang.Object)
 */


/**
 * Recursively insert the key in the radix tree.
 *
 * @param key The key to be inserted
 * @param node The current node
 * @param value The value associated with the key
 * @throws DuplicateKeyException If the key already exists in the database.
 */
-(BOOL)insert:(NSString *)key node:(RadixTreeNode *)node value:(id)value {
    int numberOfMatchingCharacters = [node numberOfMatchingCharacters:key];
    
    // we are either at the root node
    // or we need to go down the tree
    if (node.key.length == 0 || numberOfMatchingCharacters == 0 || (numberOfMatchingCharacters < key.length && numberOfMatchingCharacters >= node.key.length)) {
        BOOL flag = NO;
        NSString *newText = [key substringFromIndex:numberOfMatchingCharacters];
        for (RadixTreeNode *child in node.children) {
            if ([child.key characterAtIndex:0] == [newText characterAtIndex:0]) {
                flag = YES;
                [self insert:newText node:child value:value];
                break;
            }
        }
        
        // just add the node as the child of the current node
        if (flag == NO) {
            RadixTreeNode *n = [[RadixTreeNode alloc] init];
            n.key = newText;
            n.isReal = YES;
            n.value = value;
            
            [node.children addObject:n];
        }
    }    
    // there is a exact match just make the current node as data node
    else if (numberOfMatchingCharacters == key.length && numberOfMatchingCharacters == node.key.length) {
        if (node.isReal) {
            return FALSE;
        }
        
        node.isReal = YES;
        node.value = value;
    }
    // This node need to be split as the key to be inserted
    // is a prefix of the current node key
    else if (numberOfMatchingCharacters > 0 && numberOfMatchingCharacters < node.key.length) {
        RadixTreeNode *n1 = [[RadixTreeNode alloc] init];
        n1.key = [node.key substringFromIndex:numberOfMatchingCharacters];
        n1.isReal = node.isReal;
        n1.value = node.value;
        n1.children = node.children;
        
        node.key = [key substringToIndex:numberOfMatchingCharacters];
        node.isReal = NO;
        node.children = [[NSMutableArray alloc] initWithObjects:n1, nil];
        
        if (numberOfMatchingCharacters < key.length) {
            RadixTreeNode *n2 = [[RadixTreeNode alloc] init];
            n2.key = [key substringFromIndex:numberOfMatchingCharacters];
            n2.isReal = YES;
            n2.value = value;
            
            [node.children addObject:n2];
        } else {
            node.value= value;
            node.isReal= YES;
        }
    }        
    // this key need to be added as the child of the current node
    else {
        RadixTreeNode *n = [[RadixTreeNode alloc] init];
        n.key = [node.key substringFromIndex:numberOfMatchingCharacters];
        n.children = node.children;
        n.isReal = node.isReal;
        n.value = node.value;
        
        node.key = key;
        node.isReal = YES;
        node.value = value;
        
        [node.children addObject:n];
    }
    
    return TRUE;
}

-(BOOL)insert:(NSString*)key value:(id)value {
    if ([self insert:key node:_root value:value]) {
        _count++;
        return YES;
    }
    
    return NO;
}
    
 -(NSArray*)searchPrefix:(NSString *)key recordLimit:(int)maxLimit {
    NSMutableArray *keys = [[NSMutableArray alloc] init];
     
    RadixTreeNode *node = [self searchPefix:key node:_root];

    if (node != nil) {
        if (node.isReal) {
            [keys addObject:node.value];
        }
        
        [self getNodes:node keys:keys recordLimit:maxLimit];
    }

    return keys;
}

-(void)getNodes:(RadixTreeNode *)parent keys:(NSMutableArray*) keys recordLimit:(int)limit {
    NSMutableArray *queue = [[NSMutableArray alloc] initWithArray:parent.children];

    while (queue.count > 0) {
        RadixTreeNode * node = [queue dequeue];
        if (node.isReal == YES) {
            [keys addObject:node.value];
        }

        if (limit > 0 && keys.count == limit) {
            break;
        }

        [queue addObjectsFromArray:node.children];
    }
}

-(RadixTreeNode *)searchPefix:(NSString*)key node:(RadixTreeNode *)node {
    RadixTreeNode * result;

    int numberOfMatchingCharacters = [node numberOfMatchingCharacters:key];
    
    if (numberOfMatchingCharacters == key.length && numberOfMatchingCharacters <= node.key.length) {
        result = node;
    } else if (node.key.length == 0 || (numberOfMatchingCharacters < key.length && numberOfMatchingCharacters >= node.key.length)) {
        
        NSString *newText = [key substringFromIndex:numberOfMatchingCharacters];
        
        for (RadixTreeNode * child in node.children) {
            if ([child.key characterAtIndex:0] == [newText characterAtIndex:0]) {
                result = [self searchPefix:newText node:child];
                break;
            }
        }
    }

    return result;
}

-(BOOL)contains:(NSString *)key {
    Visitor *visitor = [[Visitor alloc] initWithBlock:^(Visitor *visitor, NSString *key, RadixTreeNode *parent, RadixTreeNode *node) {
        
        visitor.result = [NSNumber numberWithBool:node.isReal];
    }];

    [self visit:key visitor:visitor];

    return [visitor.result boolValue];
}

/**
 * visit the node those key matches the given key
 * @param key The key that need to be visited
 * @param visitor The visitor object
 */

/**
 * recursively visit the tree based on the supplied "key". calls the Visitor
 * for the node those key matches the given prefix
 * 
 * @param prefix
 *            The key o prefix to search in the tree
 * @param visitor
 *            The Visitor that will be called if a node with "key" as its
 *            key is found
 * @param node
 *            The Node from where onward to search
 */

-(long)size {
    return _count;
}

/**
 * Complete the a prefix to the point where ambiguity starts.
 * 
 *  Example:
 *  If a tree contain "blah1", "blah2"
 *  complete("b") -> return "blah"
 * 
 * @param prefix The prefix we want to complete
 * @return The unambiguous completion of the string.
 */
-(NSString*)complete:(NSString *)prefix {
    return [self complete:prefix node:_root base:@""];
}    
	
-(NSString*)complete:(NSString *)key node:(RadixTreeNode*)node base:(NSString *)base {
    int i = 0;
    int keylen = key.length;
    int nodelen = node.key.length;

    while (i < keylen && i < nodelen) {
        if ([key characterAtIndex:i] != [node.key characterAtIndex:i]) {
            break;
        }
        i++;
    }

    if (i == keylen && i <= nodelen) {
        return [base stringByAppendingString:node.key];
    }
    else if (nodelen == 0 || (i < keylen && i >= nodelen)) {
        NSString *beginning = [key substringToIndex:i];
        NSString *ending = [key substringFromIndex:i];
        for (RadixTreeNode * child in node.children) {
            if ([child.key characterAtIndex:0] == [ending characterAtIndex:0]) {
                return [self complete:ending node:child base:[base stringByAppendingString:beginning]];
            }
        }
    }
    
    return @"";
}

-(void)formatNodeTo:(NSMutableString*)f level:(int)level node:(RadixTreeNode *) node {
    [f appendString:@"\n"];

    for (int i = 0; i < level; i++) {
        [f appendString:@" "];
    }

    [f appendString:@"|"];
    for (int i = 0; i < level; i++) {
        [f appendString:@"-"];
    }
    
    if (node.isReal) {
        [f appendFormat:@"%@[%@]*", node.key,  node.value];
    }
    else {
        [f appendFormat:@"%@", node.key];
    }
    
    for (RadixTreeNode *child in node.children) {
        [self formatNodeTo:f level:level + 1 node:child];
    }
}

- (NSString *)description {
    NSMutableString *formatter = [[NSMutableString alloc] init];
    [self formatNodeTo:formatter level:0 node:_root];
     
    return formatter;
}

@end