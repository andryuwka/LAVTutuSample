#import <UIKit/UIKit.h>
#import "LAVModelStation.h"

@interface LAVStationCell : UITableViewCell

@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelStationTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelCityTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelCountryTitle;

- (void)setInfo:(LAVModelStation *)station;

@end
