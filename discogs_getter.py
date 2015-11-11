import discogs_client

d = discogs_client.Client('MixtapeEvaluator/1.0', user_token='VzgIBHnQRiOQxObNXiDsELJjnsZYseKZfdQlkwTu')

# Release data is composed of string lists of artists, labels, genres, and styles.
class ReleaseData:
  def __init__(self, artists, labels, genres, styles):
    self.artists = artists
    self.labels = labels
    self.genres = genres
    self.styles = styles

# Artist date is composed of an artist's name followed by all releases in ReleaseData format
class ArtistData:
  def __init__(self, name, releases):
    self.name = name
    self.releases = releases

# Gets a ReleaseData object for the given title and artist, returning None if the specific pair
# is not found in the Discogs database.
def get_release_data(title, artist):
  releases = d.search(title=title, artist=artist, type='release')
  for release in releases:
    artist_names = map(lambda artist: artist.name, release.artists)
    if (release.title == title and artist in artist_names):
      return ReleaseData(artist_names, release.data['label'], release.data['genre'],\
        release.data['style'])

  return None

# Gets data for a given artist, including past releases
def get_artist_data(name):
  artists = d.search(name, type='artist')
  for artist in artists:
    print(artist)
    if artist.name.lower() == name.lower():
      releases = []
      for release in artist.releases:
        # Only take releases, not masters
        if type(release) is discogs_client.models.Release:
          artist_names = map(lambda artist: artist.name, release.artists)
          releases.append(ReleaseData(artist_names, release.labels, release.genres, release.styles))

      return ArtistData(name, releases)