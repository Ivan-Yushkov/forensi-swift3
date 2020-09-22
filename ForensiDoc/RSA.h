//
//  RSA.h
//  Crypto
//
//  Created by Paolo De Luca on 17/01/2016.
//  Copyright © 2016 Paolo De Luca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSA : NSObject
{
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
}

- (NSData *) encryptWithData:(NSData *)content;
- (NSData *) encryptWithString:(NSString *)content;
- (NSString *) encryptToString:(NSString *)content;

@end
