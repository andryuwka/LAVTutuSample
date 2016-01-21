#import "LAVModelCity.h"

@interface LAVModelCity ()

@end

@implementation LAVModelCity

+ (LAVModelCity *)cityWithCityId:(NSInteger)cityId
                           point:(LAVModelPoint *)point
                     coutryTitle:(NSString *)countryTitle
                   districtTitle:(NSString *)districtTitle
                       cityTitle:(NSString *)cityTitle
                     regionTitle:(NSString *)regionTitle
                        stations:(NSArray *)stations {

  LAVModelCity *city = [[LAVModelCity alloc] init];

  city.cityId = cityId;
  city.point = point;
  city.countryTitle = countryTitle;
  city.districtTitle = districtTitle;
  city.cityTitle = cityTitle;
  city.regionTitle = regionTitle;
  city.stations = stations;

  return city;
}

- (NSString *)description {
  return [NSString
      stringWithFormat:@"cityId: %lu\npoint: %@\ncountryTitle: "
                       @"%@\ndistrictTitle: %@\ncityTitle: "
                       @"%@\nregionTitle: %@\nstations count: %lu\n",
                       (long)self.cityId, self.point, self.countryTitle,
                       self.districtTitle, self.cityTitle, self.regionTitle,
                       self.stations.count];
}

@end
