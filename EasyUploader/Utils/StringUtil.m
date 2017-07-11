//
//  StringUtil.m
//  XingHomecloud
//
//  Created by zhouyong on 15/12/3.
//  Copyright © 2015年 zhouyong. All rights reserved.
//

#import "StringUtil.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
//#import "GTMBase64.h"

#define gkey			@"23b1c4c08503bd4cec7af5c7476b8665"
#define gIv             @"23b1c4c08503bd4c"

@implementation StringUtil

+ (NSString *)jsonStringFromObject:(id)object options:(NSJSONWritingOptions)options {
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:options error:&error];
        if (error != nil) {
            DDLogError(@"object[%@] to json failed, error = %@", object, error);
            return nil;
        }
        
        NSString *jsonString =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

+ (NSString *)jsonStringFromObject:(id)object {
    return [self.class jsonStringFromObject:object options:NSJSONWritingPrettyPrinted];
}

+ (NSDictionary *)dictFromJsonString:(NSString *)jsonString {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error != nil) {
        DDLogError(@"json[%@] to dict failed, error = %@", jsonString, error);
        return nil;
    }
    
    return dict;
}

+ (NSString *)documentsPath {
    static NSString *documentsPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        documentsPath = documentPath[0];
    });
    return documentsPath;
}

+ (NSString *)cachePath {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachePath = cachesPath.firstObject;
    });
    return cachePath;
}

+ (NSString *)videoCachePath {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath = [[StringUtil cachePath] stringByAppendingPathComponent:@"VideoCache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    });
    return cachePath;
}

+ (NSString *)photoCachePath {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath = [[StringUtil cachePath] stringByAppendingPathComponent:@"PhotoCache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    });
    return cachePath;
}

+ (NSString *)tempPath {
    static NSString *tempPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tempPath = NSTemporaryDirectory();
    });
    return tempPath;
}

+ (NSString *)deviceName {
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    
    static NSDictionary<NSString *, NSString *> *devices = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        devices = @{@"iPhone1,1": @"iPhone1",
                    @"iPhone1,2": @"iPhone3G",
                    @"iPhone2,1": @"iPhone3GS",
                    @"iPhone3,1": @"iPhone4",
                    @"iPhone4,1": @"iPhone4S",
                    @"iPhone5,2": @"iPhone5",
                    @"iPhone5,3": @"iPhone5C",
                    @"iPhone6,1": @"iPhone5S",
                    @"iPhone6,2": @"iPhone5S",
                    @"iPhone7,1": @"iPhone6P",
                    @"iPhone7,2": @"iPhone6",
                    @"iPhone8,1": @"iPhone6S",
                    @"iPhone8,2": @"iPhone6SP",
                    @"i386":      @"Simulator",
                    @"x86_64":    @"Simulator",
                    @"iPad5,1":   @"iPad mini 4"
                    };
    });
    
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *deviceName = devices[machine];
    if (deviceName.length == 0) {
        DDLogWarn(@"oh no, unknown device type: %@", machine);
        deviceName = @"";
    }
    return deviceName;
}

+ (NSString *)smartDescriptionOfBytesNumber:(UInt64)number times:(int *)times {
    if (number <= 0) {
        *times = 0;
        return @"0";
    }
    
    *times = 0;
    UInt64 weight = 1;
    UInt64 now = number;
    while (now >= 1024) {
        now = now / 1024;
        weight *= 1024;
        *times = *times + 1;
    }
    UInt64 leftBytes = number - now * weight;
    CGFloat decimal = leftBytes * 1.0f / weight;
    CGFloat value = now + decimal;
    return [NSString stringWithFormat:@"%.1f", value];
}

+ (NSString *)descriptionOfSpace:(UInt64)space {
    static NSArray<NSString *> *units = nil;
    if (units == nil) {
        units = @[@"B", @"K", @"M", @"G", @"T", @"P"];
    }
    
    int times;
    NSString *desc = [self smartDescriptionOfBytesNumber:space times:&times];
    desc = [NSString stringWithFormat:@"%@%@", desc, units[times]];
    return desc;
}

+ (NSString *)descriptionOfSpeed:(UInt64)speed {
    static NSArray<NSString *> *units = nil;
    if (units == nil) {
        units = @[@"B/s", @"KB/s", @"MB/s", @"GB/s", @"TB/s", @"PB/s"];
    }
    
    int times;
    NSString *desc = [self smartDescriptionOfBytesNumber:speed times:&times];
    desc = [NSString stringWithFormat:@"%@%@", desc, units[times]];
    return desc;
}

/**
+ (NSString *)AES128Encrypt:(NSString *)plainText {
    int keysize = 32;
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    int count = (int)[data length];
    
    int amount = keysize - (count % keysize);
    char pad_char = (char)(amount & 0xFF);
    
    char dataPtr[count + amount];
    memcpy(dataPtr, [data bytes], count);
    for(int i = 0; i < amount; i++) {
        dataPtr[i + count] = pad_char;
    }
    
    size_t bufferSize = count + amount;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,               //No padding
                                          [gkey UTF8String],
                                          keysize,
                                          [gIv UTF8String],
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [GTMBase64 stringByEncodingData:resultData];
    }
    free(buffer);
    return nil;
}
*/
+ (NSString *)md5:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return [result copy];
}

+ (NSString *)toUnicode:(NSString *)plainText {
    NSMutableString *string = [NSMutableString string];
    
    for (int i=0; i<plainText.length; i++) {
        int ch = [plainText characterAtIndex:i];
        if (ch > 255) {
            [string appendFormat:@"%@u%x", @"\\", ch];
        } else {
            [string appendFormat:@"%c", ch];
        }
    }
    
    return [string copy];
}

@end
