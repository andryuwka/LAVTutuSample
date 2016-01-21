#import "LAVJSONConverter.h"

#pragma mark - Constants

static const NSString *kCountryTitle = @"countryTitle";
static const NSString *kPoint = @"point";
static const NSString *kLongitude = @"longitude";
static const NSString *kLatitude = @"latitude";
static const NSString *kDistrictTitle = @"districtTitle";
static const NSString *kCityId = @"cityId";
static const NSString *kCityTitle = @"cityTitle";
static const NSString *kRegionTitle = @"regionTitle";
static const NSString *kStations = @"stations";
static const NSString *kStationId = @"stationId";
static const NSString *kStationTitle = @"stationTitle";
static const NSString *kCitiesFrom = @"citiesFrom";
static const NSString *kCitiesTo = @"citiesTo";

@interface LAVJSONConverter ()

@property(nonatomic, strong, readwrite) NSDictionary *json;

@end

@implementation LAVJSONConverter

+ (LAVJSONConverter *)sharedInstance {
  static LAVJSONConverter *instance = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[LAVJSONConverter alloc] init];
  });

  return instance;
}

- (void)readJSON {

  NSString *filePath =
      [[NSBundle mainBundle] pathForResource:@"allStations" ofType:@"json"];
  NSString *jsonString =
      [[NSString alloc] initWithContentsOfFile:filePath
                                      encoding:NSUTF8StringEncoding
                                         error:NULL];

  NSError *error = nil;
  NSDictionary *json = [NSJSONSerialization
      JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                 options:kNilOptions
                   error:&error];

  self.json = json;
  // NSLog(@"%@", self.json);
}

- (NSArray *)getCities:(NSString *)direct {
  if (self.json == nil) {
    [self readJSON];
  }

  NSArray *tempCities;

  if (direct == kCitiesFrom) {
    tempCities = self.json[kCitiesFrom];
  } else if (direct == kCitiesTo) {
    tempCities = self.json[kCitiesTo];
  } else {
    NSLog(@"nillll");
    return nil;
  }

  NSMutableArray *cities = [NSMutableArray array];

  for (NSDictionary *currentCity in tempCities) {
    NSMutableArray *tempStations = [NSMutableArray array];
    NSString *tempCountryTitle = currentCity[kCountryTitle];

    LAVModelPoint *tempPoint;
    // parsing point
    NSDictionary *tempDict = currentCity[kPoint];
    if (tempDict) {
      NSInteger longtitude = [tempDict[kLongitude] doubleValue];
      NSInteger latitude = [tempDict[kLatitude] doubleValue];

      tempPoint = [LAVModelPoint pointWithLong:longtitude andLat:latitude];
    }
    // point parsed

    NSString *tempDisctrictTitle = currentCity[kDistrictTitle];
    NSInteger tempCityId = [currentCity[kCityId] integerValue];
    NSString *tempCityTitle = currentCity[kCityTitle];
    NSString *tempRegionTitle = currentCity[kRegionTitle];

    // parsing stations

    for (NSDictionary *currentStation in currentCity[kStations]) {

      NSString *countryTitle = currentStation[kCountryTitle];
      LAVModelPoint *point;
      // parsing point
      NSDictionary *pointDict = currentStation[kPoint];
      if (tempDict) {
        NSInteger longtitude = [pointDict[kLongitude] doubleValue];
        NSInteger latitude = [pointDict[kLatitude] doubleValue];

        point = [LAVModelPoint pointWithLong:longtitude andLat:latitude];
      }
      // point parsed

      NSString *disctrictTitle = currentStation[kDistrictTitle];
      NSInteger cityId = [currentStation[kCityId] integerValue];
      NSString *cityTitle = currentStation[kCityTitle];
      NSString *regionTitle = currentStation[kRegionTitle];
      NSInteger stationId = [currentStation[kStationId] integerValue];
      NSString *stationTitle = currentStation[kStationTitle];

      LAVModelStation *station =
          [LAVModelStation stationWithCountry:countryTitle
                                        point:point
                                districtTitle:disctrictTitle
                                       cityId:cityId
                                    cityTitle:cityTitle
                                  regionTitle:regionTitle
                                  statationId:stationId
                                 stationTitle:stationTitle];
      [tempStations addObject:station];
    }
    // stations parsed
    LAVModelCity *city = [LAVModelCity cityWithCityId:tempCityId
                                                point:tempPoint
                                          coutryTitle:tempCountryTitle
                                        districtTitle:tempDisctrictTitle
                                            cityTitle:tempCityTitle
                                          regionTitle:tempRegionTitle
                                             stations:tempStations];
    [cities addObject:city];
  }
  return [NSArray arrayWithArray:cities];
}

@end
