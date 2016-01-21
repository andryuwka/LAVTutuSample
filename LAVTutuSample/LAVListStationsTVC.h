#import <UIKit/UIKit.h>
#import "LAVResultsTVC.h"

@interface LAVListStationsTVC : UITableViewController 

@property (nonatomic, strong, readwrite) NSArray *cities;
@property (nonatomic, assign, readwrite) NSInteger isCitiesFrom;

@end
