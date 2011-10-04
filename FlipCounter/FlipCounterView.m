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
- (void) carry:(NSUInteger)overage;
- (void) animate;

@end


@implementation FlipCounterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self loadImagePool];
        
        digitIndex.oldValue = 0;
        digitIndex.newValue = 0;
        digitIndex.currentFrame.topIndex = 0;
        digitIndex.currentFrame.bottomIndex = 0;
    }
    return self;
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
    FlipCounterViewDigitFrame digitFrame = digitIndex.currentFrame;
    UIImage* t = [topFrames objectAtIndex:digitFrame.topIndex];
    [t drawAtPoint:CGPointZero];
    
    UIImage* b = [bottomFrames objectAtIndex:digitFrame.bottomIndex];
    [b drawAtPoint:CGPointMake(0, FCV_TOPFRAME_HEIGHT)];
}

- (void) carry:(NSUInteger)overage
{
    
}

- (void) add:(NSUInteger)incr
{
    digitIndex.newValue += incr;
    while (digitIndex.newValue > 9) {
        double integral = 0;
        double fractional = modf(incr, &integral);
        NSAssert(integral < INT_MAX, @"integral overflow");
        NSAssert(fractional < INT_MAX, @"fractional overflow");
        [self carry:integral];
        digitIndex.newValue = fractional;
    }
    
    [self animate];
}

- (void)animate
{
    if (isAnimating) {
        return;
    }
    
    isAnimating = YES;
    int from = digitIndex.oldValue;
    int to = digitIndex.newValue;
    
    NSTimeInterval frameRate = .05;

    // top pattern: old 1, old 2, new 0
    // bottom pattern: old 1, new 2, new 3, new 0
    
    digitIndex.currentFrame.topIndex = (from * numTopFrames) + 1;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitIndex.currentFrame.topIndex = (from * numTopFrames) + 2;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitIndex.currentFrame.topIndex = (to * numTopFrames) + 0;
    digitIndex.currentFrame.bottomIndex = (from * numBottomFrames) + 1;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitIndex.currentFrame.bottomIndex = (to * numBottomFrames) + 2;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitIndex.currentFrame.bottomIndex = (to * numBottomFrames) + 3;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitIndex.currentFrame.bottomIndex = (to * numBottomFrames) + 0;
    [self setNeedsDisplay];
    
    digitIndex.oldValue = to;
    isAnimating = NO;
    
    if (digitIndex.newValue != to) {
        [self animate];
    }
}



@end
