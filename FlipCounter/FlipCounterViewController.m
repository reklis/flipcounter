//
//  FlipCounterViewController.m
//  FlipCounter
//
//  Created by Steven Fusco on 10/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipCounterViewController.h"

@implementation FlipCounterViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    flipCounter = [[FlipCounterView alloc] initWithFrame:self.view.frame];
    [flipCounter add:10];
    [self.view addSubview:flipCounter];
    [flipCounter release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* t = [touches anyObject];
    CGRect f = [self.view frame];
    CGFloat midY = CGRectGetMidY(f);
    CGPoint loc = [t locationInView:self.view];
    if (midY > loc.y) {
        [flipCounter add:[touches count]];
    } else {
        [flipCounter add:-[touches count]];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[flipCounter add:[touches count]];
}

@end
