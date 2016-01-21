#import "LAVSettingsTVC.h"
#import "LAVModelCity.h"
#import "LAVCityCell.h"

#pragma mark - Constants

static NSString *kCellIdentifier = @"cellID";
static NSString *kCellNibName = @"LAVCityCell";
static NSString *kImageNameCheckmark = @"checkmark.png";

@interface LAVSettingsTVC ()
@property(nonatomic, strong, readwrite) LAVModelCity *currentCity;

@end

@implementation LAVSettingsTVC

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.tableFooterView = [[UIView alloc] init];
  [self.tableView setEstimatedRowHeight:50];
  [self.tableView setRowHeight:UITableViewAutomaticDimension];
  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  [self.navigationController.navigationBar setTitleTextAttributes:@{
    NSForegroundColorAttributeName : [UIColor whiteColor]
  }];

  [self.tableView registerNib:[UINib nibWithNibName:kCellNibName bundle:nil]
       forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  //Вспоминаем последний выбранный город и скролим tableView
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSInteger row = [defaults integerForKey:@"row"];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  [self.tableView scrollToRowAtIndexPath:indexPath
                        atScrollPosition:UITableViewScrollPositionMiddle
                                animated:NO];
  [self selectionCellForIndexPath:indexPath];
}

#pragma mark - IBActions

- (IBAction)closeSetting:(id)sender {
  [self returnChosenCity];
}

#pragma mark - Helpful Methods

- (void)selectionCellForIndexPath:(NSIndexPath *)indexPath {
  LAVCityCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [UIView animateWithDuration:0.1
                   animations:^{
                     cell.accessoryView.tintColor = [self yellowColor];
                   }];
  _currentCity = cell.city;
}

- (void)deselectionCellForIndexPath:(NSIndexPath *)indexPath {
  LAVCityCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [UIView animateWithDuration:0.1
                   animations:^{
                     cell.accessoryView.tintColor = [UIColor lightGrayColor];
                   }];
}

- (void)returnChosenCity {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"passData"
                                                      object:_currentCity];
  [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return _cities.count;
}

#pragma mark - TableView Delegate

- (LAVCityCell *)tableView:(UITableView *)tableView
     cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  LAVCityCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (!cell) {
    cell = [[LAVCityCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:kCellIdentifier];
  }

  UIImage *mark = [UIImage imageNamed:kImageNameCheckmark];
  UIImage *markImage =
      [mark imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  UIImageView *checkmark = [[UIImageView alloc] initWithImage:markImage];

  checkmark.tintColor = [UIColor lightGrayColor];
  cell.accessoryView = checkmark;
  LAVModelCity *city = _cities[indexPath.row];
  [cell setInfo:city];

  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSInteger row = [defaults integerForKey:@"row"];
  NSIndexPath *idx = [NSIndexPath indexPathForRow:row inSection:0];

  [self deselectionCellForIndexPath:idx];
  [self selectionCellForIndexPath:indexPath];

  [defaults setInteger:indexPath.row forKey:@"row"];
  [defaults setInteger:indexPath.row forKey:@"currentCity"];
  [defaults synchronize];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  return @"Текущий город для поиска";
}

#pragma mark - Other Methods

- (UIColor *)yellowColor {
  UIColor *yellowColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
  CGFloat yellowColorRGBA[4];
  [yellowColor getRed:&yellowColorRGBA[0]
                green:&yellowColorRGBA[1]
                 blue:&yellowColorRGBA[2]
                alpha:&yellowColorRGBA[3]];
  return yellowColor;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
