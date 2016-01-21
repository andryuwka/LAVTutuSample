#import "LAVModelPoint.h"

@interface LAVModelPoint ()

@end

@implementation LAVModelPoint

+ (LAVModelPoint *)pointWithLong:(double)longitude andLat:(double)latitude {

  LAVModelPoint *point = [[LAVModelPoint alloc] init];

  point.longitude = longitude;
  point.latitude = latitude;

  return point;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"longitude: %f\nlatitude: %f\n",
                                    self.longitude, self.latitude];
}

@end
