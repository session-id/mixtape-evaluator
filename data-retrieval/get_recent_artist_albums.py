# Gets all recent artists from 2009 - present on the hot-100 and retrieves a list of their
# albums since 2009 with track listings

import pickle
import datetime
import spotipy

build_artists = False # Whether or not to build the recent artists list from scratch
build_artist_to_ids = False # Whether or not to build the artists to id table

start_date = datetime.date(2009, 1, 1)

if build_artists:
  charts = pickle.load(open('chart-data/billboard-200_charts.pickle', 'rb'))
  for i in range(len(charts)):
    if charts[i].date > start_date:
      break

  recent_charts = charts[i:]

  def sanitize_artist_name(name):
    return name

  # Compile all artists
  artists = set()
  for chart in recent_charts:
    for album in chart:
      artists.add(sanitize_artist_name(album.artist))

  pickle.dump(artists, open('chart-data/recent_artists.pickle', 'wb'))

artists = pickle.load(open('chart-data/recent_artists.pickle', 'rb'))
print(str(len(artists)) + ' artists loaded.')

if build_artist_to_ids:
  spotify = spotipy.Spotify()
  artist_to_id = {}
  # Spotify query for artists
  for artist in artists:
    print('Finding artist id for ' + artist)
    results = spotify.search(q = 'artist:' + artist, type = 'artist')
    artist_id = ''
    # Find artist that matches name
    for search_artist in results['artists']['items']:
      if search_artist['name'].lower() == artist.lower():
        artist_id = search_artist['id']
        break

    # If match found
    if artist_id != '':
      artist_to_id[artist] = artist_id

  pickle.dump(artist_to_id, open('chart-data/artist_to_spotify_id.pickle', 'wb'))

artist_to_id = pickle.load(open('chart-data/artist_to_spotify_id.pickle', 'rb'))

# Query for album data
artist_to_albums = {}
for artist, artist_id in artist_to_id.iteritems():
  try:
    print ('Loading albums for ' + artist)

    results = spotify.artist_albums(artist_id, album_type='album')
    albums = results['items']
    while results['next']:
      results = spotify.next(results)
      albums.extend(results['items'])

    artist_to_albums[artist] = {}
    # Find all relevant albums
    for album in albums:
      s_album = spotify.album(album['id'])
      # Check to make sure release is after start_date
      try:
        release_date = datetime.datetime.strptime(s_album['release_date'], '%Y-%m-%d').date()
      except:
        continue
      if release_date >= start_date:
        tracks = map(lambda track: track['name'], s_album['tracks']['items'])
        artist_to_albums[artist][s_album['name']] = (release_date, tracks)
  except:

pickle.dump(artist_to_albums, open('chart-data/artist_to_albums.pickle', 'wb'))