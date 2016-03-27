//
//  OBJGroup.h
//  Teapot
//
//  Created by Volvet Zhang on 16/3/27.
//  Copyright © 2016年 volvet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBJGroup : NSObject

- (instancetype)  initWithName :(NSString*) name;

@property  (copy)   NSString * name;
@property  (copy)   NSData * vertexData;
@property  (copy)   NSData * indexData;

@end
