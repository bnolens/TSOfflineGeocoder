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

@import Foundation;

@class RadixTreeNode;

@class Visitor;

typedef void (^VisitBlock)(Visitor *visitor, NSString *key, RadixTreeNode *parent, RadixTreeNode * node);

/*!
 @interface Visitor
 The visitor interface that is used by {@link RadixTreeImpl} for perfroming
 task on a searched node.
 
 @author Tahseen Ur Rehman (tahseen.ur.rehman {at.spam.me.not} gmail.com)
 @author Javid Jamae
 @author Dennis Heidsiek
 @author Shay Erlichmen
*/
@interface Visitor : NSObject

-(id)initWithBlock:(VisitBlock)visitBlock;

-(void)visit:(NSString *)key parent:(RadixTreeNode *)parent node:(RadixTreeNode *)node;

@property (nonatomic, strong) id result;

@end