//
//  random.h
//  Jasmine
//
//  Created by Qiang Li on 12-10-10.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#include <math.h>

// low accruency
#define ARC4RANDOM_MAX 0xFFFFFFFFu
//#define ARC4RANDOM_MAX_PLUS1 0x100000000u
//#define ARC4RANDOM_MAX 0x100000000u
#define ARC4RANDOM_MAX_HALF 0x80000000u

#define RANDOM_0_1 (((float)arc4random() / ARC4RANDOM_MAX))
#define RANDOM_MINUS1_1 (((float)arc4random() / ARC4RANDOM_MAX_HALF) - 1.0f)

#define RANDOM(min, max) (RANDOM_0_1 * ((float)(max)-(float)(min)) + (float)(min))
#define RANDOMI(min, max) (arc4random() % ((int)max-(int)(min)) + (int)(min))

// Box-Muller Transform
// U1 and U2 are independent random variables that are uniformly distributed in the interval (0, 1]
// Z0 = R*cos(theta) = sqrt(-2*ln(U1))*cos(2*PI*U2)
// Z1 = R*sin(theta) = sqrt(-2*ln(U1))*sin(2*PI*U2)
// Z0 and Z1 are independent random variables with a standard normal distribution.
//#define RANDOM_STD_NORMAL (sqrtf(-2*log10f(RANDOM_0_1)) * cosf(2*(float)M_PI*RANDOM_0_1))
//#define RANDOM_NORMAL(mean, variance) (RANDOM_STD_NORMAL * sqrtf((float)(variance)) + (float)(mean))

// U are uniformly distributed in the (0,1]
// Exponential distribution CDF: F(x) = 1 - exp(-lamda * x)
// Z = -(1/lamda)*ln(U)
// Z are random variable with a expoential distribution.
