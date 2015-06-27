//
//  SUItemSignature.h
//  Sparkle
//
//  Created by Jean-Daniel Dupas on 12/09/09.
//  Copyright 2009 Ninsight. All rights reserved.
//

#import "SUExport.h"

extern NSString * const SUSignatureAlgorithmSHA1WithDSA;

SU_EXPORT @interface SUItemSignature : NSObject

+ (instancetype)signatureWithAlgorithm:(NSString *)anAlgorithm string:(NSString *)base64String;
- (instancetype)initWithAlgorithm:(NSString *)anAlgorithm string:(NSString *)base64String;

@property(nonatomic, readonly) NSData *data;

@property(nonatomic, readonly) NSString *algorithm;

@end

