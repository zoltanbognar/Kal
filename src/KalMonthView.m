/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalDate.h"
#import "KalPrivate.h"

extern const CGSize kTileSize;

@implementation KalMonthView

@synthesize numWeeks;

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    tileAccessibilityFormatter = [[NSDateFormatter alloc] init];
    [tileAccessibilityFormatter setDateFormat:@"EEEE, MMMM d"];
    self.opaque = NO;
    self.clipsToBounds = YES;
    for (int i=0; i<6; i++) {
      for (int j=0; j<7; j++) {
        CGRect r = CGRectMake(j*kTileSize.width, i*kTileSize.height, kTileSize.width, kTileSize.height);
        [self addSubview:[[[KalTileView alloc] initWithFrame:r] autorelease]];
      }
    }
  }
  return self;
}

- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates
{
  int tileNum = 0;
  NSArray *dates[] = { leadingAdjacentDates, mainDates, trailingAdjacentDates };
  
  for (int i=0; i<3; i++) {
    for (KalDate *d in dates[i]) {
      KalTileView *tile = [self.subviews objectAtIndex:tileNum];
      [tile resetState];
      tile.date = d;
      tile.type = dates[i] != mainDates
                    ? KalTileTypeAdjacent
                    : [d isToday] ? KalTileTypeToday : KalTileTypeRegular;
      tileNum++;
    }
  }
  
  numWeeks = ceilf(tileNum / 7.f);
  [self sizeToFit];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,kTileSize}, [[UIImage imageNamed:@"Kal.bundle/kal_tile.png"] CGImage]);
}

- (KalTileView *)firstTileOfMonth
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if (!t.belongsToAdjacentMonth) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (KalTileView *)tileForDate:(KalDate *)date
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t.date isEqual:date]) {
      tile = t;
      break;
    }
  }
  NSAssert1(tile != nil, @"Failed to find corresponding tile for date %@", date);
  
  return tile;
}

- (void)sizeToFit
{
  self.height = 1.f + kTileSize.height * numWeeks;
}

- (KalTileMarkerColor) getMarkerColor:(NSArray*) dates
{
    __block BOOL red = NO;
    __block BOOL yellow = NO;
    __block BOOL green = NO;
    
    [dates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        KalDate * kalDate = (KalDate*) obj;
        
        if (!red && kalDate.colorId == 0)
        {
            red = YES;
        }
        else if (!yellow && kalDate.colorId == 1)
        {
            yellow = YES;
        }
        else if (!green && kalDate.colorId == 2)
        {
            green = YES;
        }
    }];
    
    KalTileMarkerColor ret = KalTileMarkerColorDefault;
    
    
    if (red && !yellow && !green)
    {
        ret = KalTileMarkerColorRed;
    }
    else if (!red && !yellow && green)
    {
        ret = KalTileMarkerColorGreen;
    }
    else if (!red && !yellow && !green)
    {
        ret = KalTileMarkerColorDefault;
    }
    else
    {
        ret = KalTileMarkerColorYellow;
    }
 
    return  ret;
}

- (BOOL) hasNewSelected:(NSArray*) dates
{
    __block BOOL ret = NO;
    
    [dates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         KalDate * kalDate = (KalDate*) obj;
         
         if (kalDate.selectedDate == YES)
         {
             ret = YES;
             *stop = YES;
         }
         
    }];

    return ret;
}

- (void)markTilesForDates:(NSArray *)dates
{
    for (KalTileView *tile in self.subviews)
    {
        //NSArray * filtered = [dates filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NSDate = %@",[tile.date NSDate]]];
        
        tile.marked = [dates containsObject:tile.date];
        tile.date.selectedDate = YES;
        tile.new_edit = [dates containsObject:tile.date];
        tile.date.selectedDate = NO;
        tile.date.colorId = 0;
        tile.color = 0;
        
        
        //tile.color = tile.color | ([dates containsObject:tile.date])? KalTileMarkerColorRed : KalTileMarkerColorDefault;
        if ([dates containsObject:tile.date]) {
            tile.color = tile.color | KalTileMarkerColorRed;
        }
        
        tile.date.colorId = 1;
        
        
        //tile.color = tile.color | ([dates containsObject:tile.date])? KalTileMarkerColorYellow : KalTileMarkerColorDefault;
        if ([dates containsObject:tile.date]) {
            tile.color = tile.color | KalTileMarkerColorYellow;
        }

        
        
        tile.date.colorId = 2;
        //tile.color = tile.color | ([dates containsObject:tile.date])? KalTileMarkerColorGreen : KalTileMarkerColorDefault;
        if ([dates containsObject:tile.date]) {
            tile.color = tile.color | KalTileMarkerColorGreen;
        }
        tile.date.colorId = -1;
        
       // NSLog(@"tile marker color %d",tile.color);
       
        //    tile.marked = ([filtered count] > 0)?YES:NO;
        //    tile.color = [self getMarkerColor:filtered];
        //    tile.new_edit = [self hasNewSelected:filtered];
        
        NSString *dayString = [tileAccessibilityFormatter stringFromDate:[tile.date NSDate]];
        
        if (dayString)
        {
            NSMutableString *helperText = [[[NSMutableString alloc] initWithCapacity:128] autorelease];
            if ([tile.date isToday])
                [helperText appendFormat:@"%@ ", NSLocalizedString(@"Today", @"Accessibility text for a day tile that represents today")];
            
            [helperText appendString:dayString];
            
            if (tile.marked)
                [helperText appendFormat:@". %@", NSLocalizedString(@"Marked", @"Accessibility text for a day tile which is marked with a small dot")];
            
            [tile setAccessibilityLabel:helperText];
        }
    }
}

#pragma mark -

- (void)dealloc
{
  [tileAccessibilityFormatter release];
  [super dealloc];
}

@end
