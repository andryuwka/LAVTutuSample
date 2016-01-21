#import <Foundation/Foundation.h>
#import "LAVModelPoint.h"

@interface LAVModelCity : NSObject
@property(nonatomic, strong, readwrite) NSArray *stations;

@property(nonatomic, assign, readwrite) NSInteger cityId;

@property(nonatomic, strong, readwrite) LAVModelPoint *point;

@property(nonatomic, copy, readwrite) NSString *countryTitle;
@property(nonatomic, copy, readwrite) NSString *districtTitle;
@property(nonatomic, assign, readwrite) NSString *cityTitle;
@property(nonatomic, copy, readwrite) NSString *regionTitle;

+ (LAVModelCity *)cityWithCityId:(NSInteger)cityId
                           point:(LAVModelPoint *)point
                     coutryTitle:(NSString *)countryTitle
                   districtTitle:(NSString *)districtTitle
                       cityTitle:(NSString *)cityTitle
                     regionTitle:(NSString *)regionTitle
                        stations:(NSArray *)stations;

@end
