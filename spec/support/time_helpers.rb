module TimeHelpers
	def equal_dates(date1, date2)
		date1.utc.year == date2.utc.year &&
		date1.utc.month == date2.utc.month &&
		date1.utc.mday == date2.utc.mday &&
		date1.utc.hour == date2.utc.hour &&
		date1.utc.min == date2.utc.min &&
		date1.utc.sec == date2.utc.sec 
	end
end