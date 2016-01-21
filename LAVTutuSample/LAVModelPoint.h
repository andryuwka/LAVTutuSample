#import <Foundation/Foundation.h>

@interface LAVModelPoint : NSObject

@property(nonatomic, assign, readwrite) double longitude;
@property(nonatomic, assign, readwrite) double latitude;

+ (LAVModelPoint *)pointWithLong:(double)longitude andLat:(double)latitude;
- (NSString *)description;

@end
