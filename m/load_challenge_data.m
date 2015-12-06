% Reads the data from the challenge directly into matlab

load_data = false; % Set to true to load data
if (load_data)
    fileId = fopen('challenge_data.csv');
    header = fgetl(fileId);
    C = textscan(fileId, '%s %n %n %s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n', 'Delimiter', ',', 'TreatAsEmpty', {'NA', 'na'});
    fclose(fileId);
    % data = cell2mat([C(2:3) C(5:end)]);
end

% Find times when there is data for artist reaching both backwards and
% forwards
shift_back = 7; % Number of days to shift all data backwards by
shift_forward = 7; % Number of days to shift all data forwards by
back_buffer = -ones([shift_back, 1]);
forward_buffer = -ones([shift_forward, 1]);
artist_shift_f = [forward_buffer; C{2}(1:end-shift_forward)];
artist_shift_b = [C{2}(shift_back+1:end); back_buffer];
viable_days = (artist_shift_f == artist_shift_b) & (artist_shift_f == C{2});
clear artist_shift_f
clear artist_shift_b

% Recover days that have relevant fields of information
album_releases = ~isnan(C{104}); % IsReleaseDay
has_fb_likes_t = ~isnan(C{6}); % Facebook_PageLikes_t
has_twitter_followers_t = ~isnan(C{74}); % Twitter_Followers_t

% youtube_views_delta contains total number of views (from
% Youtube_Video_Views_t) over the next [shift_back] days from any day
youtube_views_delta = n_delta(C{101}, shift_back);
youtube_views_delta = [youtube_views_delta(shift_back+1:end);...
    ones([shift_back, 1])];
youtube_views_delta2 = n_delta(C{101}, shift_forward);
has_youtube_delta = ~isnan(youtube_views_delta);

% iTunes album and track data
temp = C{103};
temp(isnan(temp)) = 0; % Set all NaN's to zero
%{
itunes_tracks_delta = n_delta(cumsum(temp), shift_back);
itunes_tracks_delta2 = n_delta(cumsum(temp), shift_forward);
itunes_tracks_delta = [itunes_tracks_delta(shift_back+1:end);...
    ones([shift_back, 1])];
%}
itunes_tracks_delta = shift(n_delta(cumsum(temp), shift_back), -shift_back+1);
itunes_tracks_delta2 = shift(n_delta(cumsum(temp), shift_forward), 1);

track_momentum = shift(n_delta(C{103}, shift_forward-1)...
    ./ (abs(n_sum(C{103}, shift_forward-1)) + 1), 1);
track_momentum(track_momentum < -1.1) = -1.1;
track_momentum(track_momentum > 1.1) = 1.1;

temp = C{102};
temp(isnan(temp)) = 0; % Set all NaN's to zero
itunes_albums_delta = n_delta(cumsum(temp), shift_back);
itunes_albums_delta2 = n_delta(cumsum(temp), shift_forward);
itunes_albums_delta = [itunes_albums_delta(shift_back+1:end);...
    ones([shift_back, 1])];
has_itunes_delta = (C{103} >= 0) & (shift(C{103},shift_forward) >= 0)...
    & (shift(C{103},-shift_back) >= 0);
has_albums_delta = ~isnan(C{102}) & ~isnan(shift(C{102},shift_forward))...
    & ~isnan(shift(C{102},-shift_back));

% fb_likes_delta contains total delta of fb likes over last week. It's sort
% of like a measure of recent artist momentum
fb_likes_delta = n_delta(C{6}, shift_forward);
has_fb_likes_delta = ~isnan(fb_likes_delta);

target_albums = find(album_releases & has_itunes_delta & viable_days...
    & has_fb_likes_t & has_twitter_followers_t);

% Make linear regression features
fb_likes_t = C{6}(target_albums);
tw_followers_t = C{74}(target_albums);
fb_likes_delta = fb_likes_delta(target_albums);
fb_likes_delta_sc = max(fb_likes_delta, 1) ./ fb_likes_t;
%youtube_views_delta = youtube_views_delta(target_albums);
delta_tracks = safelog(itunes_tracks_delta) - safelog(itunes_tracks_delta2);
% Simple linear regression on the log of the variables

X = [safelog(fb_likes_t), safelog(tw_followers_t), ones(length(target_albums), 1)];
y = delta_tracks(target_albums);
beta = X \ y;
xspace = [linspace(min(X(:,1)),max(X(:,1)),10)', ones([10 1])];
plot(X(:,1), y, 'o', xspace(:,1), xspace * beta, '-r')

error = X * beta - y;
error_stdev = sqrt(sum(error .^ 2) / length(y))
abs_error = sum(abs(error)) / length(y)