nan_ratio = zeros(1, length(C));
for i=5:length(C)
    nan_ratio(i) = sum(isnan(C{i})) / length(C{i});
end

% Figuring out average path taken on album release
target_albums = find(album_releases & viable_days & has_albums_delta);
paths = zeros(14,length(target_albums));
for i=1:length(target_albums)
    vec = C{102}(target_albums(i)-6:target_albums(i)+7);
    paths(:,i) = vec / sum(vec);
end
plot(paths)
errorbar((-6:7)', nanmean(paths,2), nanstd(paths')');
hold on
plot([-6 7], [1/14 1/14], 'r')
hold off

temp = C{103};
temp(isnan(temp)) = 0; % Set all NaN's to zero
n_itunes_tracks_delta = shift(n_delta(cumsum(temp), shift_back), -shift_back+1);
n_itunes_tracks_delta2 = shift(n_delta(cumsum(temp), shift_forward), 1);

% Cross validation test - track_momentum alone
target_albums = album_releases & has_itunes_delta & viable_days...
    & (track_momentum > -1) & (track_momentum < 1);
X_master = [track_momentum(target_albums), ones(sum(target_albums),1)];
y_master = delta_tracks(target_albums);

total_variance = 0;
train_ratio = 0.7;
num_trials = 1000;
errors = zeros(num_trials,1);
for i=1:num_trials
    perm = randperm(length(y_master));
    train_indices = perm(1:int32(train_ratio * end));
    test_indices = perm(int32(train_ratio * end)+1:end);
    beta = X_master(train_indices,:) \ y_master(train_indices);
    error = X_master(test_indices,:) * beta - y_master(test_indices);
    error_stdev = sqrt(sum(error .^ 2) / length(test_indices));
    total_variance = total_variance + error_stdev^2;
    errors(i) = error_stdev;
end
average_error = sqrt(total_variance / num_trials)

% Cross validation tests - track_momentum + fb + tw
target_albums = album_releases & has_itunes_delta & viable_days...
    & (track_momentum > -1) & (track_momentum < 1) & has_fb_likes_t...
    & has_twitter_followers_t;
X_master = [track_momentum(target_albums) ones(sum(target_albums),1)];
y_master = delta_tracks(target_albums);

total_variance = 0;
train_ratio = 0.7;
num_trials = 1000;
errors = zeros(num_trials,1);
for i=1:num_trials
    perm = randperm(length(y_master));
    train_indices = perm(1:int32(train_ratio * end));
    test_indices = perm(int32(train_ratio * end)+1:end);
    beta = X_master(train_indices,:) \ y_master(train_indices);
    error = X_master(test_indices,:) * beta - y_master(test_indices);
    error_stdev = sqrt(sum(error .^ 2) / length(test_indices));
    total_variance = total_variance + error_stdev^2;
    errors(i) = error_stdev;
end
average_error = sqrt(total_variance / num_trials)
average_error^2