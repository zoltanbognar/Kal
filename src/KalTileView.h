/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

enum {
  KalTileTypeRegular   = 0,
  KalTileTypeAdjacent  = 1 << 0,
  KalTileTypeToday     = 1 << 1,
};
typedef char KalTileType;

enum {
    KalTileMarkerColorRed   = 0,
    KalTileMarkerColorYellow  = 1 << 0,
    KalTileMarkerColorGreen   = 1 << 1,
    KalTileMarkerColorDefault   = 1 << 2,
};
typedef char KalTileMarkerColor;

@class KalDate;

@interface KalTileView : UIView
{
  KalDate *date;
  CGPoint origin;
  struct {
    unsigned int selected : 1;
    unsigned int highlighted : 1;
    unsigned int marked : 1;
    unsigned int type : 2;
    unsigned int color : 3;
    unsigned int new_edit : 1;
  } flags;
}

@property (nonatomic, retain) KalDate *date;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isMarked) BOOL marked;
@property (nonatomic, getter=isNew_Edit) BOOL new_edit;
@property (nonatomic) KalTileType type;
@property (nonatomic) KalTileMarkerColor color;

- (void)resetState;
- (BOOL)isToday;
- (BOOL)belongsToAdjacentMonth;

@end
