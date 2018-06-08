//
//  FLAnimatedImage+NSCoding.m
//  Flipboard
//
//  Created by Luke Scholefield on 12/22/15.
//  Copyright © 2015 Flipboard. All rights reserved.
//

#import "FLAnimatedImage+NSCoding.h"

@implementation FLAnimatedImage (NSCoding)

static NSString *const kFLAnimatedImageCodingData = @"kFLAnimatedImageCodingData";

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSData *data = [aDecoder decodeObjectForKey:kFLAnimatedImageCodingData];
    return [self initWithAnimatedGIFData:data];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.data forKey:kFLAnimatedImageCodingData];
}

@end
