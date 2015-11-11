# Get and save raw charts from billboard

import pickle
import datetime
import chart_scraper

'''
hot-100: top 100 songs
billboard-200: top 200 albums
artist-100: top 100 artists
r-b-hip-hop-songs: top 25
pop-songs: top 20
country-songs: top 25
rock-songs: top 25
dance-electronic-songs: top 25
latin-songs: top 25
christian-songs: top 25
'''

# Note: some charts do not have data for entire range of dates
chart_names = ['hot-100', 'billboard-200', 'artist-100', 'r-b-hip-hop-songs', 'pop-songs', 'latin-songs'\
  'country-songs', 'rock-songs', 'dance-electronic-songs', 'christian-songs']

for chart_name in chart_names:
  # Grab charts from 1/1/2000 to 11/1/2015
  start_date = datetime.date(2000, 1, 1)
  end_date = datetime.date(2015, 11, 1)
  charts = chart_scraper.get_charts(chart_name, start_date, end_date)
  print('Charts returned for ' + chart_name)

  pickle.dump(charts, open('chart-data/' + chart_name + '_charts.pickle', 'wb'))