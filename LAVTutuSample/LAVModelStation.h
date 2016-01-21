#import <Foundation/Foundation.h>
#import "LAVModelPoint.h"

@interface LAVModelStation : NSObject

@property(nonatomic, strong, readwrite) LAVModelPoint *point;

@property(nonatomic, assign, readwrite) NSInteger cityId;
@property(nonatomic, assign, readwrite) NSInteger stationId;

@property(nonatomic, copy, readwrite) NSString *countryTitle;
@property(nonatomic, copy, readwrite) NSString *districtTitle;
@property(nonatomic, copy, readwrite) NSString *cityTitle;
@property(nonatomic, copy, readwrite) NSString *regionTitle;
@property(nonatomic, copy, readwrite) NSString *stationTitle;

+ (LAVModelStation *)stationWithCountry:(NSString *)countryTitle
                                  point:(LAVModelPoint *)point
                          districtTitle:(NSString *)districtTitle
                                 cityId:(NSInteger)cityId
                              cityTitle:(NSString *)cityTitle
                            regionTitle:(NSString *)regionTitle
                            statationId:(NSInteger)stationId
                           stationTitle:(NSString *)stationTitle;

@end
