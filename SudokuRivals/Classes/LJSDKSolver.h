//
//  LJSDKSolver.h
//  SudokuRivals
//
//  Created by Tennyson Hinds on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJSDKSolver: NSObject
{
	int puzzle[9][9];
}

- (id)initWithNewGrid;
- (id)initWithArray:(int[9][9])array;

- (BOOL)solve;
- (BOOL)solveForX:(int)x forY:(int)y;

- (BOOL)isNumValid:(int)num atX:(int)x atY:(int)y;
- (BOOL)isNumValid:(int)num rowAtX:(int)x;
- (BOOL)isNumValid:(int)num colAtY:(int)y;
- (BOOL)isNumValid:(int)num squareAtX:(int)x atY:(int)y;

- (int)valueAtX:(int)x atY:(int)y;
- (void)setValue:(int)value atX:(int)x atY:(int)y;

@end