//
//  FlipCounterView.h
//  FlipCounter
//

#import <UIKit/UIKit.h>

@class FlipCounterViewDigitSprite;



@interface FlipCounterView : UIView
{
    @private
    NSMutableArray* topFrames;
    NSMutableArray* bottomFrames;
    int numTopFrames;
    int numBottomFrames;
    
    NSMutableArray* digits;
    
    BOOL changedWhileAnimating;
    BOOL isAnimating;
    int numDigitsToDraw;
}

- (void) add:(float)incr;

@end



@interface FlipCounterViewDigitSprite : NSObject
{
    @private
    int currentFrame;
}

- (id)initWithOldValue:(NSUInteger)o
              newValue:(NSUInteger)n
              frameTop:(NSUInteger)ft
           frameBottom:(NSUInteger)fb;

@property (readwrite,nonatomic,assign) NSUInteger topIndex;
@property (readwrite,nonatomic,assign) NSUInteger bottomIndex;
@property (readwrite,nonatomic,assign) NSUInteger oldValue;
@property (readwrite,nonatomic,assign) NSUInteger newValue;

- (float) incr:(float)inc;

- (BOOL) nextFrame:(int)from
                to:(int)to
      numTopFrames:(int)numTopFrames
   numBottomFrames:(int)numBottomFrames;

@end