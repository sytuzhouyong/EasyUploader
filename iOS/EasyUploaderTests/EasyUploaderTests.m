//
//  EasyUploaderTests.m
//  EasyUploaderTests
//
//  Created by zhouyong on 17/2/28.
//  Copyright © 2017年 zhouyong. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Common.h"

@interface EasyUploaderTests : XCTestCase

@end

@implementation EasyUploaderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString *desc = [DateUtil intelligentDateStringWithDate:[NSDate date]];
    XCTAssertTrue([desc isEqualToString:@"今天"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
