# Jalali Date Library
A lightweight Ruby library for converting, formatting, and parsing Jalali (جلالی/Persian/Shamsi) dates.

Jalalidate provides simple APIs for:

* Gregorian → Jalali conversion
* Jalali → Gregorian conversion
* Jalali date formatting
* Parsing Persian date strings
* Working with Persian numerals and month names

## Install
Add this line to your application's Gemfile:

```ruby
 gem 'jalalidate' 
```

And then execute:

    $ bundle install

Or install it manually:

    $ gem install jalalidate

## Usage
Date conversion and class methods:
```ruby
require 'jalalidate'

# Create a jalali date object:
j_date = JalaliDate.new(1402,02,25)
#=> <JalaliDate, :year => 1402, :month => 2, :day => 25 >

j_date = JalaliDate.new(Date.today)
#=> <JalaliDate, :year => 1402, :month => 2, :day => 25 >

# Initialize with hour, minute and second
j_date = JalaliDate.new(Time.now)
#=> <JalaliDate, :year => 1402, :month => 2, :day => 25, :hour => 6, :minute => 01, :second => 30 >

# Convert to gregorian date
g_date = j_date.to_gregorian
g_date = j_date.to_g
#=> Mon, 15 May 2023


# Get yesterday, today, or tomorrow in jalali
j_today = JalaliDate.yesterday
#=> <JalaliDate, :year => 1402, :month => 2, :day => 24 >
j_today = JalaliDate.today
#=> <JalaliDate, :year => 1402, :month => 2, :day => 25 >
j_tomorrow = JalaliDate.tomorrow
#=> <JalaliDate, :year => 1402, :month => 2, :day => 26 >
 
# Get year, month, and day
year = j_date.year       #=> 1402
month = j_date.month     #=> 02
day = j_date.day         #=> 25

# Get gregorian year, month, and day
g_year = j_date.g_year   #=> 2023
g_month = j_date.g_month #=> 5
g_day = j_date.g_day     #=> 15

# Get day of the year
dy = j_date.yday #=> 51

# Get the next day
tomorrow = j_date.next
#=> <JalaliDate, :year => 1402, :month => 2, :day => 26 >

# Add and substract days
j_date + 6.days
#=> <JalaliDate, :year => 1402, :month => 2, :day => 31 >
j_date + 1.month
#=> <JalaliDate, :year => 1402, :month => 3, :day => 25 >
j_date + 2.years + 5.month + 12.days
#=> <JalaliDate, :year => 1404, :month => 8, :day => 5 >

# Shift the date with number of month
j_date >> 5
#=> <JalaliDate, :year => 1402, :month => 7, :day => 25 >
j_date << 5
#=> <JalaliDate, :year => 1401, :month => 9, :day => 25 >

# Compare two dates
j_date < j_date.next       #=> true
j_date > j_date.next       #=> false
j_date > j_date.previous   #=> true
j_date <=> j_date.next     #=> -1
j_date <=> j_date          #=> 0
j_date <=> j_date.previous #=> 1

# Cycle through dates in different ways, namely, step, upto and downto
# every 2 days, including j_date, for the next 10 days
j_date.step( j_date + 10 , 2)

# every day, including j_date and the next 5 days
j_date.upto(j_date + 5)

# every day, including j_date and the previous 5 days
j_date.downto(j_date - 5)


# Get day object as array or hash
j_date.to_a     #=> [1405, 2, 25]
j_date.to_hash  #=> {year: 1405, month: 2, day: 25}


# Check for leap year
JalaliDate.leap? 1402
#=> false

# Check for validity of a jalali date
JalaliDate.valid?(1402,02,25)
#=> true

JalaliDate.valid?(1402,12,30)
#=> false
```

### Date formatting:

```ruby
# Initialize with hour, minute and second
j_date = JalaliDate.new(Time.now)
#=> <JalaliDate, :year => 1402, :month => 2, :day => 25, :hour => 6, :minute => 01, :second => 30 >

j_date.strftime("%a %A %b %B %d %e %j %m %w %y %Y %% %x")
#=> "۲ش دوشنبه اردیبهشت Ordibehesht 25 25 56 2 1 02 1402 % 02/2/25"

j_date.strftime("%X")
#=> "06:01:30"

j_date.strftime("%H:%M - %Y/%n/%d")
#=> "06:01 - 1402/02/25"
```

## Format meanings:

- `[%a]` The abbreviated weekday name (۳ش)
- `[%A]` The full weekday name (یکشنبه)
- `[%b]` The month name (اردیبهشت)
- `[%B]` The month name in pinglish (Ordibehesht)
- `[%d]` Day of the month (01..31)
- `[%e]` Day of the month (1..31)
- `[%j]` Day of the year (1..366)
- `[%m]` Month of the year (1..12)
- `[%n]` Month of the year (01..12)
- `[%w]` Day of the week (Sunday is 0, 0..6)
- `[%x]` Preferred representation for the date alone, no time in format YY/M/D
- `[%y]` Year without a century (00..99)
- `[%Y]` Year with century
- `[%H]` Hour of the day, 24-hour clock (00..23)
- `[%I]` Hour of the day, 12-hour clock (01..12)
- `[%M]` Minute of the hour (00..59)
- `[%p]` Meridian indicator ("بعد از ظهر" or "قبل از ظهر")
- `[%P]` Meridian indicator ("ب.ظ" or "ق.ظ")
- `[%S]` Second of the minute (00..60)
- `[%X]` Preferred representation for the time alone, no date
- `[%Z]` Time zone name
- `[%%]` teral %'' character

## Parsing Jalali Dates

The parser supports multiple common Persian date formats.

### Numeric Formats
```ruby
JalaliDate.parse('1402/02/25')
JalaliDate.parse('1402-02-25')
JalaliDate.parse('1402.02.25')
```
### Persian Month Names
```ruby 
JalaliDate.parse('25 اردیبهشت 1402')
JalaliDate.parse('اردیبهشت 25 1402')
```

### DateTime Parsing
```ruby 
JalaliDate.parse('1402/02/25 06:01')
JalaliDate.parse('1402/02/25 06:01:30')
JalaliDate.parse('25 اردیبهشت ۱۴۰۲ ساعت ۰۶:۰۱')
```

### Persian Digits

The parser automatically normalizes Persian and Arabic numerals:

```ruby
JalaliDate.parse('۱۴۰۲/۰۲/۲۵')
JalaliDate.parse('١٤٠۲/٠٢/٢٥')
```

## Tests
Simply run `rspec` command in the source directory:

    $ bundle exec rspec

## History

#### 0.3.3 - 17.SEP.2013
* added %n formatter for numeric representation of a month, with leading zeros, courtesy of [Mohsen Alizadeh](https://github.com/m0h3n)

#### 0.3.2 - 8.APR.2013
* Making JalaliDate class thread safe, courtesy of [Jahangir Zinedine](https://github.com/jzinedine)

#### 0.3.1 - 26.APR.2011
* Added ruby 1.9 compatibility, courtesy of [Reza](https://github.com/ryco)

#### 0.3 - 6.JAN.2011
* JalaiDate could be initialized with Time and DateTime objects
* More options for strftime method %H,%M,%S,%X,%Z,%I,%p. read docs for more information
* Added jdate and jcal binaries to access jcal from the command-line
* Updated some documentations
* Now using bundler

#### 0.2 - 25.FEB.2010
* Renamed the gem from JalaliDate to jalalidate
* Added spec and a full test suite
* Updated gemspec file for rubygems.org
* Updated some documentations

#### 0.02 - 8.AUG.2008
* Added jalali to geregorian date convertor.
* Added JalaliDate class and ported Date class method to JalaliDate

#### 0.01 - 7.AUG.2008
* Planning the project


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2008-2011 Allen A. Bargi. See LICENSE for details.
