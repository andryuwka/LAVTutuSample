#import "LAVResultsTVC.h"
#import "LAVModelStation.h"
#import "LAVModelCity.h"
#import "LAVStationCell.h"
#import "LAVDetailedStationVC.h"

#pragma mark - Constants

static NSString *kCellIdentifier = @"cellID";
static NSString *kSegueDetailedStationIdentifier = @"DetailedStationSegueID";
static NSString *kCellNibName = @"LAVStationCell";

@interface LAVResultsTVC ()

@property(nonatomic, strong, readwrite) UISearchController *searchController;
@property(nonatomic, strong, readwrite) LAVModelStation *currentStation;

@end

@implementation LAVResultsTVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.tableFooterView = [[UIView alloc] init];

  [self.tableView setEstimatedRowHeight:120];
  [self.tableView setRowHeight:UITableViewAutomaticDimension];

  [self.tableView registerNib:[UINib nibWithNibName:kCellNibName bundle:nil]
       forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - Returning methods for NSNotificationCenter
- (void)returnViewedStation {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"stationViewed"
                                                      object:_currentStation];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.filteredStations.count;
}

#pragma mark - TableView Delegate

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  return @"Результаты поиска:";
}

- (LAVStationCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  LAVStationCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (!cell) {
    cell = [[LAVStationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellIdentifier];
  }

  LAVModelStation *station = _filteredStations[indexPath.row];
  [cell setInfo:station];
  return cell;
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

  if ([[segue identifier] isEqualToString:kSegueDetailedStationIdentifier]) {
    LAVDetailedStationVC *vc = [segue destinationViewController];
    vc.station = _currentStation;
  }
}

#pragma mark - Other Methods

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
