/**
 * A simple standard implementation for a {@link visitor}.
 * 
 * @author Dennis Heidsiek 
 * @param <T,R>
 */

#import "Visitor.h"

@interface Visitor() {
    VisitBlock _visitBlock;
}
@end

@implementation Visitor

-(id)initWithBlock:(VisitBlock)visitBlock {
    self = [super init];
    
    if (self) {
        _visitBlock = visitBlock;
    }
    
    return self;
}

-(void)visit:(NSString *)key parent:(RadixTreeNode *)parent node:(RadixTreeNode *)node {
    if (_visitBlock) {
        _visitBlock(self, key, parent, node);
    }
}

@end
