//
// Created by Hammer on 1/31/16.
//

#import <Overcoat/OVCHTTPSessionManager.h>
#import <OvercoatPromiseKit/OVCHTTPSessionManager+PromiseKit.h>

@interface SKHTTPSessionManager : OVCHTTPSessionManager

@property (nonatomic, copy) NSMutableDictionary *params;

- (instancetype)init;

- (instancetype)initWithParams:(NSDictionary *)parameters;
@end
