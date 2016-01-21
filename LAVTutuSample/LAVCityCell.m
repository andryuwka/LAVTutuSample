#import "LAVCityCell.h"

@implementation LAVCityCell

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setInfo:(LAVModelCity *)city {
  _city = city;
  _labelCityTitle.text = city.cityTitle;
  _labelCountryTitle.text = city.countryTitle;
}

@end
