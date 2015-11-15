% Reads the data from the challenge directly into matlab

fileId = fopen('challenge_data.csv');
header = fgetl(fileId);
C = textscan(fileId, '%s %n %n %s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n', 'Delimiter', ',', 'TreatAsEmpty', {'NA', 'na'});
fclose(fileId);

album_releases = ~isnan(C{104}); % IsReleaseDay
fb_talking = ~isnan(C{7}); % Facebook_TalkingAboutThis_7day__d
youtube_views = ~isnan(C{101}); % YouTube_Video_Views_t

% Find times when there is data for artist reaching both backwards and
% forwards
look_back = 14;
look_forward = 14;
back_buffer = -ones([look_back, 1]);
forward_buffer = -ones([look_forward, 1]);
artist_shift_forward = [back_buffer; C{2}(1:end-look_back)];
artist_shift_backward = [C{2}(look_forward+1:end); forward_buffer];
viable_days = (artist_shift_forward == artist_shift_backward) & (artist_shift_forward == C{2});

target_albums = find(album_releases & fb_talking & youtube_views & viable_days);