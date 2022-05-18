//
//  ParseOperations.h
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/29/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol ParseOperationsDelegate <NSObject>

@optional

//-(void)searchDealsResult: (NSArray *) deals;

@end

@interface ParseOperations : NSObject

// properties

@property(nonatomic, weak) id <ParseOperationsDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *dealCategories;
@property (nonatomic, strong) NSMutableArray *allDeals;
@property (nonatomic, strong) NSMutableArray *myDeals;


@property (nonatomic, strong) NSNumber *searchCategoryIndex;
@property (nonatomic, strong) NSNumber *searchDistance;

@property (nonatomic, strong) NSNumber *sortByRateIndex;
@property (nonatomic, strong) NSNumber *sortByPriceIndex;

@property (nonatomic, strong) NSString *searchKeyword;


@property (nonatomic, strong) NSMutableArray *allDealsSearch;
@property (nonatomic, strong) NSMutableArray *myDealsSearch;


@property (nonatomic, strong) NSMutableArray *nearByBusinesses;

@property (nonatomic, strong) NSMutableArray *myBusinesses;
@property (nonatomic, strong) NSMutableArray *myNearByBusinesses;

@property (nonatomic, strong) NSMutableArray *myFavoriteDeals;
@property (nonatomic, strong) NSMutableArray *myFavoriteDealsSearch;

@property (nonatomic, strong) NSMutableArray *myFavoriteBusinessesDeals;

@property (nonatomic, assign) NSInteger myFavDealsCount;

@property (nonatomic, strong) NSMutableArray *myFavoriteDealers;

@property (nonatomic, strong) NSMutableArray *favoriteDealerDeals;
@property (nonatomic, strong) NSMutableArray *favoriteDealerDealsSearch;

@property (nonatomic, assign) BOOL isMile;


// methods
+(ParseOperations *)sharedInstance;

-(void) calculateAndSaveRatingsForADeal:(PFObject *)deal;
-(void) getAllDealCategories;

-(void) getMyBusinessInfo;

-(void) startUpFetchDealsInTheBackground: (NSNumber *)dealIndex withLimit:(NSNumber *) limit;

-(void) fetchMyDealsInTheBackgroundWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) fetchAllDealsSearchInTheBackgroundWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) fetchMyDealsSearchInTheBackgroundWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) getAllNearByBusinessesWithNewSearch: (BOOL)isNewSearch isLimit:(BOOL)isLimit isForAllDeal: (BOOL) isForAllDeal;

-(void) fetchMyFavoriteBusinesses;

-(void) getMyFavDealsWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) getMyFavDealsSearchWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) getMyFavDealersWithIndex: (NSNumber *) dealerIndex withLimit:(NSNumber *) limit;

-(void) getFavDealerDealsWithDealer: (PFObject *) dealer WithIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) getFavDealerDealsSearchWithDealer: (PFObject *) dealer WithIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit;

-(void) searchMyDealsByMyNearByBusinesses;



@end
