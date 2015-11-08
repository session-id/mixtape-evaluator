import discogs_client

d = discogs_client.Client('TestApp', user_token='VzgIBHnQRiOQxObNXiDsELJjnsZYseKZfdQlkwTu')

# Release data is composed of string lists of artists, labels, genres, and styles.
class ReleaseData:
  def __init__(self, artists, labels, genres, styles):
    self.artists = artists
    self.labels = labels
    self.genres = genres
    self.styles = styles

# Gets a ReleaseData object for the given title and artist, returning None if the specific pair
# is not found in the Discogs database.
def get_release_data(title, artist):
  releases = d.search(title=title, artist=artist, type='release')
  for release in releases:
    artist_names = map(lambda artist: artist.name, release.artists)
    if (release.title == title and artist in artist_names):
      return ReleaseData(release.artist_names, release.data['label'], release.data['genre'],\
        release.data['style'])

  return None