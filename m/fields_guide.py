# Convenience file for locating fields

fields = '"","ArtistId","Day","Date","Facebook_PageLikes_d","Facebook_PageLikes_t","Facebook_TalkingAboutThis_7day__d","Instagram_Comments_d","Instagram_Comments_t","Instagram_Followers_d","Instagram_Followers_t","Instagram_Friends_Following__d","Instagram_Friends_Following__t","Instagram_Likes_d","Instagram_Likes_t","Instagram_Photos_d","Instagram_Photos_t","Lastfm_Listeners_d","Lastfm_Listeners_t","Lastfm_Plays_d","Lastfm_Plays_t","Lastfm_Shouts_d","Lastfm_Shouts_t","MediabaseFeed_RadioSpins_d","MySpace_Friends_d","MySpace_Friends_t","MySpace_Plays_d","MySpace_Plays_t","MySpace_ProfileViews_d","MySpace_ProfileViews_t","Pandora_Fans_d","Pandora_Fans_t","Purevolume_Comments_d","Purevolume_Comments_t","Purevolume_Fans_Favorites__d","Purevolume_Fans_Favorites__t","Purevolume_Plays_d","Purevolume_Plays_t","RadioWave_InternetRadioImpressions_d","RadioWave_InternetRadioSpins_d","RadioWave_PandoraImpressions_d","RadioWave_PandoraSpins_d","RadioWave_RhapsodyImpressions_d","RadioWave_RhapsodySpins_d","RadioWave_SiriusImpressions_d","RadioWave_SiriusSpins_d","RadioWave_SlackerImpressions_d","RadioWave_SlackerSpins_d","Rdio_Collections_d","Rdio_Collections_t","Rdio_Comments_d","Rdio_Comments_t","Rdio_Playlists_d","Rdio_Playlists_t","Rdio_Plays_d","Rdio_Plays_t","Rdio_TrackListeners_d","Rdio_TrackListeners_t","ReverbNation_Fans_d","ReverbNation_Fans_t","ReverbNation_Plays_d","ReverbNation_Plays_t","ReverbNation_RemoteImpressions_d","ReverbNation_RemoteImpressions_t","SoundCloud_Comments_d","SoundCloud_Comments_t","SoundCloud_Downloads_d","SoundCloud_Downloads_t","SoundCloud_Followers_d","SoundCloud_Followers_t","SoundCloud_Plays_d","SoundCloud_Plays_t","Twitter_Followers_d","Twitter_Followers_t","Twitter_Friends_Following__d","Twitter_Friends_Following__t","Twitter_Lists_d","Twitter_Lists_t","Twitter_Tweets_d","Twitter_Tweets_t","Vevo_VideoViews_d","Vevo_VideoViews_t","Vimeo_Comments_d","Vimeo_Comments_t","Vimeo_Plays_d","Vimeo_Plays_t","Vimeo_VideoLikes_d","Vimeo_VideoLikes_t","Wikipedia_Pageviews_d","YouTube_ChannelViews_d","YouTube_ChannelViews_t","YouTube_Subscribers_d","YouTube_Subscribers_t","YouTube_Thumbs_d","YouTube_Thumbs_t","YouTube_VideoFavorites_d","YouTube_VideoFavorites_t","YouTube_VideoRaters_d","YouTube_VideoRaters_t","YouTube_VideoViews_d","YouTube_VideoViews_t","iTunes_AlbumUnits_Net__d","iTunes_TrackUnits_Net__d","IsReleaseDay"'
ftn = {}
ftn2 = {}
fields_list = fields.split(',')
j = 0
for i in range(len(fields_list)):
  ftn[fields_list[i][1:-1]] = i + 1
  # ftn2 is used for the data matrix, which doesn't contain the "" and "Date" fields
  if i != 0 and i != 3:
    ftn2[fields_list[i][1:-1]] = j + 1
    j += 1

pca_fields = ["Facebook_PageLikes_t", "Instagram_Comments_t", "Instagram_Followers_t", "Instagram_Likes_t", "Twitter_Followers_t", "Twitter_Tweets_t"]
for field in pca_fields:
  print(field + ": " + str(ftn2[field]))