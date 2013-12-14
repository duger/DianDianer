//
//  XMPPSearch.m
//  iTalk
//
//  Created by admin on 12-1-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "XMPPSearch.h"

@implementation SearchResult

@synthesize userName = _userName, userJID = _userJID, name = _name, email = _email;

- (void) dealloc
{
    [_userName release];
    [_userJID  release];
    [_name     release];
    [_email    release];
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"userName-->%@.,userJID-->%@.,name-->%@.,email-->%@",_userName,_userJID,_name,_email];
}

@end

@interface XMPPSearch (PrivateMethods)

- (NSXMLElement *)fieldWithVar:(NSString *)varValue Type:(NSString *)typeValue andValue:(NSString *)valueOfField;
- (NSXMLElement *)fieldWithVar:(NSString *)varValue Label:(NSString *)labelValue Type:(NSString *)typeValue andValue:(NSString *)valueOfField;
- (NSXMLElement *)iqForSearchUserWithKeyWords:(NSString *)keyWords;
- (void) setSearchType:(NSString *)typeName forIqdata:(NSXMLElement *)iq_x;
- (void) requestSearchFields;

@end

@implementation XMPPSearch

#pragma mark PublicMethods

- (void)searchUserWithITalkNumber:(NSString *)italkNumber_
{
//    [self requestSearchFields];
    
    NSLog(@"iqForSearchUserWithKeyWords:%@",[self iqForSearchUserWithKeyWords:italkNumber_]);
    
    [xmppStream sendElement:[self iqForSearchUserWithKeyWords:italkNumber_]];
}

#pragma mark PrivateMethods

//these methods may add to nsxmlelement as categroies
- (NSXMLElement *)fieldWithVar:(NSString *)varValue Label:(NSString *)labelValue Type:(NSString *)typeValue andValue:(NSString *)valueOfField
{
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    
    if(varValue != nil)
        [field addAttributeWithName:@"var" stringValue:varValue];
    
    if(typeValue != nil)
        [field addAttributeWithName:@"type" stringValue:typeValue];
    
    if(labelValue != nil)
        [field addAttributeWithName:@"label" stringValue:labelValue];
    
    if(valueOfField != nil)
    {
        NSXMLElement *value = [NSXMLElement elementWithName:@"value" stringValue:valueOfField];
        [field addChild:value];
    }
    
    return field;
}

- (NSXMLElement *)fieldWithVar:(NSString *)varValue Type:(NSString *)typeValue andValue:(NSString *)valueOfField
{
    return [self fieldWithVar:varValue Label:nil Type:typeValue andValue:valueOfField];
}

- (NSXMLElement *)iqForSearchUserWithKeyWords:(NSString *)keyWords
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    NSXMLElement *field_1 = [self fieldWithVar:@"FORM_TYPE" Type:@"hidden" andValue:@"jabber:iq:search"];
    NSXMLElement *field_2 = [self fieldWithVar:@"search" Type:@"text-single" andValue:keyWords];
  
    [self setSearchType:@"Username" forIqdata:x];
    
    [x addChild:field_1];
    [x addChild:field_2];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:search"];
    
    [query addChild:x];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"search.a051203020114"];
    
    [iq addChild:query];
    
    return iq;
}

- (void) setSearchType:(NSString *)typeName forIqdata:(NSXMLElement *)iq_x
{
    NSXMLElement *field = [self fieldWithVar:typeName Type:@"boolean" andValue:@"1"];
    
    [iq_x addChild:field];
}

- (void) requestSearchFields
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:search"];
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addAttributeWithName:@"to" stringValue:@"search.a051203020114"];
    
    [iq addChild:query];
    
    NSLog(@"findthesearchfield.iq:%@",iq);
    
    [xmppStream sendElement:iq];
}

#pragma mark XMPPStreamDelegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //NSLog(@"xmppsearch.iq:%@",iq);
    
    NSXMLElement *query = [iq elementForName:@"query" xmlns:@"jabber:iq:search"];
    
    if(query)
    {
        NSArray *items = [[query elementForName:@"x" xmlns:@"jabber:x:data"] elementsForName:@"item"];
        
        NSMutableArray *searchResults = [[NSMutableArray alloc] initWithCapacity:1];
        
        for(NSXMLElement *item in items)
        {
            NSArray *fields = [item elementsForName:@"field"];
            
            SearchResult *result = [[SearchResult alloc] init];
            
            for(NSXMLElement *field in fields)
            {
                NSString *var = [field attributeStringValueForName:@"var"];
                NSString *value = [(NSXMLElement*)[field elementForName:@"value"] stringValue];
                
                if([var isEqualToString:@"Username"])
                {
                    result.userName = value;
                }else if([var isEqualToString:@"Name"])
                {
                    result.name = value;
                }else if([var isEqualToString:@"Email"])
                {
                    result.email = value;
                }else if([var isEqualToString:@"jid"])
                {
                    result.userJID = [XMPPJID jidWithString:value];
                }
            }
            
            [searchResults addObject:result];
            
            [result release];
        }
    
        [multicastDelegate xmppSearch:self searchResults:searchResults];
        
        [searchResults release];
    }
    
    
    return YES;
}

@end
