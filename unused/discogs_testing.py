# Example of using discogs client to retrieve info

import discogs_client

d = discogs_client.Client('TestApp', user_token='VzgIBHnQRiOQxObNXiDsELJjnsZYseKZfdQlkwTu')

# Search for release
releases = d.search(title='King Kunta', artist='Kendrick Lamar', type='release')
releases[0].artists # All artists
releases[0].data # Contains style, genre, label, release id
releases[0].data['label']

# Search for artist
artists = d.search('Kendrick Lamar', type='artist')
artists[0].releases # Contains artist releases (Master and Release)
artists[0].aliases # Artist aliases