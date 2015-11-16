% Reads the data from the challenge directly into matlab

load_data = false; % Set to true to load data
if (load_data)
    fileId = fopen('challenge_data.csv');
    header = fgetl(fileId);
    C = textscan(fileId, '%s %n %n %s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n', 'Delimiter', ',', 'TreatAsEmpty', {'NA', 'na'});
    fclose(fileId);
end

% Recover days that have relevant fields of information
album_releases = ~isnan(C{104}); % IsReleaseDay
has_fb_likes_t = ~isnan(C{6}); % Facebook_PageLikes_t
has_youtube_views_t = ~isnan(C{101}); % YouTube_Video_Views_t

% Find times when there is data for artist reaching both backwards and
% forwards
look_back = 14; % Number of days to shift all data backwards by
look_forward = 14; % Number of days to shift all data forwards by
back_buffer = -ones([look_back, 1]);
forward_buffer = -ones([look_forward, 1]);
artist_shift_f = [forward_buffer; C{2}(1:end-look_forward)];
artist_shift_b = [C{2}(look_back+1:end); back_buffer];
viable_days = (artist_shift_f == artist_shift_b) & (artist_shift_f == C{2});
clear artist_shift_f
clear artist_shift_b

% Shift youtube views forward to get change in view counts
youtube_shift_b = [C{101}(look_back+1:end); back_buffer];
viable_days = viable_days & ~isnan(youtube_shift_b);

target_albums = find(album_releases & has_fb_likes_t & has_youtube_views_t...
    & viable_days);

% Make linear regression features
fb_likes_t = C{6}(target_albums);
youtube_views_delta = youtube_shift_b(target_albums) - C{101}(target_albums);

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