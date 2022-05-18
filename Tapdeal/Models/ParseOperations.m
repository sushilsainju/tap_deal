//
//  ParseOperations.m
//  Tapdeal
//
//  Created by Neetin Mac Mini on 7/29/14.
//  Copyright (c) 2014 Bajra Technologies. All rights reserved.
//

#import "ParseOperations.h"
#import "SharedStore.h"

#import "AppDelegate.h"



@interface ParseOperations()

// Private properties

@property (nonatomic, assign) BOOL isProcessingAllDealFetch;
@property (nonatomic, assign) BOOL isProcessingMyDealFetch;

@property (nonatomic, assign) BOOL isProcessingAllDealSearch;
@property (nonatomic, assign) BOOL isProcessingMyDealSearch;

@property (nonatomic, assign) BOOL isProcessingFavDeal;
@property (nonatomic, assign) BOOL isProcessingFavDealSearch;

@property (nonatomic, assign) BOOL isProcessingFavDealer;

@property (nonatomic, assign) BOOL isProcessingFavDealersDeal;
@property (nonatomic, assign) BOOL isProcessingFavDealersDealSearch;


@end

@implementation ParseOperations


static ParseOperations * _sharedInstance = nil;

@synthesize delegate, dealCategories, allDeals, myDeals, sortByPriceIndex;

@synthesize searchCategoryIndex, sortByRateIndex, searchDistance, searchKeyword;

@synthesize allDealsSearch, myDealsSearch, nearByBusinesses, myBusinesses;

@synthesize myFavoriteBusinessesDeals, myFavoriteDeals, myFavoriteDealsSearch;
@synthesize myFavoriteDealers, myFavDealsCount, favoriteDealerDeals, favoriteDealerDealsSearch;

@synthesize isProcessingAllDealFetch, isProcessingMyDealFetch, isProcessingAllDealSearch, isProcessingMyDealSearch;

@synthesize isProcessingFavDeal, isProcessingFavDealersDeal, isProcessingFavDealSearch;
@synthesize isProcessingFavDealersDealSearch, isProcessingFavDealer, isMile;

@synthesize myNearByBusinesses;



+(ParseOperations*)sharedInstance
{
	@synchronized([ParseOperations class])
	{
		if (!_sharedInstance)
			_sharedInstance = [[self alloc] init];
        
	}
	
    return _sharedInstance;
}


-(id)init{
    self =  [super init];
    if (self != nil) {
        if (self.dealCategories) {
            if(![self.dealCategories count])
                [self getAllDealCategories];
        }else{
            [self getAllDealCategories];
        }
        allDeals = [NSMutableArray new];
        myDeals = [NSMutableArray new];
        
        searchCategoryIndex = [NSNumber numberWithInt:-1];
        
        searchDistance = [NSNumber numberWithInt:20]; // 5 km
        
        sortByRateIndex = [NSNumber numberWithInt:-1];
        sortByPriceIndex = [NSNumber numberWithInt:-1];
        
        allDealsSearch = [NSMutableArray new];
        myDealsSearch = [NSMutableArray new];
        
        myFavoriteDealsSearch = [NSMutableArray new];
        myFavoriteDeals = [NSMutableArray new];
        
        myFavoriteDealers = [NSMutableArray new];
        searchKeyword = @"";
        
        favoriteDealerDeals = [NSMutableArray new];
        favoriteDealerDealsSearch = [NSMutableArray new];
        
        myBusinesses = [NSMutableArray new];
        myNearByBusinesses = [NSMutableArray new];
        
        isProcessingAllDealFetch = NO;
        isProcessingAllDealSearch = NO;
        
        isProcessingMyDealSearch = NO;
        isProcessingMyDealFetch = NO;
        
        isProcessingFavDeal = isProcessingFavDealersDeal = isProcessingFavDealSearch = isProcessingFavDealersDealSearch = isProcessingFavDealer = NO;
        
        isMile = NO;
        
    }
    return self;
    
}


#pragma mark - All Deals Fetch / Search

-(void) startUpFetchDealsInTheBackground:(NSNumber *)dealIndex withLimit:(NSNumber *) limit{
    
    
    // simply return if currently requesting for deals fetch
    if (isProcessingAllDealFetch) return;
    
    isProcessingAllDealFetch = !isProcessingAllDealFetch;
    
    // fetch deals
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [query includeKey:FIELD_DEAL_OWNER];
    
    NSLog(@"--------------- --------------- --------------- ---------------  current date time: %@", [NSDate date]);
    // only get non expired items
    [query whereKey:FIELD_DEAL_VALID_FROM lessThan:[NSDate date]];
    [query whereKey:FIELD_DEAL_VALID_TO greaterThanOrEqualTo:[NSDate date]];
    [query orderByAscending:FIELD_DEAL_DEAL_PRICE];
    
    // setting deal fetch query limit
    query.limit = [limit integerValue];
    query.skip = [dealIndex integerValue];
    
    // business can be sent nil as well, so this condition is required
    if (!nearByBusinesses || [nearByBusinesses count] == 0)
    {
//        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No Deals found nearby, please change your search preference and try again."];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"dealFetchNotification"
         object:nil];
        
        NSLog(@"inside nearby count check condition --------------------------");
        
        isProcessingAllDealFetch = !isProcessingAllDealFetch;
        
        [self getAllNearByBusinessesWithNewSearch:YES isLimit:NO isForAllDeal:YES];   // this may cause recursiveness
        
    }
    
    else{
        
        
        NSLog(@"nearby business in startup fetch: %@", nearByBusinesses);
        
        [query whereKey:FIELD_DEAL_OWNER containedIn:nearByBusinesses];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                if ([objects count] == 0)
                {
                    if ([allDeals count] == 0)
                    {
//                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No deals found!"];
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"dealFetchNotification"
                         object:nil];
                    }
                }
                else
                {
                    
                    if ([dealIndex intValue] == 0) {
                        [allDeals removeAllObjects];
                        allDeals = [objects mutableCopy];
                    }
                    else{
                        [allDeals addObjectsFromArray:[objects mutableCopy]];
                    }
                    
                    NSLog(@"all deals objects from parse operations: %@, %@", objects, allDeals);
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"dealFetchNotification"
                     object:nil];
                }
                
            }
            else{
                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wrong while fetching deals. Please try later"];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"dealFetchNotification"
                 object:nil];
            }
            
            isProcessingAllDealFetch = !isProcessingAllDealFetch;
        }];
        
    }
}



//-(void) getAllNearByBusinessesWithNewSearch: (BOOL)isNewSearch isLimit:(BOOL)isLimit{

    
-(void) getAllNearByBusinessesWithNewSearch: (BOOL)isNewSearch isLimit:(BOOL)isLimit isForAllDeal: (BOOL) isForAllDeal{
    
    CLLocation *currentLocation = DELEGATE.locationManager.location;
    
    
//    if (currentLocation.coordinate.latitude == 0 ){
//        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Could not get current location of mobile. Please make sure you have turned on location sharing from settings"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
//        return;
//    }
    
    
    PFGeoPoint *geoPoint;
    if (currentLocation) {
          geoPoint= [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    }
    else
    geoPoint= [PFGeoPoint geoPointWithLatitude:27.703378 longitude:85.322514];
    
    PFQuery *distanceQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
    
    // if search distance is grater than 100 miles then ommit search by distance clause
    if ([searchDistance floatValue] <= 100)
    {
        if (isMile)
            [distanceQuery whereKey:@"locationPoint" nearGeoPoint:geoPoint withinMiles:[searchDistance floatValue]];
        else
            [distanceQuery whereKey:@"locationPoint" nearGeoPoint:geoPoint withinKilometers:[searchDistance floatValue]];
    }
    
    
    [distanceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 0) {
                PFQuery *businessQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
                [businessQuery whereKey:FIELD_BUSINESS_BUSINESSLOCATIONS containedIn:objects];
                [businessQuery findObjectsInBackgroundWithBlock:^(NSArray *businessObjects, NSError *businessError) {
                    if (!businessError)
                    {
                        if ([businessObjects count] > 0)
                        {
                            [nearByBusinesses removeAllObjects];
                            nearByBusinesses = [businessObjects mutableCopy];
                            
                            if (isForAllDeal)
                            {
                                [self startUpFetchDealsInTheBackground:@0 withLimit:DEALS_FETCH_LIMIT];
                            }
                            
                            else
                            {
                                if (isNewSearch)
                                {
                                    [allDealsSearch removeAllObjects];
                                    if (isLimit)
                                        [self fetchAllDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
                                    else
                                        [self fetchAllDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:@0];
                                }
                            }
                            
                        }
                        else{
                            
                            NSString *msg = nil;
                            if (isMile)
                                msg = [NSString stringWithFormat:@"No deals found within %@ miles", searchDistance];
                            else
                                msg = [NSString stringWithFormat:@"No deals found within %@ km", searchDistance];

//                            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:msg];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
                            
                        }
                    }
                    else
                    {
                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wroing while searching for deals"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
                    }
                }];
            }
            else{
                NSString *msg = nil;
                if (isMile)
                    msg = [NSString stringWithFormat:@"No deals found within %@ miles", searchDistance];
                else
                    msg = [NSString stringWithFormat:@"No deals found within %@ km", searchDistance];

//                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:msg];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
                
            }
        }else{
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wrong while searching for deals"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
        }
    }];
    
}

-(void) fetchAllDealsSearchInTheBackgroundWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit
{
    
    
    if (isProcessingAllDealSearch) return;
    
    isProcessingAllDealSearch = !isProcessingAllDealSearch;
    
    NSLog(@"--------------- --------------- --------------- ---------------  requesting for deals of search");
 
    PFQuery *filterSearchA = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [filterSearchA whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:[NSString stringWithFormat:@"^(?i)%@|\\s(?i)%@",searchKeyword,searchKeyword]];
    
    
  // PFQuery *filterSearchB = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
  // [filterSearchB whereKey:FIELD_DEAL_ITEM_DESCRIPTION matchesRegex:[NSString stringWithFormat:@"(?i)%@",searchKeyword]];
    
   // PFQuery *filterSearchC = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
   // [filterSearchC whereKey:FIELD_DEAL_ITEM_TAG matchesRegex:[NSString stringWithFormat:@"(?i)%@",searchKeyword]];
    
   // NSString *trimmedKeyword = [searchKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *keywords = [self splitSearchKeywordsIntoArray:searchKeyword];
    PFQuery *filterSearchB = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [filterSearchB whereKey:FIELD_DEAL_KEYWORD containedIn:keywords];
   
    PFQuery *searchQuery = [PFQuery orQueryWithSubqueries:@[filterSearchA,filterSearchB]];
    [searchQuery includeKey:FIELD_DEAL_OWNER];
    
   
    
    // construction query to search deals
  //  PFQuery *searchQuery = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
 //   [searchQuery includeKey:FIELD_DEAL_OWNER];
    
    
    // only get non expired items
    [searchQuery whereKey:FIELD_DEAL_VALID_FROM lessThan:[NSDate date]];
    [searchQuery whereKey:FIELD_DEAL_VALID_TO greaterThanOrEqualTo:[NSDate date]];
    
    NSLog(@"searchCategoryIndex: %@", searchCategoryIndex);
    
    
   if ([dealCategories count]) {
        
        if([searchCategoryIndex intValue] > 0){
            int index = [searchCategoryIndex intValue] - 1;
            NSLog(@"search category object index: %d", index);
            
            PFObject *cat = [dealCategories objectAtIndex:index];
            [searchQuery whereKey:FIELD_DEAL_ITEM_CATEGORY equalTo:cat];
            
            NSLog(@"search category : %@", cat);
        }
    }
    
    // business can be sent nil as well, so this condition is required
    if (nearByBusinesses) {
        NSLog(@"near by businesses... : %@", nearByBusinesses);
        [searchQuery whereKey:FIELD_DEAL_OWNER containedIn:nearByBusinesses];
        
        
    }
    
    // setting deal fetch query limit
    searchQuery.limit = [limit integerValue];
    searchQuery.skip = [dealIndex integerValue];
    
    
//    NSString *regx = [NSString stringWithFormat:@"\\Q%@\\E", searchKeyword];
//    [searchQuery whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:regx modifiers:@"i"];
    
    
 // NSString *trimmedKeyword = [searchKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
// if (trimmedKeyword.length > 0) {
    /* NSArray *keywords = [self splitSearchKeywordsIntoArray:searchKeyword];
     [searchQuery whereKey:FIELD_DEAL_KEYWORD containedIn:keywords];*/
     
 //   [searchQuery whereKey:FIELD_DEAL_ITEM_NAME hasPrefix: trimmedKeyword];
     
    // [searchQuery whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:[NSString stringWithFormat:@"^(?i)%@",trimmedKeyword]];
   //    [searchQuery whereKey:FIELD_DEAL_ITEM_DESCRIPTION matchesRegex:[NSString stringWithFormat:@"(?i)%@",trimmedKeyword]];
    // [searchQuery whereKey:FIELD_DEAL_ITEM_TAG matchesRegex:[NSString stringWithFormat:@"(?i)%@",trimmedKeyword]];

  
// }
   

  
   
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
           NSLog(@"Deal search objects: %@", objects);
            if ([objects count] > 0) {
                if ([dealIndex intValue] == 0) {
                    [allDealsSearch removeAllObjects];
                    allDealsSearch = [objects mutableCopy];

                }else{
                    
                    [allDealsSearch addObjectsFromArray:[objects mutableCopy]];
                }
                
                [self sortDealsByPrice:@"allDealSearch"];
                [self sortDealsByRate:@"allDealSearch"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
                
            }
            else{
                if ([allDealsSearch count] == 0 && [dealIndex intValue] == 0) {
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No matching deals found!"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
                }
            }
            
            if ([dealIndex intValue] == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
            }

      }else{
            NSLog(@"error ayo: %@", [error userInfo]);
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Unknown error occurred. Please try later."];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dealsSearchNotification" object:nil];
        }
        
        isProcessingAllDealSearch = !isProcessingAllDealSearch;
    }];
}


#pragma mark - My Deals Fetch / Search


-(void)getMyBusinessInfo{
    if ([myBusinesses count] == 0) {
        PFUser *currentUser = [PFUser currentUser];
        
        if (currentUser) {
            PFQuery *businessQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
            [businessQuery whereKey:FIELD_BUSINESS_DEALER equalTo:currentUser];
//            myBusinessObject = [businessQuery getFirstObject];
            NSLog(@"my biz info : %@", myBusinesses);
            [businessQuery findObjectsInBackgroundWithBlock:^(NSArray *bizs, NSError *error) {
                if (!error) {
                    if ([bizs count])
                    {
                        myBusinesses = [bizs mutableCopy];
                        NSLog(@"my businesses: %@", myBusinesses);
                        [self fetchMyDealsInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
                    }
                    
                }
                else{
                    NSLog(@"error on getting biz info: %@", [error userInfo]);
                }
            }];
        }
    }
}

-(void)fetchMyDealsInTheBackgroundWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit{
    
    if ([myBusinesses count] == 0) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"There is an error to get your business information. Please make sure you have added your business information from settings or simply drag the list to reload it"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"myDealFetchNotification"
         object:nil];
        
        [self getMyBusinessInfo];
        return;
    }
    
    
    if (isProcessingMyDealFetch) return;
    
    isProcessingMyDealFetch = !isProcessingMyDealFetch;
    
    PFQuery *dealsQuery = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [dealsQuery includeKey:FIELD_DEAL_OWNER];
    
    
    // setting deal fetch query limit
    dealsQuery.limit = [limit integerValue];
    dealsQuery.skip = [dealIndex integerValue];
    
    [dealsQuery whereKey:FIELD_DEAL_OWNER containedIn:myBusinesses];
    [dealsQuery orderByDescending:@"validTo"];
    [dealsQuery findObjectsInBackgroundWithBlock:^(NSArray *myBizDeals, NSError *error) {
        if (!error) {
            
            if ([myBizDeals count] == 0) {
                if ([myDeals count] == 0) {
//                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"You don't have any deals. Please create one!"];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"myDealFetchNotification"
                     object:nil];
                }
            }else{
                [DEFAULTS setBool:YES forKey:@"ifDealerHasBusiness"];
                if ([dealIndex intValue] == 0) {
                    [myDeals removeAllObjects];
                    myDeals = [myBizDeals mutableCopy];
      
                }else{
                    
                    [myDeals addObjectsFromArray:[myBizDeals mutableCopy]];
                }
                
                NSLog(@"my deals objects from parse operations: %@", myBizDeals);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealFetchNotification" object:nil];
                
            }
        }
        else{
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Something went wrong while fetching deals. Please try later"];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"myDealFetchNotification"
             object:nil];
        }
        
        isProcessingMyDealFetch = !isProcessingMyDealFetch;
        
    }];
    
}

-(void) fetchMyDealsSearchInTheBackgroundWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit{
    if (!myNearByBusinesses) {
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Could not get near by deals"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
    }
    
    
    if (isProcessingMyDealSearch) return;
    
    isProcessingMyDealSearch = !isProcessingMyDealSearch;
    
    
    
    // construction query to search deals
    PFQuery *filterSearchA = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [filterSearchA whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:[NSString stringWithFormat:@"^(?i)%@|\\s(?i)%@",searchKeyword,searchKeyword]];
    
    // PFQuery *filterSearchC = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    //[filterSearchC whereKey:FIELD_DEAL_ITEM_DESCRIPTION matchesRegex:[NSString stringWithFormat:@"(?i)%@",searchKeyword]];
    
    // PFQuery *filterSearchC = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    // [filterSearchC whereKey:FIELD_DEAL_ITEM_TAG matchesRegex:[NSString stringWithFormat:@"(?i)%@",searchKeyword]];
    // NSString *trimmedKeyword = [searchKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *keywords = [self splitSearchKeywordsIntoArray:searchKeyword];
    PFQuery *filterSearchB = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [filterSearchB whereKey:FIELD_DEAL_KEYWORD containedIn:keywords];
    
    PFQuery *searchQuery = [PFQuery orQueryWithSubqueries:@[filterSearchA,filterSearchB]];
    [searchQuery includeKey:FIELD_DEAL_OWNER];
    
    
    
/*    PFQuery *searchQuery = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
    [searchQuery includeKey:FIELD_DEAL_OWNER];*/
    
    // only get non expired items
    //    [searchQuery whereKey:FIELD_DEAL_VALID_FROM lessThan:[NSDate date]];
    //    [searchQuery whereKey:FIELD_DEAL_VALID_TO greaterThanOrEqualTo:[NSDate date]];
    
    if ([dealCategories count]) {
        
        if([searchCategoryIndex intValue] > 0){
            int index = [searchCategoryIndex intValue] - 1;
            
            NSLog(@"searc category object index: %d", index);
            
            PFObject *cat = [dealCategories objectAtIndex:index];
            [searchQuery whereKey:FIELD_DEAL_ITEM_CATEGORY equalTo:cat];
            
            NSLog(@"search category : %@", cat);
        }
    }
    
  
    [searchQuery whereKey:FIELD_DEAL_OWNER containedIn:myNearByBusinesses];
    
    // setting deal fetch query limit
    searchQuery.limit = [limit integerValue];
    searchQuery.skip = [dealIndex integerValue];
    
//    NSString *regx = [NSString stringWithFormat:@"\\Q%@\\E", searchKeyword];
//    [searchQuery whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:regx modifiers:@"i"];

    
 /*   NSString *trimmedKeyword = [searchKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedKeyword.length > 0) {
        NSArray *keywords = [self splitSearchKeywordsIntoArray:searchKeyword];
        [searchQuery whereKey:FIELD_DEAL_KEYWORD containedIn:keywords];
    }
*/
    
    [searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Deal search objects: %@", objects);
            if ([objects count] > 0) {
                if ([dealIndex intValue] == 0) {
                    [myDealsSearch removeAllObjects];
                    myDealsSearch = [objects mutableCopy];
                }else{
                    [myDealsSearch addObjectsFromArray:[objects mutableCopy]];
                }
                
                [self sortDealsByPrice:@"myDealSearch"];
                [self sortDealsByRate:@"myDealSearch"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
                
            }else{
                if ([myDealsSearch count] == 0 && [dealIndex intValue] == 0) {
                    [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No matching deals found!"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
                }
            }
            
        }else{
            NSLog(@"error ayo: %@", [error userInfo]);
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Unknown error occurred. Please try later."];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
        }
        
        isProcessingMyDealSearch = !isProcessingMyDealSearch;
        
    }];
}

#pragma mark - get deals categries

-(void) getAllDealCategories{
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_CATEGORY];
    [query addAscendingOrder:FIELD_CATEGORY_NAME];
    
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Results were successfully found, looking first on the
            // network and then on disk.
            
            NSLog(@"all objects from parse for category: %@", objects);
            if ([objects count] > 0) {
                
                self.dealCategories = [objects mutableCopy];
                
            }else{
                //                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No categories list found."];
            }
        } else {
            // The network was inaccessible and we have no cached data for
            // this query.
            NSLog(@"there is an error while fetching categories list: %@", [error userInfo]);
        }
    }];
    
}

#pragma mark - Calculate Ratings

-(void)calculateAndSaveRatingsForADeal:(PFObject *)deal{
    
    PFQuery *query = [PFQuery queryWithClassName: PARSE_CLASS_RATING];
    [query whereKey:FIELD_RATING_DEAL equalTo:deal];
    [query findObjectsInBackgroundWithBlock:^(NSArray *ratings, NSError *error) {
        if (!error) {
            if ([ratings count]) {
                NSLog(@"all ratings: %@", ratings);
                
                int totalRating = 0;
                for (PFObject *rating in ratings) {
                    int rate = [rating[FIELD_RATING_RATE] intValue];
                    totalRating += rate;
                }
                
                int avgRating=0;
                if ([ratings count]>0) {
                    avgRating= totalRating/[ratings count];

                }
                NSNumber *averageRating = [NSNumber numberWithInt:avgRating];
                
                deal[FIELD_DEAL_ITEM_AVERAGE_RATE] = averageRating;
                
                
            }else{
                NSLog(@"no ratings found for this deal");
                deal[FIELD_DEAL_ITEM_AVERAGE_RATE] = [NSNumber numberWithInt:0];
            }
            
            // save ratings
            [deal saveEventually];
        }
        else{
            NSLog(@"error while calculating average deal rating : %@", [error userInfo]);
        }
    }];
}


#pragma mark - sorting methods

-(void)sortDealsByRate:(NSString *)dealType{
    
    
    NSArray *sortOrder = [[SharedStore store] getSortByRateItems];
    NSString *sort = [sortOrder objectAtIndex:[sortByRateIndex intValue]];
    
    NSString *sortDescriptorkey = @"";
    BOOL ascending = YES;
    
    if ([sort isEqualToString:SEARCH_OPTION_SORT_BY_RATING_IGNORE]) {
        return;
    }
    else if ([sort isEqualToString:SEARCH_OPTION_SORT_BY_RATING_ASC]) {
        sortDescriptorkey = FIELD_DEAL_ITEM_AVERAGE_RATE;
        ascending = YES;
    }
    else  if ([sort isEqualToString:SEARCH_OPTION_SORT_BY_RATING_DESC]) {
        sortDescriptorkey = FIELD_DEAL_ITEM_AVERAGE_RATE;
        ascending = NO;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortDescriptorkey
                                                                     ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = nil;
    
    if ([dealType isEqualToString:@"myDealSearch"]) {
        sortedArray = [myDealsSearch sortedArrayUsingDescriptors:sortDescriptors];
        
        [myDealsSearch removeAllObjects];
        myDealsSearch = [sortedArray mutableCopy];
        
    }
    else if([dealType isEqualToString:@"allDealSearch"]){
        sortedArray = [allDealsSearch sortedArrayUsingDescriptors:sortDescriptors];
        
        [allDealsSearch removeAllObjects];
        allDealsSearch = [sortedArray mutableCopy];
    }
    else if([dealType isEqualToString:@"favoriteDealSearch"]){
        sortedArray = [myFavoriteDealsSearch sortedArrayUsingDescriptors:sortDescriptors];
        
        [myFavoriteDealsSearch removeAllObjects];
        myFavoriteDealsSearch = [sortedArray mutableCopy];
    }
}

-(void)sortDealsByPrice:(NSString *)dealType{
    
    NSArray *sortOrder = [[SharedStore store] getSortByPriceItems];
    NSString *sort = [sortOrder objectAtIndex:[sortByPriceIndex intValue]];
    
    NSString *sortDescriptorkey = @"";
    BOOL ascending = YES;
    
    if ([sort isEqualToString:SEARCH_OPTION_SORT_BY_DEAL_PRICE_IGNORE]) {
        return;
    }
    else if ([sort isEqualToString:SEARCH_OPTION_SORT_BY_DEAL_PRICE_ASC]) {
        sortDescriptorkey = FIELD_DEAL_DEAL_PRICE;
        ascending = YES;
    }
    else  if ([sort isEqualToString:SEARCH_OPTION_SORT_BY_DEAL_PRICE_DESC]) {
        sortDescriptorkey = FIELD_DEAL_DEAL_PRICE;
        ascending = NO;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortDescriptorkey
                                                                     ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray = nil;
    if ([dealType isEqualToString:@"myDealSearch"]) {
        sortedArray = [myDealsSearch sortedArrayUsingDescriptors:sortDescriptors];
        
        [myDealsSearch removeAllObjects];
        myDealsSearch = [sortedArray mutableCopy];
        
    }
    else if([dealType isEqualToString:@"allDealSearch"]){
        sortedArray = [allDealsSearch sortedArrayUsingDescriptors:sortDescriptors];
        
        [allDealsSearch removeAllObjects];
        allDealsSearch = [sortedArray mutableCopy];
    }
    else if([dealType isEqualToString:@"favoriteDealSearch"]){
        sortedArray = [myFavoriteDealsSearch sortedArrayUsingDescriptors:sortDescriptors];
        
        [myFavoriteDealsSearch removeAllObjects];
        myFavoriteDealsSearch = [sortedArray mutableCopy];
    }
}

#pragma mark - Favorites

-(void)fetchMyFavoriteBusinesses{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        NSArray *biz = [[PFUser currentUser] objectForKey:FIELD_USER_FAVORITE_BUSINESSES];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
        [query whereKey:FIELD_DEAL_OWNER containedIn:biz];
        [query findObjectsInBackgroundWithBlock:^(NSArray *bizDeals, NSError *error) {
            
            if (!error) {
                NSLog(@"fav biz deals: %@", bizDeals);
            }
        }];
    }
    
}

-(void)getMyFavDealsWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit{
    
    if (isProcessingFavDeal) return;
    
    isProcessingFavDeal = !isProcessingFavDeal;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        NSArray *favDeal = [[PFUser currentUser] objectForKey:FIELD_USER_FAVORITE_DEALS];
        
        NSMutableArray *fav = [NSMutableArray new];
        for (PFObject *d in favDeal) {
            NSString *objId = d.objectId;
            [fav addObject:objId];
        }
        
        myFavDealsCount = [favDeal count];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
        query.skip = [dealIndex integerValue];
        query.limit = [limit integerValue];
        
        
       [query includeKey:FIELD_DEAL_OWNER];
        
        [query whereKey:@"objectId" containedIn:fav];
        [query findObjectsInBackgroundWithBlock:^(NSArray *favDeals, NSError *error) {
            if (!error) {
                NSLog(@"fav deals list : %@", favDeals);
                if ([favDeals count]) {
                    if ([dealIndex intValue] == 0) {
                        [myFavoriteDeals removeAllObjects];
                        myFavoriteDeals = [favDeals mutableCopy];
                    }else{
                        [myFavoriteDeals addObjectsFromArray:[favDeals mutableCopy]];
                    }
                }else{
                    if ([dealIndex intValue] == 0)
                    {
                        [myFavoriteDeals removeAllObjects];
//                         [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No favorite deals found!"];
                    }
                }
                
                NSLog(@"my fav deals: %@", myFavoriteDeals);
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"myFavDealsFetchNotification"
                 object:nil];
            }
            
            isProcessingFavDeal = !isProcessingFavDeal;
        }];
    }
    
}

-(void) getMyFavDealsSearchWithDealIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit{
    
    if (isProcessingFavDealSearch) return;
    
    isProcessingFavDealSearch = !isProcessingFavDealSearch;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        NSArray *favDeal = [[PFUser currentUser] objectForKey:FIELD_USER_FAVORITE_DEALS];
        
        NSMutableArray *fav = [NSMutableArray new];
        for (PFObject *d in favDeal) {
            NSString *objId = d.objectId;
            [fav addObject:objId];
        }
        
        myFavDealsCount = [favDeal count];
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
        
        if ([dealCategories count]) {
            
            if([searchCategoryIndex intValue] > 0){
                int index = [searchCategoryIndex intValue] - 1;
                NSLog(@"search category object index: %d", index);
                
                PFObject *cat = [dealCategories objectAtIndex:index];
                [query whereKey:FIELD_DEAL_ITEM_CATEGORY equalTo:cat];
                
                NSLog(@"search category : %@", cat);
            }
        }
        
        query.skip = [dealIndex integerValue];
        query.limit = [limit integerValue];
        [query includeKey:FIELD_DEAL_OWNER];
        
//        NSString *regx = [NSString stringWithFormat:@"\\Q%@\\E", searchKeyword];
//        [query whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:regx modifiers:@"i"];
        
        NSString *trimmedKeyword = [searchKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmedKeyword.length > 0) {
            NSArray *keywords = [self splitSearchKeywordsIntoArray:searchKeyword];
            [query whereKey:FIELD_DEAL_KEYWORD containedIn:keywords];
        }
        
        [query whereKey:@"objectId" containedIn:fav];
        [query findObjectsInBackgroundWithBlock:^(NSArray *favDeals, NSError *error) {
            if (!error) {
                NSLog(@"fav deals list : %@", favDeals);
                if ([favDeals count]) {
                    
                    if ([dealIndex intValue] == 0) {
                        [myFavoriteDealsSearch removeAllObjects];
                        myFavoriteDealsSearch = [favDeals mutableCopy];
                    }else{
                        [myFavoriteDealsSearch addObjectsFromArray:[favDeals mutableCopy]];
                    }
                    
                }else{
                    if ([dealIndex intValue] == 0) {
                        [myFavoriteDealsSearch removeAllObjects];
//                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No favorite deals found!"];
                    }
                }
                
                
                [self sortDealsByPrice:@"favoriteDealSearch"];
                [self sortDealsByRate:@"favoriteDealSearch"];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"myFavDealsSearchFetchNotification"
                 object:nil];
            }
            
            isProcessingFavDealSearch = !isProcessingFavDealSearch;
        }];
    }
    
}


#pragma mark - Fav Dealers

-(void) getMyFavDealersWithIndex: (NSNumber *) dealerIndex withLimit:(NSNumber *) limit{
    
     if (isProcessingFavDealer) return;
    
    isProcessingFavDealer = !isProcessingFavDealer;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        NSArray *favBusiness = [[PFUser currentUser] objectForKey:FIELD_USER_FAVORITE_BUSINESSES];
        
        NSMutableArray *fav = [NSMutableArray new];
        for (PFObject *d in favBusiness) {
            NSString *objId = d.objectId;
            [fav addObject:objId];
        }
        
        
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
        
        query.skip = [dealerIndex integerValue];
        query.limit = [limit integerValue];
        
        
        [query whereKey:@"objectId" containedIn:fav];
        [query includeKey:@"businessLocations"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *favDealers, NSError *error) {
            
            if (!error) {
                NSLog(@"fav dealer list : %@", favDealers);
                if ([favDealers count]) {
                    if ([dealerIndex intValue] == 0) {
                        [myFavoriteDealers removeAllObjects];
                        myFavoriteDealers = [favDealers mutableCopy];
                    }else{
                        [myFavoriteDealers addObjectsFromArray:[favDealers mutableCopy]];
                    }
                }else{
                    if ([dealerIndex intValue] == 0) {
                        [myFavoriteDealers removeAllObjects];
//                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No favorite businesses found!"];
                    }
                }
                
                NSLog(@"my fav dealers: %@", myFavoriteDealers);
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"myFavDealersFetchNotification"
                 object:nil];
            }
            else{
                NSLog(@"error ayo on fav dealer: %@", [error userInfo]);
            }
            
            isProcessingFavDealer = !isProcessingFavDealer;
        }];
    }
    

}


-(void) getFavDealerDealsWithDealer: (PFObject *) dealer WithIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit{
    
    if (isProcessingFavDealersDeal) return;
    
    isProcessingFavDealersDeal = !isProcessingFavDealersDeal;
    
    PFUser *currentUser = [PFUser currentUser];

    if (currentUser) {
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
        query.skip = [dealIndex integerValue];
        query.limit = [limit integerValue];
        
        // only get non expired items
        [query whereKey:FIELD_DEAL_VALID_FROM lessThan:[NSDate date]];
        [query whereKey:FIELD_DEAL_VALID_TO greaterThanOrEqualTo:[NSDate date]];
        [query orderByAscending:FIELD_DEAL_DEAL_PRICE];

        [query whereKey:FIELD_DEAL_OWNER equalTo:dealer];
        [query findObjectsInBackgroundWithBlock:^(NSArray *favDeals, NSError *error) {
            if (!error) {
                NSLog(@"fav dealer's deals list : %@", favDeals);
                if ([favDeals count]) {
                    if ([dealIndex intValue] == 0) {
                        [favoriteDealerDeals removeAllObjects];
                        favoriteDealerDeals = [favDeals mutableCopy];
                    }else{
                        [favoriteDealerDeals addObjectsFromArray:[favDeals mutableCopy]];
                    }
                }else{
                    if (![favoriteDealerDeals count])
                    {
//                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"No favorite deals found!"];
                    }
                }
                
                NSLog(@"my fav dealer's deals: %@", favoriteDealerDeals);
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"favDealerDealsFetchNotification"
                 object:nil];
            }
            
            isProcessingFavDealersDeal = !isProcessingFavDealersDeal;
        }];
    }
}


-(void) getFavDealerDealsSearchWithDealer: (PFObject *) dealer WithIndex: (NSNumber *) dealIndex withLimit:(NSNumber *) limit{
    
    if (isProcessingFavDealersDealSearch) return;
    
    isProcessingFavDealersDealSearch = !isProcessingFavDealersDealSearch;
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_DEAL];
        query.skip = [dealIndex integerValue];
        query.limit = [limit integerValue];
        
        // only get non expired items
        [query whereKey:FIELD_DEAL_VALID_FROM lessThan:[NSDate date]];
        [query whereKey:FIELD_DEAL_VALID_TO greaterThanOrEqualTo:[NSDate date]];
        [query orderByAscending:FIELD_DEAL_DEAL_PRICE];
        
//        NSString *regx = [NSString stringWithFormat:@"\\Q%@\\E", searchKeyword];
//        [query whereKey:FIELD_DEAL_ITEM_NAME matchesRegex:regx modifiers:@"i"];
        
        NSString *trimmedKeyword = [searchKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (trimmedKeyword.length > 0) {
            NSArray *keywords = [self splitSearchKeywordsIntoArray:searchKeyword];
            [query whereKey:FIELD_DEAL_KEYWORD containedIn:keywords];
        }
        

        [query whereKey:FIELD_DEAL_OWNER equalTo:dealer];
        [query findObjectsInBackgroundWithBlock:^(NSArray *favDeals, NSError *error) {
            if (!error) {
                NSLog(@"fav dealer's deals list : %@", favDeals);
                if ([favDeals count]) {
                    
                    if ([dealIndex intValue] == 0) {
                        [favoriteDealerDealsSearch removeAllObjects];
                        favoriteDealerDealsSearch = [favDeals mutableCopy];
                    }else{
                        [favoriteDealerDealsSearch addObjectsFromArray:[favDeals mutableCopy]];
                    }
                    
                }else{
                    if (![favoriteDealerDealsSearch count]) {
                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"There is no deals of this favorite dealer!"];
                    }
                }
                
                NSLog(@"my fav dealer's deals: %@", favoriteDealerDealsSearch);
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"favDealerDealsSearchFetchNotification"
                 object:nil];
            }
            
            isProcessingFavDealersDealSearch = !isProcessingFavDealersDealSearch;
        }];
    }
}

-(NSArray *) splitSearchKeywordsIntoArray:(NSString *)keyword{
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];
    
    NSMutableArray *finalSearchKeywordArray = [NSMutableArray new];
    NSArray *searchKeywords = [keyword componentsSeparatedByString: @" "];
    for (NSString *token in searchKeywords) {
        NSString *unfilteredString = [token lowercaseString];
        NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        [finalSearchKeywordArray addObject:resultString];
    }
    
    return [finalSearchKeywordArray copy];
}


-(void)searchMyDealsByMyNearByBusinesses{
    
    CLLocation *currentLocation = DELEGATE.locationManager.location;
    
    if (currentLocation.coordinate.latitude == 0 ){
        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Could not get current location of mobile. Please make sure you have turned on location sharing from settings"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
        return;
    }
    
    
    NSLog(@"location: %@", currentLocation);
    
    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    
    PFQuery *distanceQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS_LOCATION];
    
    // if search distance is grater than 100 miles then ommit search by distance clause
    if ([searchDistance floatValue] <= 100) {
        if (isMile)
            [distanceQuery whereKey:@"locationPoint" nearGeoPoint:geoPoint withinMiles:[searchDistance floatValue]];
        else
            [distanceQuery whereKey:@"locationPoint" nearGeoPoint:geoPoint withinKilometers:[searchDistance floatValue]];
    }
    
    
    [distanceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 0) {
                PFUser *currentUser = [PFUser currentUser];
                
                PFQuery *businessQuery = [PFQuery queryWithClassName:PARSE_CLASS_BUSINESS];
                [businessQuery whereKey:FIELD_BUSINESS_BUSINESSLOCATIONS containedIn:objects];
                [businessQuery whereKey:FIELD_BUSINESS_DEALER equalTo:currentUser];
                
                [businessQuery findObjectsInBackgroundWithBlock:^(NSArray *bizs, NSError *error) {
                    if(!error){
                        if ([bizs count]) {
                            [myNearByBusinesses removeAllObjects];
                            myNearByBusinesses = [bizs mutableCopy];
                            
                            [self fetchMyDealsSearchInTheBackgroundWithDealIndex:@0 withLimit:DEALS_FETCH_LIMIT];
                            
                        }else{
                            
                            [myDealsSearch removeAllObjects];
                            
                            NSString *msg = nil;
                            if (isMile)
                                msg = [NSString stringWithFormat:@"No deals found within %@ miles", searchDistance];
                            else
                                msg = [NSString stringWithFormat:@"No deals found within %@ km", searchDistance];
                            
//                            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:msg];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
                        }
                    }else{
                        NSLog(@"error ayo: %@", [error userInfo]);
                        [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Unknown error occurred. Please try later."];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
                    }
                }];
            }
            else{
                [myDealsSearch removeAllObjects];
                
                NSString *msg = nil;
                if (isMile)
                    msg = [NSString stringWithFormat:@"No deals found within %@ miles", searchDistance];
                else
                    msg = [NSString stringWithFormat:@"No deals found within %@ km", searchDistance];
                
//                [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:msg];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
            }
        }
        else{
            NSLog(@"error ayo: %@", [error userInfo]);
            [DELEGATE showAlertViewWithTitle:APPLICATION_NAME withMessage:@"Unknown error occurred. Please try later."];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"myDealsSearchNotification" object:nil];
        }
    }];
    
    
}



@end
