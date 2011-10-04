//
//  FlipCounterView.m
//  FlipCounter
//
//  Created by Steven Fusco on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipCounterView.h"

#define FCV_FRAME_WIDTH 53
#define FCV_TOPFRAME_HEIGHT 39
#define FCV_BOTTOMFRAME_HEIGHT 64
#define FCV_BOTTOM_START_ROW 10

@interface FlipCounterView(Private)

- (void) loadImagePool;
- (void) carry:(float)overage base:(int)base;
- (void) animate;

@end

@implementation FlipCounterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self loadImagePool];
        
        digits = [[NSMutableArray alloc] initWithCapacity:10];
        FlipCounterViewDigitSprite* sprite = [[[FlipCounterViewDigitSprite alloc] initWithOldValue:0 newValue:0 frameTop:0 frameBottom:0] autorelease];
        [digits addObject:sprite];
        
        [self animate];
    }
    return self;
}

- (void)dealloc {
    [topFrames release];
    [bottomFrames release];
    [digits release];
    
    [super dealloc];
}

- (void) loadImagePool
{
    UIImage* sprite = [UIImage imageNamed:@"digits.png"];
    CGImageRef spriteRef = [sprite CGImage];
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = FCV_FRAME_WIDTH;
    CGFloat topH = FCV_TOPFRAME_HEIGHT;
    CGFloat bottomH = FCV_BOTTOMFRAME_HEIGHT;
    
    int numCols = 4;
    int numRows = 20;
    
    numTopFrames = 3;
    int totalNumTopFrames = numTopFrames * 10;
    topFrames = [[NSMutableArray alloc] initWithCapacity:totalNumTopFrames];
    
    numBottomFrames = 4;
    int totalNumBottomFrames = numBottomFrames * 10;
    bottomFrames = [[NSMutableArray alloc] initWithCapacity:totalNumBottomFrames];
    
    int bottomRowStart = FCV_BOTTOM_START_ROW;
    for (int row=0; row!=numRows; ++row) {
        x = 0;
        BOOL isTopFrame = (row < bottomRowStart);
        CGFloat h = isTopFrame ? topH : bottomH;
        
        for (int col=0; col!=numCols; ++col) {
            if ((col == 3) && (isTopFrame)) continue; // ignore whitespace
            
            CGRect frameRect = CGRectMake(x, y, w, h);
            CGImageRef image = CGImageCreateWithImageInRect(spriteRef, frameRect);
            UIImage* imagePtr = [[UIImage alloc] initWithCGImage:image];
            
            if (isTopFrame) {
                [topFrames addObject:imagePtr];
            } else {
                [bottomFrames addObject:imagePtr];
            }
            
            [imagePtr release];
            CFRelease(image);
            
            x += w;
        }
        
        y += h;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (int i=numDigitsToDraw-1; i!=-1; --i) {
        FlipCounterViewDigitSprite* sprite = [digits objectAtIndex:i];
        
        CGFloat x = (FCV_FRAME_WIDTH * (numDigitsToDraw - i)) - FCV_FRAME_WIDTH;
        
        UIImage* t = [topFrames objectAtIndex:sprite.topIndex];
        [t drawAtPoint:CGPointMake(x, 0)];
        
        UIImage* b = [bottomFrames objectAtIndex:sprite.bottomIndex];
        [b drawAtPoint:CGPointMake(x, FCV_TOPFRAME_HEIGHT)];
    }
}

- (void) carry:(float)overhang base:(int)base
{
    FlipCounterViewDigitSprite* sprite = nil;
    
    NSUInteger digitIndex = base + 1;
    if ([digits count] > digitIndex) {
        sprite = [digits objectAtIndex:digitIndex];
    } else {
        sprite = [[FlipCounterViewDigitSprite alloc] initWithOldValue:0
                                                             newValue:0
                                                             frameTop:0
                                                          frameBottom:0];
        [digits addObject:sprite];
        [sprite release];
    }
    
    float o = [sprite incr:overhang/10.];
    
    if (o != 0) {
        [self carry:o base:base+1];
    }
}

- (void) add:(float)i
{
    FlipCounterViewDigitSprite* digitIndex = [digits objectAtIndex:0];
    
    float overhang = [digitIndex incr:i];
    
    if (overhang != 0) {
        [self carry:overhang base:0];
    }
    
    [self animate];
}

- (void) animate
{
    if (isAnimating) {
        changedWhileAnimating = YES;
        return;
    }
    
    isAnimating = YES;
    numDigitsToDraw = [digits count];
    NSArray* sprites = [digits copy];
    NSTimeInterval frameRate = .05;

    for (FlipCounterViewDigitSprite* sprite in sprites) {
        int from = sprite.oldValue;
        int to = sprite.newValue;
        if (from == to) continue; // skip sprites that have not changed
        
        BOOL spriteAnimationComplete = FALSE;
        while (!spriteAnimationComplete) {
            spriteAnimationComplete = [sprite nextFrame:from
                                                     to:to
                                           numTopFrames:numTopFrames
                                        numBottomFrames:numBottomFrames];
            [self setNeedsDisplay];
            NSDate* nextFrameTime = [NSDate dateWithTimeIntervalSinceNow:frameRate];
            [[NSRunLoop currentRunLoop] runUntilDate:nextFrameTime];
        }
        
        sprite.oldValue = to;
    }
    
    isAnimating = NO;
    while (changedWhileAnimating) {
        changedWhileAnimating = NO;
        [self animate];
    }
}

@end




@implementation FlipCounterViewDigitSprite

@synthesize oldValue=_oldValue;
@synthesize newValue=_newValue;
@synthesize topIndex=_topIndex;
@synthesize bottomIndex=_bottomIndex;

- (id)initWithOldValue:(NSUInteger)o newValue:(NSUInteger)n frameTop:(NSUInteger)ft frameBottom:(NSUInteger)fb
{
    self = [super init];
    if (self) {
        _oldValue = o;
        _newValue = n;
        _topIndex = ft;
        _bottomIndex = fb;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(o:%d n:%d t:%d b:%d)", _oldValue, _newValue, _topIndex, _bottomIndex];
}

- (float) incr:(float)inc
{
    float i1 = 0;
    float f1 = modff(inc/10., &i1);
    
    float overhang = i1;
    float v = _newValue + floorf(f1 * 10.);
    if (v > 9) {
        float i2 = 0;
        float f2 = modff(v, &i2);
        overhang += i2;
        v = floorf(f2 * 10.);
    }
    
    _newValue = v;
    return overhang;
}

- (BOOL) nextFrame:(int)from
                to:(int)to
      numTopFrames:(int)numTopFrames
   numBottomFrames:(int)numBottomFrames
{
    ++currentFrame;
    if (currentFrame > 5) {
        currentFrame = 0;
    }
    
    // top pattern: old 1, old 2, new 0
    // bottom pattern: old 1, new 2, new 3, new 0
    
    switch (currentFrame) {
        case 0:
            _topIndex = (from * numTopFrames) + 1;
            break;
        case 1:
            _topIndex = (from * numTopFrames) + 2;
            break;
        case 2:
            _topIndex = (to * numTopFrames) + 0;
            _bottomIndex = (from * numBottomFrames) + 1;
            break;
        case 3:
            _bottomIndex = (to * numBottomFrames) + 2;
            break;
        case 4:
            _bottomIndex = (to * numBottomFrames) + 3;
            break;
        case 5:
            _bottomIndex = (to * numBottomFrames) + 0;
            break;
            
        default:
            break;
    }
    
    return (currentFrame == 5);
}

@end