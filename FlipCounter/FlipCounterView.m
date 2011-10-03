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

@implementation FlipCounterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        
        int bottomRowStart = 10;
        for (int row=0; row!=numRows; ++row) {
            x = 0;
            BOOL isTopFrame = (row < bottomRowStart);
            CGFloat h = isTopFrame ? topH : bottomH;
            
            for (int col=0; col!=numCols; ++col) {
                if ((col == 3) && (row < bottomRowStart)) continue; // ignore whitespace
                
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
        
        digitFrame.topIndex = 0;
        digitFrame.bottomIndex = 0;
        
        o = 0;
        n = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* t = [topFrames objectAtIndex:digitFrame.topIndex];
    [t drawAtPoint:CGPointZero];
    
    UIImage* b = [bottomFrames objectAtIndex:digitFrame.bottomIndex];
    [b drawAtPoint:CGPointMake(0, FCV_TOPFRAME_HEIGHT)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSTimeInterval frameRate = .05;
    
    // top pattern: old 1, old 2, new 0
    // bottom pattern: old 1, new 2, new 3, new 0
    
    digitFrame.topIndex = (o * numTopFrames) + 1;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];

    digitFrame.topIndex = (o * numTopFrames) + 2;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];

    digitFrame.topIndex = (n * numTopFrames) + 0;
    digitFrame.bottomIndex = (o * numBottomFrames) + 1;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitFrame.bottomIndex = (n * numBottomFrames) + 2;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitFrame.bottomIndex = (n * numBottomFrames) + 3;
    [self setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:frameRate]];
    
    digitFrame.bottomIndex = (n * numBottomFrames) + 0;
    [self setNeedsDisplay];
    
    o = n;
    ++n;
    
    if (n >= 10) {
        n=0;
    }
}

@end
