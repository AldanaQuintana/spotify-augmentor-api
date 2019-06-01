module TimeHelpers
	def equal_dates(date1, date2)
		date1.year == date2.year
		date1.month == date2.month
		date1.mday == date2.mday
		date1.hour == date2.hour
		date1.min == date2.min
		date1.sec == date2.sec
	end
end