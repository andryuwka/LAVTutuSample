#import "LAVListStationsTVC.h"
#import "LAVResultsTVC.h"
#import "LAVJSONConverter.h"
#import "LAVModelCity.h"

#import "LAVDetailedStationVC.h"
#import "LAVStationCell.h"

#pragma mark - Constants

static NSString *kCellIdentifier = @"cellID";
static NSString *kSegueDetailedStationIdentifier = @"DetailedStationSegueID";
static NSString *kCellNibName = @"LAVStationCell";

@interface LAVListStationsTVC () <
    UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property(nonatomic, strong, readwrite) LAVModelStation *currentStation;
@property(nonatomic, strong, readwrite) UISearchController *searchController;
@property(nonatomic, strong, readwrite) LAVResultsTVC *resultsTVC;
@property(nonatomic, strong, readwrite) NSArray *listOfStations;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation LAVListStationsTVC

#pragma mark -
- (void)viewDidLoad {
  [super viewDidLoad];
  [self initTableAndSearchViews];
  [self makeListOfStations];
    
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (self.searchControllerWasActive) {
    self.searchController.active = self.searchControllerWasActive;
    _searchControllerWasActive = NO;

    if (self.searchControllerSearchFieldWasFirstResponder) {
      [self.searchController.searchBar resignFirstResponder];
      _searchControllerSearchFieldWasFirstResponder = NO;
    }
  }
}

- (void)initTableAndSearchViews {
  _resultsTVC = [[LAVResultsTVC alloc] init];
  self.resultsTVC.tableView.delegate = self;
  _searchController =
      [[UISearchController alloc] initWithSearchResultsController:_resultsTVC];

  self.searchController.searchResultsUpdater = self;
  self.searchController.delegate = self;
  self.searchController.dimsBackgroundDuringPresentation = NO;
  self.searchController.searchBar.delegate = self;
  [self.searchController.searchBar sizeToFit];
  self.searchController.hidesNavigationBarDuringPresentation = NO;

  [self.tableView setEstimatedRowHeight:120];
  [self.tableView setRowHeight:UITableViewAutomaticDimension];
  [self.tableView registerNib:[UINib nibWithNibName:kCellNibName bundle:nil]
       forCellReuseIdentifier:kCellIdentifier];
  self.tableView.tableHeaderView = self.searchController.searchBar;
  self.definesPresentationContext = YES;
}

#pragma mark - Helpful Methods

- (void)makeListOfStations {
  NSMutableArray *result = [NSMutableArray array];

  for (int i = 0; i < _cities.count; ++i) {
    LAVModelCity *c = _cities[i];
    [result addObjectsFromArray:c.stations];
  }
  // сортируем итоговый массив
  [result sortUsingComparator:^NSComparisonResult(id _Nonnull obj1,
                                                  id _Nonnull obj2) {
    LAVModelStation *st1 = obj1;
    LAVModelStation *st2 = obj2;

    NSString *str1 = st1.stationTitle;
    NSString *str2 = st2.stationTitle;
    if (str1 < str2)
      return NSOrderedAscending;
    if (str1 > str2)
      return NSOrderedDescending;
    return [str1 localizedCompare:str2];
  }];

  self.listOfStations = [NSArray arrayWithArray:result];
}

#pragma mark - Returning methods for NSNotificationCenter

- (void)returnViewedStation {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"stationViewed"
                                                      object:_currentStation];
}

#pragma mark - SearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  LAVModelCity *city = _cities[section];
  return [city.stations count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _cities.count;
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

  LAVModelCity *c = self.cities[indexPath.section];
  LAVModelStation *s = c.stations[indexPath.row];
  [cell setInfo:s];

  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.tableView) {
    LAVModelCity *c = _cities[indexPath.section];
    _currentStation = c.stations[indexPath.row];
  } else {
    _currentStation = self.resultsTVC.filteredStations[indexPath.row];
  }

  [self returnViewedStation];
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:kSegueDetailedStationIdentifier
                              sender:self];
  });
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {

  LAVModelCity *c = self.cities[section];
  return c.cityTitle;
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

  if ([[segue identifier] isEqualToString:kSegueDetailedStationIdentifier]) {
    LAVDetailedStationVC *vc = [segue destinationViewController];
    vc.isStationFrom = self.isCitiesFrom;
    vc.station = _currentStation;
  }
}

#pragma mark - SearchResults Updating

- (void)updateSearchResultsForSearchController:
    (UISearchController *)searchController {
  NSString *searchText = searchController.searchBar.text;

  // убираем все начальные и конечные пробелы
  NSString *strippedString = [searchText
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

  // разбиваем поисковой запрос по токенам
  NSArray *searchItems = nil;
  if (strippedString.length > 0) {
    searchItems = [strippedString componentsSeparatedByString:@" "];
  }

  NSMutableArray *andMatchPredicates = [NSMutableArray array];
  NSMutableArray *searchResults = [self.listOfStations mutableCopy];

  for (NSString *searchString in searchItems) {
    NSMutableArray *searchItemsPredicate = [NSMutableArray array];

    // поиск по cityTitle
    NSExpression *lhs = [NSExpression expressionForKeyPath:@"cityTitle"];
    NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
    NSPredicate *finalPredicate = [NSComparisonPredicate
        predicateWithLeftExpression:lhs
                    rightExpression:rhs
                           modifier:NSDirectPredicateModifier
                               type:NSContainsPredicateOperatorType
                            options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];

    // поиск по countryTitle
    lhs = [NSExpression expressionForKeyPath:@"countryTitle"];
    rhs = [NSExpression expressionForConstantValue:searchString];
    finalPredicate = [NSComparisonPredicate
        predicateWithLeftExpression:lhs
                    rightExpression:rhs
                           modifier:NSDirectPredicateModifier
                               type:NSContainsPredicateOperatorType
                            options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];

    // поиск по districtTitle
    lhs = [NSExpression expressionForKeyPath:@"districtTitle"];
    rhs = [NSExpression expressionForConstantValue:searchString];
    finalPredicate = [NSComparisonPredicate
        predicateWithLeftExpression:lhs
                    rightExpression:rhs
                           modifier:NSDirectPredicateModifier
                               type:NSContainsPredicateOperatorType
                            options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];

    // поиск stationTitle
    lhs = [NSExpression expressionForKeyPath:@"stationTitle"];
    rhs = [NSExpression expressionForConstantValue:searchString];
    finalPredicate = [NSComparisonPredicate
        predicateWithLeftExpression:lhs
                    rightExpression:rhs
                           modifier:NSDirectPredicateModifier
                               type:NSContainsPredicateOperatorType
                            options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];

    // поиск по regionTitle
    lhs = [NSExpression expressionForKeyPath:@"regionTitle"];
    rhs = [NSExpression expressionForConstantValue:searchString];
    finalPredicate = [NSComparisonPredicate
        predicateWithLeftExpression:lhs
                    rightExpression:rhs
                           modifier:NSDirectPredicateModifier
                               type:NSContainsPredicateOperatorType
                            options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];

    // Все предикаты поиска объединяем по операции OR в главный AND предикат
    NSCompoundPredicate *orMatchPredicates =
        [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
    [andMatchPredicates addObject:orMatchPredicates];
  }
  // Составляем итоговый предикат для поиска
  NSCompoundPredicate *finalCompoundPredicate =
      [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];

  // Фильтруем результаты и обновляем tableView
  LAVResultsTVC *tableController =
      (LAVResultsTVC *)self.searchController.searchResultsController;
  tableController.filteredStations =
      [searchResults filteredArrayUsingPredicate:finalCompoundPredicate];
  [tableController.tableView reloadData];
}

#pragma mark - UIStateRestoration(Tips and Tricks from AppleReference)

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
  [super encodeRestorableStateWithCoder:coder];

  // encode the view state so it can be restored later

  // encode the title
  [coder encodeObject:self.title forKey:ViewControllerTitleKey];

  UISearchController *searchController = self.searchController;

  // encode the search controller's active state
  BOOL searchDisplayControllerIsActive = searchController.isActive;
  [coder encodeBool:searchDisplayControllerIsActive
             forKey:SearchControllerIsActiveKey];

  // encode the first responser status
  if (searchDisplayControllerIsActive) {
    [coder encodeBool:[searchController.searchBar isFirstResponder]
               forKey:SearchBarIsFirstResponderKey];
  }

  // encode the search bar text
  [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
  [super decodeRestorableStateWithCoder:coder];

  // restore the title
  self.title = [coder decodeObjectForKey:ViewControllerTitleKey];

  // restore the active state:
  // we can't make the searchController active here since it's not part of the
  // view
  // hierarchy yet, instead we do it in viewWillAppear
  //
  _searchControllerWasActive =
      [coder decodeBoolForKey:SearchControllerIsActiveKey];

  // restore the first responder status:
  // we can't make the searchController first responder here since it's not part
  // of the view
  // hierarchy yet, instead we do it in viewWillAppear
  //
  _searchControllerSearchFieldWasFirstResponder =
      [coder decodeBoolForKey:SearchBarIsFirstResponderKey];

  // restore the text in the search field
  self.searchController.searchBar.text =
      [coder decodeObjectForKey:SearchBarTextKey];
}

#pragma mark - Other Methods

- (void)dealloc {
  [self.searchController.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
