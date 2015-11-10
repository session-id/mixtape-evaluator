import billboard
import datetime

# Gets all charts between the specified start and end dates.
# Start date must be a Saturday.
def get_charts(chart_name, start_date, end_date):
  print('Getting charts...')
  charts = []
  # Scrape every week from start to end
  cur_date = start_date
  while (cur_date <= end_date):
    print(cur_date)
    date_str = "%s" % cur_date
    chart = billboard.ChartData(chart_name, cur_date)
    charts.append(chart)
    cur_date = cur_date + datetime.timedelta(days = 7)

  return charts

# Writes the given charts to a file
def write_charts_to_file(charts, filename):
  

# charts = getCharts('hot-100', datetime.date(2015,10,17), datetime.date.today())
# print charts[0]