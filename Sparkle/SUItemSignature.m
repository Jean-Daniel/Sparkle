//
//  SUItemSignature.m
//  Sparkle
//
//  Created by Jean-Daniel Dupas on 12/09/09.
//  Copyright 2009 Ninsight. All rights reserved.
//

#import <Sparkle/SUItemSignature.h>

NSString * const SUSignatureAlgorithmSHA1WithDSA = @"SHA1WithDSA";

@implementation SUItemSignature

@synthesize data;
@synthesize algorithm;

+ (instancetype)signatureWithAlgorithm:(NSString *)anAlgorithm string:(NSString *)base64String {
  return [[self alloc] initWithAlgorithm:anAlgorithm string:base64String];
}

- (instancetype)initWithAlgorithm:(NSString *)anAlgorithm string:(NSString *)base64String {
  if ((self = [super init])) {
    algorithm = anAlgorithm;
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber10_9) {
      data = [[NSData alloc] initWithBase64EncodedString:base64String options:(NSDataBase64DecodingOptions)0];
    } else {
      data = [[NSData alloc] initWithBase64Encoding:base64String];
    }
    if (!data)
      return nil;
  }
  return self;
}

@end
