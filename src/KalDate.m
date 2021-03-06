/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalDate.h"
#import "KalPrivate.h"

static KalDate *today;


@interface KalDate ()
+ (void)cacheTodaysDate;
@end


@implementation KalDate

+ (void)initialize
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheTodaysDate) name:UIApplicationSignificantTimeChangeNotification object:nil];
  [self cacheTodaysDate];
}

+ (void)cacheTodaysDate
{
  [today release];
  today = [[KalDate dateFromNSDate:[NSDate date]] retain];
}

+ (KalDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
  return [[[KalDate alloc] initForDay:day month:month year:year] autorelease];
}

+ (KalDate *)dateFromNSDate:(NSDate *)date
{
  NSDateComponents *parts = [date cc_componentsForMonthDayAndYear];
  return [KalDate dateForDay:(unsigned int)[parts day] month:(unsigned int)[parts month] year:(unsigned int)[parts year]];
}

+ (KalDate *)dateFromNSDate:(NSDate *)date withColorId:(NSUInteger) colorId
{
    NSDateComponents *parts = [date cc_componentsForMonthDayAndYear];
    
    KalDate *kalDate = [[[KalDate alloc] initForDay:(unsigned int)[parts day]
                                              month:(unsigned int)[parts month]
                                               year:(unsigned int)[parts year]] autorelease];
    kalDate.colorId = colorId;
    
    return kalDate;
}

- (id)initForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
  if ((self = [super init])) {
    a.day = day;
    a.month = month;
    a.year = year;
    self.colorId = -1;
  }
  return self;
}

- (unsigned int)day { return a.day; }
- (unsigned int)month { return a.month; }
- (unsigned int)year { return a.year; }

- (NSDate *)NSDate
{
  NSDateComponents *c = [[[NSDateComponents alloc] init] autorelease];
  c.day = a.day;
  c.month = a.month;
  c.year = a.year;
  return [[NSCalendar currentCalendar] dateFromComponents:c];
}

- (BOOL)isToday { return [self isEqual:today]; }

- (NSComparisonResult)compare:(KalDate *)otherDate
{
  NSInteger selfComposite = a.year*10000 + a.month*100 + a.day;
  NSInteger otherComposite = [otherDate year]*10000 + [otherDate month]*100 + [otherDate day];
  
  if (selfComposite < otherComposite)
    return NSOrderedAscending;
  else if (selfComposite == otherComposite)
    return NSOrderedSame;
  else
    return NSOrderedDescending;
}

#pragma mark -
#pragma mark NSObject interface

- (BOOL)isEqual:(id)anObject
{
    if (![anObject isKindOfClass:[KalDate class]])
        return NO;
    
    KalDate *d = (KalDate*)anObject;
    
    if (self.colorId > -1)
    {
        return a.day == [d day] && a.month == [d month] && a.year == [d year] && self.colorId == d.colorId;
    }
    else if (self.selectedDate)
    {
        return a.day == [d day] && a.month == [d month] && a.year == [d year] && self.selectedDate == d.selectedDate;
    }
    
    return a.day == [d day] && a.month == [d month] && a.year == [d year];
}

- (NSUInteger)hash
{
  return a.day;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%u/%u/%u", a.month, a.day, a.year];
}

@end
