//
//  SDKSolver.m
//
//  Based on code created by Benny Pollak on 1/22/11.
//  Copyright 2011 Alben Software. All rights reserved.
//

#import "SDKSolver.h"

@implementation SDKSolver

#pragma mark Init

- (id)initWithNewGrid
{
    self = [super init];
    
	if (self)
    {
        if (self)
        {
            for (int i=0; i<9; i++)
            {
                int num;
                do {
                    num = (arc4random() % 9) + 1;
                } while (![self isNumValid:num atX:i atY:0]);
                puzzle[i][0] = num;
            }
        }        
	}
	
    return self;
}

- (id)initWithArray:(int[9][9])array
{
	self = [super init];
    
	if (self)
    {
		for (int i=0; i<9; i++)
        {
			for (int j=0; j<9; j++)
				puzzle[i][j]=array[i][j];
		}
	}
    
	return self;
}

#pragma mark - Solve

- (BOOL)solve
{
    for (int i=0; i<9; i++)
    {
        for (int j=0; j<9; j++)
        {
            if (![self solveForX:i forY:j])
                return NO;
        }
    }
    
    return YES;
}

- (BOOL)solveForX:(int)x forY:(int)y
{
    if (y >= 9)
        return YES;
    else if (x >= 9)
        return [self solveForX:0 forY:y+1];
    else if (puzzle[x][y] != 0)
        return [self solveForX:x+1 forY:y];
    
    for (int num = 1; num <= 9; num++)
    {
        if ([self isNumValid:num atX:x atY:y])
        {
            puzzle[x][y] = num;
            if ([self solveForX:x+1 forY:y])
                return YES;
        }
    }
    
    puzzle[x][y]=0;
    
    return NO;
}

#pragma mark - Valid checks

- (BOOL)isNumValid:(int)num atX:(int)x atY:(int)y
{
	BOOL isValid = [self isNumValid:num rowAtX:x] && [self isNumValid:num colAtY:y] && [self isNumValid:num squareAtX:x atY:y];
    
	return isValid;
}

- (BOOL)isNumValid:(int)num rowAtX:(int)x
{
	for (int col = 0; col < 9; col++)
    {
		if (abs(puzzle[x][col]) == num) return NO;
	}
    
	return YES;
}

- (BOOL)isNumValid:(int)num colAtY:(int)y
{
	for (int row = 0; row < 9; row++)
    {
		if (abs(puzzle[row][y]) == num) return NO;
	}
    
	return YES;
}

- (BOOL)isNumValid:(int)num squareAtX:(int)x atY:(int)y
{
	int r1 = (x / 3) * 3;
	int c1 = (y / 3) * 3;
	for (int r = r1; r < r1+3; r++)
    {
		for (int c = c1; c < c1+3; c++)
        {
			if (abs(puzzle[r][c]) == num) return NO;
		}
	}
    
	return YES;
}

#pragma mark - Values

- (int)valueAtX:(int)x atY:(int)y
{
	return puzzle[x][y];
}

- (void)setValue:(int)value atX:(int)x atY:(int)y
{
	puzzle[x][y] = value;
}

@end