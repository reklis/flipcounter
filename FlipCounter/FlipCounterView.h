//
//  FlipCounterView.h
//  FlipCounter
//
//  Created by Steven Fusco on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct FlipCounterViewDigitFrame {
    NSUInteger topIndex;
    NSUInteger bottomIndex;
} FlipCounterViewDigitFrame;

@interface FlipCounterView : UIView
{
    @private
    NSMutableArray* topFrames;
    NSMutableArray* bottomFrames;
    int numTopFrames;
    int numBottomFrames;
    
    int o;
    int n;
    FlipCounterViewDigitFrame digitFrame;
    
    BOOL isAnimating;
}

- (void) add:(NSUInteger)incr;

@end
