#import <UIKit/UIKit.h>
#import "LAVModelCity.h"

@interface LAVCityCell : UITableViewCell

@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelCityTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelCountryTitle;
@property(nonatomic, strong, readwrite) LAVModelCity *city;

- (void)setInfo:(LAVModelCity *)city;

@end
