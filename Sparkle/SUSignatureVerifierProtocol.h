//
//  SUSignatureVerifierProtocol.h
//  Sparkle
//
//  Created by Jean-Daniel Dupas on 12/09/09.
//  Copyright 2009 Ninsight. All rights reserved.
//

#import "SUExport.h"

@class SUAppcastItem;
SU_EXPORT @protocol SUSignatureVerifier

- (BOOL)verifyItem:(SUAppcastItem *)anItem atURL:(NSURL *)anURL;

@end
