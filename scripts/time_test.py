from datetime import datetime

# Define dates as strings
date_str1 = 'Wednesday, June 6, 2018'
date_str2 = '6/6/18'
date_str3 = '06-06-2018'
date_str4 = "20200616120210"

# Define dates as datetime objects
date_dt1 = datetime.strptime(date_str1, '%A, %B %d, %Y')
date_dt2 = datetime.strptime(date_str2, '%m/%d/%y')
date_dt3 = datetime.strptime(date_str3, '%m-%d-%Y')
date_dt4 = datetime.strptime(date_str4, '%Y%m%d%H%M%S')

# Print converted dates
print(date_dt1)
print(date_dt2)
print(date_dt3)
print(date_dt4)
