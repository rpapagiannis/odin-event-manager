# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode) # rubocop:disable Metrics/MethodLength
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  legislators = civic_info.representative_info_by_address(
    address: zipcode,
    levels: 'country',
    roles: %w[legislatorUpperBody legislatorLowerBody]
  )

  legislators = legislators.officials
  legislator_names = legislators.map(&:name)
  legislator_names.join(', ')
rescue StandardError
  'You can find representatives by visiting www.commoncause.org/take-action/find-elected-officials'
end

puts 'Event manager initialized!'

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

template_letter = File.read('form_letter.html')

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  personal_letter = template_letter.gsub('FIRST_NAME', name)

  personal_letter.gsub!('LEGISLATORS', legislators)
  puts personal_letter
end
