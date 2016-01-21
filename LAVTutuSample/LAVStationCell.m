#import "LAVStationCell.h"

@implementation LAVStationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setInfo:(LAVModelStation *)station {
    _labelCityTitle.text = station.cityTitle;
    _labelCountryTitle.text = station.countryTitle;
    _labelStationTitle.text = station.stationTitle;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
