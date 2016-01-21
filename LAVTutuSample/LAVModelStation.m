#import "LAVModelStation.h"

@interface LAVModelStation ()

@end

@implementation LAVModelStation

+ (LAVModelStation *)stationWithCountry:(NSString *)countryTitle
                                  point:(LAVModelPoint *)point
                          districtTitle:(NSString *)districtTitle
                                 cityId:(NSInteger)cityId
                              cityTitle:(NSString *)cityTitle
                            regionTitle:(NSString *)regionTitle
                            statationId:(NSInteger)stationId
                           stationTitle:(NSString *)stationTitle {

  LAVModelStation *station = [[LAVModelStation alloc] init];

  station.countryTitle = countryTitle;
  station.point = point;
  station.districtTitle = districtTitle;
  station.cityId = cityId;
  station.cityTitle = cityTitle;
  station.regionTitle = regionTitle;
  station.stationId = stationId;
  station.stationTitle = stationTitle;

  return station;
}

- (NSString *)description {
  return [NSString
      stringWithFormat:@"countryTitle: %@ \npoint: %@ \ndistrictTitle: "
                       @"%@ \n cityId: %lu \ncityTitle: %@ \nregionTitle: "
                       @"%@ \nstationId: %lu \nstationTitle: %@\n",
                       self.countryTitle, self.point, self.districtTitle,
                       (long)self.cityId, self.cityTitle, self.regionTitle,
                       (long)self.stationId, self.stationTitle];
}

@end
