//
//  XMPPSearch.h
//  iTalk
//
//  Created by admin on 12-1-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@interface XMPPSearch : XMPPModule {
    
}

- (void)searchUserWithITalkNumber:(NSString *)italkNumber;

@end


@protocol XMPPSearchDelegate <NSObject>

- (void)xmppSearch:(XMPPSearch *)xmppS searchResults:(NSArray *)results;

@end


@interface SearchResult : NSObject {

}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) XMPPJID  *userJID;

@end