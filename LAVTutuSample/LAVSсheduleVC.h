#import <UIKit/UIKit.h>
#import "LAVJSONConverter.h"
#import "LAVModelCity.h"
#import "LAVResultsTVC.h"
#import <TSMessage.h>
#import <DMPickerView.h>
#import <ActionSheetPicker.h>

@interface LAVScheduleVC
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        DMPickerViewDatasource, DMPickerViewDelegate,
                        UITextFieldDelegate>

@property(nonatomic, weak, readwrite) IBOutlet UITableView *tableView;
@property(nonatomic, weak, readwrite) IBOutlet UIView *aboutAppView;
@property(nonatomic, weak, readwrite) IBOutlet UIView *backView;
@property(nonatomic, weak, readwrite) IBOutlet UIView *viewListFrom;
@property(nonatomic, weak, readwrite) IBOutlet UIView *viewListTo;
@property(nonatomic, weak, readwrite) IBOutlet DMPickerView *pickerView;
@property(nonatomic, weak, readwrite) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonChoose;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonSearch;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonSwap;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonListFrom;
@property(nonatomic, weak, readwrite) IBOutlet UIButton *buttonListTo;
@property(nonatomic, weak, readwrite) IBOutlet UITextField *textFrom;
@property(nonatomic, weak, readwrite) IBOutlet UITextField *textTo;

@property(nonatomic, strong, readwrite) AbstractActionSheetPicker *actionSheetPicker;
@property(nonatomic, strong, readwrite) NSDate *selectedDate;
@property(nonatomic, strong, readwrite) LAVModelStation *stationFrom;
@property(nonatomic, strong, readwrite) LAVModelStation *stationTo;

@end
