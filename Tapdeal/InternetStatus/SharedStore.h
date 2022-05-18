//
//  Animal.h
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define GOOGLE_SERVER_API_KEY @"AIzaSyCJ6AVYknufRScynnfApZ6jKGvfkD_2bUM"

#define GOOGLE_BROWSER_API_KEY @"AIzaSyAJ4CL7qFsbn96QIPAXt3aJlBgcteUdZmk"


#define DEFAULTS [NSUserDefaults standardUserDefaults]

#define IS_IPAD  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define ScreenSize [[UIScreen mainScreen] bounds].size

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define APPLICATION_NAME @"TapDeal"

#define DEALS_FETCH_LIMIT [NSNumber numberWithInt:6]


// blue theme
#define THEME_COLOR UIColorFromRGB(0x1a63a7)
#define THEME_DESCRIPTIONCOLOR UIColorFromRGB(0x545454)
#define THEME_COLOR_LIGHT UIColorFromRGB(0xbce0ff)
#define THEME_COLOR_DISABLED UIColorFromRGB(0x6d6d6d)

#define THEME_COLOR_GREY UIColorFromRGB(0x323232)

#define THEME_BUTTON_TEXT_COLOR UIColorFromRGB(0xffffff)
#define THEME_NAVBAR_COLOR UIColorFromRGB(0xffffff)

// FONT
/*
#define App_Default_font_18             [UIFont fontWithName:@"CaviarDreams" size:18]
#define App_Default_font_18_bold        [UIFont fontWithName:@"CaviarDreams-Bold" size:18]

#define App_Default_font_16             [UIFont fontWithName:@"CaviarDreams" size:16]
#define App_Default_font_16_bold        [UIFont fontWithName:@"CaviarDreams-Bold" size:16]

#define App_Default_font_15             [UIFont fontWithName:@"CaviarDreams" size:15]
#define App_Default_font_14             [UIFont fontWithName:@"CaviarDreams" size:14]
#define App_Default_font_13             [UIFont fontWithName:@"CaviarDreams" size:13]
#define App_Default_font_12             [UIFont fontWithName:@"CaviarDreams" size:12]
#define App_Default_font_11             [UIFont fontWithName:@"CaviarDreams" size:11]

#define App_Default_font_14_bold        [UIFont fontWithName:@"CaviarDreams-Bold" size:14]
#define App_Default_font_14_bold_italic [UIFont fontWithName:@"CaviarDreams-BoldItalic" size:14]
#define App_Default_font_14_italic      [UIFont fontWithName:@"CaviarDreams-Italic" size:14]

 */

#define App_Default_font_18             [UIFont fontWithName:@"HelveticaNeue" size:18]
#define App_Default_font_18_bold        [UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
#define App_Default_font_20_bold        [UIFont fontWithName:@"HelveticaNeue-Bold" size:20]

#define App_Default_font_16              [UIFont fontWithName:@"HelveticaNeue" size:16]
#define App_Default_font_16_Medium      [UIFont fontWithName:@"HelveticaNeue-Medium" size:16]

#define App_Default_font_24_Medium      [UIFont fontWithName:@"HelveticaNeue-Medium" size:24]
#define App_Default_font_16_bold        [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]

#define App_Default_font_15             [UIFont fontWithName:@"HelveticaNeue" size:15]
#define App_Default_font_14             [UIFont fontWithName:@"HelveticaNeue" size:14]
#define App_Default_font_13             [UIFont fontWithName:@"HelveticaNeue" size:13]
#define App_Default_font_12             [UIFont fontWithName:@"HelveticaNeue" size:12]
#define App_Default_font_10             [UIFont fontWithName:@"HelveticaNeue" size:10]
#define App_Default_font_11             [UIFont fontWithName:@"HelveticaNeue" size:11]

#define App_Default_font_10_Light             [UIFont fontWithName:@"HelveticaNeue-Light" size:10]

#define App_Default_font_14_bold        [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
#define App_Default_font_14_bold_italic [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:14]
#define App_Default_font_14_italic      [UIFont fontWithName:@"HelveticaNeue-Italic" size:14]




// MESSAGES
#define Message_InternetOffline         @"The Internet connection appears to be offline."
#define Message_ServerCommunication     @"Communicating with server.."
#define Message_FacebookCommunication   @"Communicating with facebook.."

#define Message_OperationFailed         @"The requested operation failed!!"

#define Message_OperationSuccessful     @"Operation successful!!"
#define Message_EntryAdded              @"Entry added successfully!!"
#define Message_DeletingEntry           @"Deleting Entry..."
#define Message_EntryDeleted            @"Entry deleted successfully!!"



// parse Classes
#define PARSE_CLASS_USER @"User"
#define PARSE_CLASS_BUSINESS @"Business"
#define PARSE_CLASS_BUSINESS_LOCATION @"BusinessLocation"
#define PARSE_CLASS_CATEGORY @"Category"
#define PARSE_CLASS_DEAL @"Deal"
#define PARSE_CLASS_RATING @"Rating"
#define PARSE_CLASS_SOCIAL @"Social"

// parse User Roles
#define USER_TYPE_BUSINESS @"Business"
#define USER_TYPE_CONSUMER @"Consumer"

// parse User Class Fields
#define FIELD_USER_USERTYPE @"userType"
#define FIELD_USER_USERNAME @"username"
#define FIELD_USER_FULLNAME @"fullname"
#define FIELD_USER_EMAIL @"email"
#define FIELD_USER_PASSWORD @"password"
#define FIELD_USER_FAVORITE_BUSINESSES @"favoriteBusinesses"
#define FIELD_USER_FAVORITE_DEALS @"favoriteDeals"


// parse Business Class Fields

#define FIELD_BUSINESS_DEALER @"dealer"
#define FIELD_BUSINESS_IMAGE @"image"
#define FIELD_BUSINESS_NAME @"name"
#define FIELD_BUSINESS_BUSINESSLOCATIONS @"businessLocations"
#define FIELD_BUSINESS_IS_VERIFIED @"isVerified"
#define FIELD_BUSINESS_BUSINESS_NUMBER @"businessNumber"


// parse BusinessLocation class fields
#define FIELD_BUSINESSLOCATION_COUNTRY @"country"
#define FIELD_BUSINESSLOCATION_ADDRESSLINE1 @"addressLine1"
#define FIELD_BUSINESSLOCATION_ADDRESSLINE2 @"addressLine2"
#define FIELD_BUSINESSLOCATION_STATE @"state"
#define FIELD_BUSINESSLOCATION_SUBURB @"suburb"
#define FIELD_BUSINESSLOCATION_LOCATION_POINT @"locationPoint"
#define FIELD_BUSINESSLOCATION_IS_USING_LOCATION_FROM_MAP @"isUsingLocationFromMap"

#define FIELD_BUSINESSLOCATION_PHONE @"phone"
#define FIELD_BUSINESSLOCATION_EMAIL @"email"
#define FIELD_BUSINESSLOCATION_CONTACT_PERSON @"contactPerson"
#define FIELD_BUSINESSLOCATION_BUSINESS_NAME_ALIAS @"businessNameAlias"

// parse Category class fields
#define FIELD_CATEGORY_NAME @"name"
#define FIELD_CATEGORY_CATEGORY_ID @"category_id"

// parse Deal class fields
#define FIELD_DEAL_ITEM_NAME @"itemName"
#define FIELD_DEAL_DEAL_PRICE @"dealPrice"
#define FIELD_DEAL_ITEM_DESCRIPTION @"itemDescription"
#define FIELD_DEAL_ITEM_TAG @"itemTag"
#define FIELD_DEAL_ORIGINAL_PRICE @"originalPrice"
#define FIELD_DEAL_VALID_FROM @"validFrom"
#define FIELD_DEAL_VALID_TO @"validTo"
#define FIELD_DEAL_IMAGE_FILE @"imageFile"
#define FIELD_DEAL_OWNER @"owner"
#define FIELD_DEAL_ITEM_CATEGORY @"itemCategory"
#define FIELD_DEAL_ITEM_AVERAGE_RATE @"averageRate"
#define FIELD_DEAL_KEYWORD @"keyword"
#define FIELD_DEAL_SNAPSHOT @"dealSnapshot"


// parse Rating class fields
#define FIELD_RATING_DEAL @"deal"
#define FIELD_RATING_USER @"user"
#define FIELD_RATING_RATE @"rate"

// parse Social class fields
#define FIELD_SOCIAL_FACEBOOK_MESSAGE @"facebook"
#define FIELD_SOCIAL_TWITTER_MESSAGE @"twitter"
#define FIELD_SOCIAL_TEXT_MESSAGE @"sms"
#define FIELD_SOCIAL_EMAIL_MESSAGE @"email"
#define FIELD_SOCIAL_APP_STORE_URL @"appStoreURL"



// sory options

#define SEARCH_OPTION_SORT_BY_RATING_IGNORE @"Rating: Ignore"
#define SEARCH_OPTION_SORT_BY_RATING_ASC @"Rating: Low To High"
#define SEARCH_OPTION_SORT_BY_RATING_DESC @"Rating: High To Low"


#define SEARCH_OPTION_SORT_BY_DEAL_PRICE_IGNORE @"Price: Ignore"
#define SEARCH_OPTION_SORT_BY_DEAL_PRICE_ASC @"Price: Low To High"
#define SEARCH_OPTION_SORT_BY_DEAL_PRICE_DESC @"Price: High To Low"


#define ID_TERMS_OF_USE @1
#define ID_APP_DISCLAIMER @2
#define ID_PRIVACY_POLICY @3

@interface SharedStore: NSObject {
    
    BOOL checkedConnection;
    BOOL hostActive;
}



// ------------ PROPERTIES ------------ //

@property (nonatomic, assign) BOOL checkedConnection;
@property (nonatomic, assign) BOOL enableNotification;
@property (nonatomic, assign) BOOL hostActive;

// ------------ CLASS METHOD --------- //
+(SharedStore*)store;

-(NSArray*)getAllCountry;

-(NSArray *)getSortByRateItems;

-(NSArray *)getSortByPriceItems;

-(UIImage *)scaleAndRotateImaga:(UIImage *)image;

-(void)customizeImageView :(UIImageView *)view;
-(NSAttributedString *)strkiethroughLabel:(NSString *)string;
@end












