//
//  Post.h
//  SocialStash
//
//  Created by Russ Fellman on 9/4/13.
//  Copyright (c) 2013 Russ Fellman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSData * attachedImage;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDictionary* posts;

@end
