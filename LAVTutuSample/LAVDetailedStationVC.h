#import <UIKit/UIKit.h>
#import "LAVModelStation.h"
#import <TSMessage.h>

@interface LAVDetailedStationVC : UITableViewController

@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelStationTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelCityTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelCountryTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelDistrictTitle;
@property(nonatomic, weak, readwrite) IBOutlet UILabel *labelRegionTitle;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonChoose;
@property(nonatomic, weak, readwrite) IBOutlet UIView *mapview;
@property(nonatomic, weak, readwrite) IBOutlet UIImageView *imgView;
@property(nonatomic, weak, readwrite) IBOutlet UIProgressView *progressView;

@property(nonatomic, strong, readwrite) NSURLSessionDownloadTask *downloadTask;
@property(nonatomic, strong, readwrite) NSURLSession *session;
@property(nonatomic, strong, readwrite) NSData *resumeData;
@property(nonatomic, strong, readwrite) LAVModelStation *station;

@property(nonatomic, assign, readwrite) NSInteger isStationFrom;

@end
