//
//  NSString+Custom.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/2/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "NSString+Custom.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString(Custom)


- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end
