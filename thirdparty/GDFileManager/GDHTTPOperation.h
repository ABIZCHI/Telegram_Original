//
//  GDParentOperation.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 4/07/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDHTTPClient, MT_AFHTTPRequestOperation;

#import "GDParentOperation.h"
#import "thirdparty/AFNetworking/MT_AFHTTPRequestOperation.h"

extern NSString * const GDHTTPStatusErrorDomain;

@interface GDHTTPOperation : GDParentOperation

@property (nonatomic, strong, readonly) GDHTTPClient *client;
@property (nonatomic, strong) NSMutableURLRequest *urlRequest;
@property (nonatomic) BOOL requiresAuthentication;
@property (nonatomic) BOOL retryOnStandardErrors;

@property (nonatomic, strong, readonly) void (^success)(MT_AFHTTPRequestOperation *requestOperation, id responseObject);
@property (nonatomic, strong, readonly) void (^failure)(MT_AFHTTPRequestOperation *requestOperation, NSError *error);

@property (nonatomic, strong) BOOL (^shouldRetryAfterError)(NSError *error);
@property (nonatomic, strong) void (^configureOperationBlock)(MT_AFHTTPRequestOperation *requestOperation);

- (id)initWithClient:(GDHTTPClient *)client urlRequest:(NSMutableURLRequest *)urlRequest
             success:(void (^)(MT_AFHTTPRequestOperation *requestOperation, id responseObject))success
             failure:(void (^)(MT_AFHTTPRequestOperation *requestOperation, NSError *error))failure;


@end
