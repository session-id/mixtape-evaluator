% Reads the data from the challenge directly into matlab

load_data = false; % Set to true to load data
if (load_data)
    fileId = fopen('challenge_data.csv');
    header = fgetl(fileId);
    C = textscan(fileId, '%s %n %n %s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n', 'Delimiter', ',', 'TreatAsEmpty', {'NA', 'na'});
    fclose(fileId);
end

% Find times when there is data for artist reaching both backwards and
% forwards
shift_back = 28; % Number of days to shift all data backwards by
shift_forward = 0; % Number of days to shift all data forwards by
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
has_insta_followers_t = ~isnan(C{11}); % Instagram_Followers_t

% youtube_views_delta contains total number of views (from
% Youtube_Video_Views_t) over the next [shift_back] days from any day
youtube_views_delta = n_delta(C{101}, shift_back);
youtube_views_delta = [youtube_views_delta(shift_back+1:end);...
    ones([shift_forward, 1])];
has_youtube_delta = ~isnan(youtube_views_delta);

target_albums = find(album_releases & has_fb_likes_t & has_youtube_delta...
    & viable_days);

% Make linear regression features
fb_likes_t = C{6}(target_albums);
youtube_views_delta = youtube_views_delta(target_albums);

% Simple linear regression on the log of the variables
X = [log10(fb_likes_t), ones(size(fb_likes_t))];
y = log10(youtube_views_delta);
beta = X \ y;
plot(X(:,1), y, 'o')
hold on
xspace = [linspace(0,8,10)', ones([10 1])];
plot(xspace(:,1), xspace * beta)
hold off

error = X * beta - y;
error_stdev = sqrt(sum(error .^ 2) / length(y))
abs_error = sum(abs(error)) / length(y)

C_sum = zeros(size(C));
for i=1:length(C)
    if i ~= 1 && i ~= 4
        C_sum(i) = sum(~isnan(C{i}));
    end
end