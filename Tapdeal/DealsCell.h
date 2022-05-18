//
//  dealsCell.h
//  Ratings
//
//  Created by Marin Todorov on 8/9/13.
//
//

#import <UIKit/UIKit.h>

@interface DealsCell: UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *TitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *oldPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *dealPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *dealExpiredLabel;
@property (nonatomic, strong) IBOutlet UIImageView *ratingImageView;
@property (nonatomic, strong) IBOutlet UIImageView *itemImageView;

@end
