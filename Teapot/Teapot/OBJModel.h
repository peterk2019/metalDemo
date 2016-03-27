//
//  OBJModel.h
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBJGroup;

@interface OBJModel : NSObject

- (instancetype) initWithContentsOfURL :(NSURL*)fileUrl generateNormals:(BOOL)generateNormals;

@property (nonatomic, readonly) NSArray * groups;

- (OBJGroup*) groupForName :(NSString*)groupName;

@end
