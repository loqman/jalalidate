# frozen_string_literal: true
# encoding: utf-8

# Usage:
#   JalaliDateParser.parse("1402/02/25")
#   JalaliDateParser.parse("۱۴۰۲-۰۲-۲۵ ۰۶:۰۱")
#   JalaliDateParser.parse("25 اردیبهشت 1402")
#   JalaliDateParser.parse("25 اردیبهشت 1402 ساعت 6:01:30")
#   JalaliDateParser.parse("1402.2.25")
#   JalaliDateParser.parse("1402/02/25T06:01:30")
#
# Returns:
#   {
#     jalali: #<JalaliDate ...>,
#     gregorian: #<DateTime ...>,
#     components: {
#       year: 1402,
#       month: 2,
#       day: 25,
#       hour: 06,
#       min: 01,
#       sec: 30
#     }
#   }

require "date"
require "jalalidate"

module JalaliDateParser
  PERSIAN_DIGITS = "۰۱۲۳۴۵۶۷۸۹"
  ENGLISH_DIGITS = "0123456789"
  ARABIC_DIGITS = "٠١٢٣٤٥٦٧٨٩"

  MONTHS = {
    "فروردین" => 1,
    "اردیبهشت" => 2,
    "خرداد" => 3,
    "تیر" => 4,
    "مرداد" => 5,
    "شهریور" => 6,
    "مهر" => 7,
    "آبان" => 8,
    "آذر" => 9,
    "دی" => 10,
    "بهمن" => 11,
    "اسفند" => 12
  }.freeze

  COMMON_PATTERNS = [
    # 1403/01/15
    # 1403-01-15
    # 1403.01.15
    {
      regex: /
        (?<year>\d{4})
        [\/\-.]
        (?<month>\d{1,2})
        [\/\-.]
        (?<day>\d{1,2})
        (?:[T\s]+(?<time>\d{1,2}:\d{1,2}(?::\d{1,2})?))?
      /x
    },

    # 15/01/1403
    # 15-01-1403
    {
      regex: /
        (?<day>\d{1,2})
        [\/\-.]
        (?<month>\d{1,2})
        [\/\-.]
        (?<year>\d{4})
        (?:[T\s]+(?<time>\d{1,2}:\d{1,2}(?::\d{1,2})?))?
      /x
    },

    # 15 فروردین 1403
    # فروردین 15 1403
    {
      regex: /
        (?:
          (?<day>\d{1,2})\s+
          (?<month_name>[[:word:]\p{Arabic}]+)\s+
          (?<year>\d{4})
          |
          (?<month_name2>[[:word:]\p{Arabic}]+)\s+
          (?<day2>\d{1,2})\s+
          (?<year2>\d{4})
        )
        (?:.*?(?<time>\d{1,2}:\d{1,2}(?::\d{1,2})?))?
      /x
    }
  ].freeze

  class ParseError < StandardError; end

  module_function

  def parse(input)
    raise ParseError, "Empty input" if input.nil? || input.strip.empty?

    str = normalize(input)

    COMMON_PATTERNS.each do |pattern|
      match = str.match(pattern[:regex])
      next unless match

      year  = (match[:year] || match[:year2]).to_i
      day   = (match[:day] || match[:day2]).to_i

      month =
        if match.names.include?("month")
          match[:month].to_i
        else
          MONTHS[match[:month_name] || match[:month_name2]]
        end

      hour, min, sec = extract_time(match[:time])

      validate!(year, month, day, hour, min, sec)

      jdate = JalaliDate.new(year, month, day, hour, min, sec)
      gdate = jdate.to_gregorian.to_datetime

      return {
        jalali: jdate,
        gregorian: gdate,
        components: {
          year: year,
          month: month,
          day: day,
          hour: hour,
          min: min,
          sec: sec
        }
      }
    end

    raise ParseError, "Unsupported Jalali date format: #{input}"
  end

  def normalize(str)
    s = str.dup

    # Persian/Arabic digits → English
    s.tr!(PERSIAN_DIGITS, ENGLISH_DIGITS)
    s.tr!(ARABIC_DIGITS, ENGLISH_DIGITS)

    # Normalize Arabic chars
    s.gsub!("ي", "ی")
    s.gsub!("ك", "ک")

    # Remove extra words
    s.gsub!(/ساعت|در|،/, " ")

    # Normalize whitespace
    s.gsub!(/\s+/, " ")

    s.strip
  end

  def extract_time(time_str)
    return [0, 0, 0] unless time_str

    parts = time_str.split(":").map(&:to_i)

    [
      parts[0] || 0,
      parts[1] || 0,
      parts[2] || 0
    ]
  end

  def validate!(year, month, day, hour, min, sec)
    raise ParseError, "Invalid year" unless year > 0
    raise ParseError, "Invalid month" unless month.between?(1, 12)
    raise ParseError, "Invalid day" unless day.between?(1, 31)
    raise ParseError, "Invalid hour" unless hour.between?(0, 23)
    raise ParseError, "Invalid minute" unless min.between?(0, 59)
    raise ParseError, "Invalid second" unless sec.between?(0, 59)
  end
end