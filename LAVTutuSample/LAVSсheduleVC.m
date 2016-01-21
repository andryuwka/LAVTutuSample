#import "LAVSсheduleVC.h"
#import "LAVListStationsTVC.h"
#import "LAVSettingsTVC.h"
#import "LAVStationCell.h"
#import "LAVDetailedStationVC.h"

#pragma mark - Constants

static NSString *kCellIdentifier = @"cellID";
static NSString *kSegueFromIdentifier = @"ListCitiesFromSegueID";
static NSString *kSegueToIdentifier = @"ListCitiesToSegueID";
static NSString *kSegueSettingsIdentifier = @"SettingsSegueID";
static NSString *kSegueDetailedStationIdentifier = @"DetailedStationSegueID";
static NSString *kSegueAppInformationIdentifier = @"AppInformationSegueID";
static NSString *kCellNibName = @"LAVStationCell";
static NSString *kCitiesFrom = @"citiesFrom";
static NSString *kCitiesTo = @"citiesTo";
static NSString *kImageNameSearch = @"search.png";
static NSString *kImageNameSwap = @"replace.png";
static NSString *kImageNameBookmark = @"bookmark.png";
static NSString *kImageChoose = @"choose.png";

@interface LAVScheduleVC ()

@property(nonatomic, strong, readwrite) NSMutableArray *lastStations;
@property(nonatomic, strong, readwrite) NSArray *citiesFrom;
@property(nonatomic, strong, readwrite) NSArray *citiesTo;
@property(nonatomic, strong, readwrite) NSMutableArray *dateValues;

@property(nonatomic, strong, readwrite) NSString *currentDate;

@property(nonatomic, assign, readwrite) BOOL datasWasFetched;
@property(nonatomic, assign, readwrite) BOOL dateWasChanged;

@property(nonatomic, strong, readwrite) LAVModelCity *currentCity;
@property(nonatomic, strong, readwrite) LAVModelStation *currentStation;

@end

@implementation LAVScheduleVC

- (void)viewDidLoad {
  [super viewDidLoad];
  self.selectedDate = [NSDate date];
  self.datasWasFetched = NO;
  self.dateWasChanged = NO;

  [self initViews];
  [self initButtons];
  [self initCitiesAndStations];
  [self initObservers]; // Используем их для передачи просмотренных и выбранных станций
  [self initDataValues];
  [self initPicker];
}

#pragma mark - Helpful Methods

- (void)initViews {
  self.textFrom.delegate = self;
  self.textTo.delegate = self;

  UIImage *img = [self
      imageForBarWithColor:[UIColor colorWithRed:0.8 green:0.4 blue:0 alpha:1]];
  [self.navigationController.navigationBar
      setBackgroundImage:img
           forBarMetrics:UIBarMetricsDefault];
  [self.backView
      setBackgroundColor:[UIColor colorWithRed:0.8 green:0.4 blue:0 alpha:1]];
  self.viewListFrom.clipsToBounds = YES;
  self.viewListFrom.layer.borderWidth = 1.0f;
  self.viewListFrom.layer.cornerRadius = 3;
  self.viewListFrom.layer.borderColor = [UIColor lightGrayColor].CGColor;

  self.viewListTo.clipsToBounds = YES;
  self.viewListTo.layer.borderWidth = 1.0f;
  self.viewListTo.layer.cornerRadius = 3;
  self.viewListTo.layer.borderColor = [UIColor lightGrayColor].CGColor;

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.tableFooterView = [[UIView alloc] init];
  [self.tableView setEstimatedRowHeight:120];
  [self.tableView setRowHeight:UITableViewAutomaticDimension];
  [self.tableView registerNib:[UINib nibWithNibName:kCellNibName bundle:nil]
       forCellReuseIdentifier:kCellIdentifier];
}

- (void)initButtons {
  UIImage *imageSearch = [UIImage imageNamed:kImageNameSearch];
  UIImage *imageSwap = [UIImage imageNamed:kImageNameSwap];
  UIImage *imageBook = [UIImage imageNamed:kImageNameBookmark];
  UIImage *imageChoose = [UIImage imageNamed:kImageChoose];

  [self.buttonListFrom setImage:imageBook forState:UIControlStateNormal];
  [self.buttonListTo setImage:imageBook forState:UIControlStateNormal];
  [self.buttonSwap setImage:imageSwap forState:UIControlStateNormal];
  [self.buttonSearch setImage:imageSearch forState:UIControlStateNormal];
  [self.buttonChoose setImage:imageChoose forState:UIControlStateNormal];

  self.buttonListFrom.tintColor = [self yellowColor];
  self.buttonListTo.tintColor = [self yellowColor];
  self.buttonSearch.tintColor = [UIColor whiteColor];
  self.buttonSwap.tintColor = [UIColor whiteColor];
  self.buttonChoose.tintColor = [UIColor whiteColor];

  [self.buttonChoose setTitle:@"" forState:UIControlStateNormal];
  [self.buttonListTo setTitle:@"" forState:UIControlStateNormal];
  [self.buttonListFrom setTitle:@"" forState:UIControlStateNormal];
  [self.buttonSwap setTitle:@"" forState:UIControlStateNormal];
  [self.buttonSearch setTitle:@"" forState:UIControlStateNormal];

  self.buttonChoose.hidden = YES;
}

- (void)initCitiesAndStations {
  self.lastStations = [NSMutableArray array];
  [[LAVJSONConverter sharedInstance] readJSON];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.citiesFrom = [[LAVJSONConverter sharedInstance] getCities:kCitiesFrom];
    self.citiesTo = [[LAVJSONConverter sharedInstance] getCities:kCitiesTo];
    self.datasWasFetched = YES;
      
    //Вспоминаем последний выбранный город
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (_currentCity == nil) {
      NSInteger i = [defaults integerForKey:@"currentCity"];
      _currentCity = self.citiesFrom[i];
    }
  });
}

- (void)initObservers {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(dataReceived:)
                                               name:@"passData"
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(stationReceived:)
                                               name:@"stationViewed"
                                             object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(stationFromReceived:)
             name:@"chosenStationFrom"
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(stationToReceived:)
             name:@"chosenStationTo"
           object:nil];
}


- (void)initDataValues {
  self.dateValues = [@[
    @"Завтра",
    @"Сегодня",
    @"Выбрать..",
  ] mutableCopy];
}

- (void)initPicker {
  self.pickerView.datasource = self;
  self.pickerView.delegate = self;
  self.pickerView.sizeScaleRatio = 1;
  self.pickerView.minSizeScale = 0.2;
  self.pickerView.alphaScaleRatio = 1;
  self.pickerView.minAlphaScale = 0.3;
  self.pickerView.spacing = 20;
  self.pickerView.shouldUpdateRenderingOnlyWhenSelected = NO;
  self.pickerView.orientation = HORIZONTAL;
  [self.pickerView moveToIndex:1 animated:NO];
  [self.pickerView reloadData];
}

- (UIColor *)yellowColor {
  UIColor *yellowColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
  CGFloat yellowColorRGBA[4];
  [yellowColor getRed:&yellowColorRGBA[0]
                green:&yellowColorRGBA[1]
                 blue:&yellowColorRGBA[2]
                alpha:&yellowColorRGBA[3]];
  return yellowColor;
}

- (UIImage *)imageForBarWithColor:(UIColor *)color {
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(3, 3), NO, 0.0f);
  UIBezierPath *rectanglePath =
      [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 3, 3)];
  [color setFill];
  [rectanglePath fill];

  UIImage *im = [UIGraphicsGetImageFromCurrentImageContext()
      resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)
                     resizingMode:UIImageResizingModeTile];
  UIGraphicsEndImageContext();

  return im;
}

#pragma mark - IBActions

- (IBAction)buttonChooseClicked:(id)sender {

  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *minimumDateComponents = [calendar
      components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
        fromDate:[NSDate date]];
  [minimumDateComponents setYear:2000];
  NSDate *minDate = [NSDate date];

  _actionSheetPicker = [[ActionSheetDatePicker alloc]
       initWithTitle:@""
      datePickerMode:UIDatePickerModeDate
        selectedDate:self.selectedDate
              target:self
              action:@selector(dateWasSelected:element:)
              origin:sender];

  [(ActionSheetDatePicker *)self.actionSheetPicker setMinimumDate:minDate];

  [self.actionSheetPicker addCustomButtonWithTitle:@"Сегодня"
                                             value:[NSDate date]];
  self.actionSheetPicker.hideCancel = YES;
  [self.actionSheetPicker showActionSheetPicker];
}

- (IBAction)switchSegmentedControl:(id)sender {
  UISegmentedControl *control = (UISegmentedControl *)sender;
  if (control.selectedSegmentIndex == 0) {
    [UIView animateWithDuration:(0.3)
                     animations:^{
                       self.tableView.alpha = 1;
                       self.aboutAppView.alpha = 0;
                     }];
  } else {
    [UIView animateWithDuration:(0.3)
                     animations:^{
                       self.tableView.alpha = 0;
                       self.aboutAppView.alpha = 1;
                     }];
  }
}

- (IBAction)buttonSearchClicked:(id)sender {
  NSString *subtitle = [NSString
      stringWithFormat:
          @"Направление с %@ в %@ на %@ не найдено.",
          self.textFrom.text, self.textTo.text, self.currentDate];
  [TSMessage showNotificationWithTitle:@"Поиск"
                              subtitle:subtitle
                                  type:TSMessageNotificationTypeWarning];
}

- (IBAction)swapStations:(id)sender {
  LAVModelStation *temp = self.stationFrom;
  self.stationFrom = self.stationTo;
  self.stationTo = temp;

  NSString *tempStr = self.textTo.text;
  self.textTo.text = self.textFrom.text;
  self.textFrom.text = tempStr;
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - NSNotificationCenter Observing

- (void)dataReceived:(NSNotification *)notification {
  _currentCity = (LAVModelCity *)notification.object;
}

- (void)stationReceived:(NSNotification *)notification {
  BOOL isNew = YES;
  for (LAVModelStation *current in _lastStations) {
    if ([current isEqual:notification.object]) {
      isNew = NO;
    }
  }
  if (isNew) {
    [_lastStations addObject:(LAVModelStation *)notification.object];
    [self.tableView reloadData];
  }
}

- (void)stationToReceived:(NSNotification *)notification {
  self.stationTo = notification.object;
  self.textTo.text = self.stationTo.stationTitle;
}

- (void)stationFromReceived:(NSNotification *)notification {
  self.stationFrom = notification.object;
  self.textFrom.text = self.stationFrom.stationTitle;
}

#pragma mark - DMPickerview datasource

- (NSUInteger)numberOfLabelsForPickerView:(DMPickerView *)pickerView {
  return [self.dateValues count];
}

- (NSString *)valueLabelForPickerView:(DMPickerView *)pickerView
                              AtIndex:(NSUInteger)index {
  return self.dateValues[index];
}

- (UIFont *)fontForLabelsForPickerView:(DMPickerView *)pickerView {
  return [UIFont fontWithName:@"Helvetica-Light" size:20];
}

- (UIColor *)textColorForLabelsForPickerView:(DMPickerView *)pickerView {
  return [UIColor whiteColor];
}

#pragma mark - DMPickerview delegate

- (void)pickerView:(DMPickerView *)pickerView
    didSelectLabelAtIndex:(NSUInteger)index {
  if (index < 2) {
    _currentDate = self.dateValues[index];
    self.buttonChoose.hidden = YES;
  } else {
    self.buttonChoose.hidden = NO;
    if (self.dateWasChanged)
      _currentDate = self.dateValues[index];
  }
}

#pragma mark - DMPickerview Methods

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    self.selectedDate = selectedDate;
    NSArray *searchItems =
    [[self.selectedDate description] componentsSeparatedByString:@" "];
    self.dateValues[2] = searchItems[0];
    self.dateWasChanged = YES;
    [self.pickerView moveToIndex:2 animated:NO];
    [self.pickerView reloadData];
}


#pragma mark - TableView Delegate

- (LAVStationCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  LAVStationCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  if (!cell) {
    cell = [[LAVStationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellIdentifier];
  }
  LAVModelStation *station = _lastStations[indexPath.row];
  [cell setInfo:station];

  return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  return @"Недавно просмотренные станции";
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

  _currentStation = _lastStations[indexPath.row];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:kSegueDetailedStationIdentifier
                              sender:self];
  });
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return _lastStations.count;
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

  if ([[segue identifier] isEqualToString:kSegueFromIdentifier]) {
    LAVListStationsTVC *vc = [segue destinationViewController];
    vc.isCitiesFrom = -1;
    vc.cities = [NSArray arrayWithObject:_currentCity];
  } else if ([[segue identifier] isEqualToString:kSegueToIdentifier]) {
    LAVListStationsTVC *vc = [segue destinationViewController];
    vc.isCitiesFrom = 1;
    vc.cities = self.citiesTo;
  } else if ([[segue identifier] isEqualToString:kSegueSettingsIdentifier]) {
    LAVSettingsTVC *vc = [segue destinationViewController];
    vc.cities = self.citiesFrom;
  } else if ([[segue identifier]
                 isEqualToString:kSegueDetailedStationIdentifier]) {
    LAVDetailedStationVC *vc = [segue destinationViewController];
    vc.isStationFrom = 0;
    vc.station = _currentStation;
  }
}

#pragma mark - Other Methods
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
