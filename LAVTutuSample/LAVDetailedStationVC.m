#import "LAVDetailedStationVC.h"

@interface LAVDetailedStationVC ()

@end

@implementation LAVDetailedStationVC

- (void)viewDidLoad {
  [super viewDidLoad];
  if (self.isStationFrom == 0) {
    _buttonChoose.hidden = YES;
  }
  [self.tableView setEstimatedRowHeight:100];
  [self.tableView setRowHeight:UITableViewAutomaticDimension];

  [self initViews];
}

#pragma mark - Helpful Methods

- (void)initViews {
  _labelStationTitle.text = self.station.stationTitle;
  _labelCityTitle.text = self.station.cityTitle;
  _labelCountryTitle.text = self.station.countryTitle;
  _labelDistrictTitle.text = self.station.districtTitle;
  _labelRegionTitle.text = self.station.regionTitle;

  _buttonChoose.clipsToBounds = YES;
  _buttonChoose.layer.borderWidth = 1.0f;
  _buttonChoose.layer.cornerRadius = 5;
  _buttonChoose.layer.borderColor = [UIColor lightGrayColor].CGColor;

  self.imgView.hidden = YES;

  NSURLSessionConfiguration *sessionConfiguration =
      [NSURLSessionConfiguration defaultSessionConfiguration];
  self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                               delegate:self
                                          delegateQueue:nil];

  NSString *staticMapUrl = [NSString
      stringWithFormat:
          @"https://maps.google.com/maps/api/"
          @"staticmap?markers=color:red|%f,%f&%@&maptype=hybrid&sensor=true",
          self.station.point.latitude, self.station.point.longitude,
          @"zoom=14&size=600x220"];

  NSURL *mapUrl = [NSURL
      URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:
                                      NSUTF8StringEncoding]];
  self.downloadTask = [self.session downloadTaskWithURL:mapUrl];
  [self.downloadTask resume];
}

#pragma mark - URLSession Delegate

- (void)URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location {
  NSData *data = [NSData dataWithContentsOfURL:location];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.progressView.hidden = YES;
    self.mapview.hidden = YES;
    self.imgView.hidden = NO;
    [self.imgView setImage:[UIImage imageWithData:data]];
  });
  [self.session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  float progress =
      (double)totalBytesWritten / (double)totalBytesExpectedToWrite;

  dispatch_async(dispatch_get_main_queue(), ^{
    [self.progressView setProgress:progress];
  });
}

#pragma mark - IBActions

- (IBAction)buttonChooseClicked:(id)sender {

  NSString *subtitle =
      [NSString stringWithFormat:@"%@\n%@", self.station.stationTitle,
                                 self.station.cityTitle];
  [TSMessage showNotificationWithTitle:@"Выбранная станция:"
                              subtitle:subtitle
                                  type:TSMessageNotificationTypeSuccess];
  [self returnChosenStation];
}

- (void)returnChosenStation {
  if (self.isStationFrom) {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"chosenStationFrom"
                      object:self.station];
  } else {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"chosenStationTo"
                      object:self.station];
  }
}

#pragma mark - TableView Methods

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return 140.0;
  }
  return 70;
}

#pragma mark - Other Methods

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
