#import <Foundation/Foundation.h>
#import "LAVModelCity.h"
#import "LAVModelStation.h"
#import "LAVModelPoint.h"

@interface LAVJSONConverter : NSObject

+ (LAVJSONConverter *)sharedInstance;

- (void)readJSON;
- (NSArray *)getCities:(NSString *)direct;

@end
