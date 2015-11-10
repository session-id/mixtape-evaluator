import chart_scraper
import discogs_getter
import datetime
import time
import pickle

scrape_chart_data = False # Whether or not to scrape billboard for chart data

# All relevant information for a song
class Song:
  def __init__(self, **entries):
    self.__dict__.update(entries)

  def __init__(self, title, artists, weeks, peak_pos, labels = [], genres = [], styles = []):
    self.title = title
    self.artists = artists
    self.weeks = weeks
    self.peak_pos = peak_pos
    self.labels = labels
    self.genres = genres
    self.styles = styles

  # Updates a song with discogs artists, labels, genres, and styles information
  def update(self, artists, labels, genres, styles):
    self.atists = artists
    self.labels = labels
    self.genres = genres
    self.styles = styles

if scrape_chart_data:
  # Grab charts from 1/1/2000 to 1/1/2012 as training data
  start_date = datetime.date(2000, 1, 1)
  #end_date = datetime.date(2000, 1, 14)
  end_date = datetime.date(2012,1,1)
  charts = chart_scraper.get_charts('hot-100', start_date, end_date)
  print('Charts returned')

  # Separate out all unique songs by combining all songs with same title and artist
  ce_to_songs = dict()
  for chart in charts:
    for entry in chart:
      entry_string = entry.title + ' - ' + entry.artist
      # Deal with Featuring
      index = entry.artist.find('Featuring')
      artist = entry.artist
      if index != -1:
        artist = entry.artist[:index-1]
      ce_to_songs[entry_string] = Song(entry.title, [artist], entry.weeks, entry.peakPos)

  pickle.dump(ce_to_songs, open('chart-data/chart_songs_train.pickle', 'wb'))

ce_to_songs = pickle.load(open('chart-data/chart_songs_train.pickle', 'rb'))

# Find statistics on artists
artist_to_song = dict()
for _, song in ce_to_songs.iteritems():
  for artist in song.artists:
    if artist in artist_to_song:
      artist_to_song[artist].append(song)
    else:
      artist_to_song[artist] = [song]

'''
songs = []
# Grab discogs info for each song, don't add if no information found
for title_artist, song in ce_to_songs.iteritems():
  time.sleep(3.5) # To keep rate limited to at most 20 requests per second
  try:
    release_data = discogs_getter.get_release_data(song.title, song.artists[0])
    if (release_data == None):
      print('Skipping song: ' + title_artist)
      continue

    song.update(release_data.artists, release_data.labels, release_data.genres, release_data.styles)
    songs.append(song)
    print('Added song: ' + title_artist)
  except:
    print('Skipping song due to exception: ' + title_artist)
'''

'''
Note: A better approach to all this song by song method may be to compile a list of all artists at the end
and grab song data then... however, it will probably still be fairly slow.
'''
# Note: look at trying to dissect "Featuring"