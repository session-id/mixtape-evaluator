% Only requirements are that deltas remain within current artist and itunes
% data is available.
target_albums = find(album_releases & has_itunes_delta & viable_days);

% Norm fields loader taken from pca
pca_field_ids = [6 74 80];
pca_fields = cell2mat(C(:, pca_field_ids));
log_pca_fields = log10(pca_fields + 1);
means = nanmean(log_pca_fields);
stdevs = nanstd(log_pca_fields);
norm_fields = (log_pca_fields - repmat(means, [length(pca_fields) 1]))...
    ./ repmat(stdevs, [length(pca_fields) 1]);
norm_fields = norm_fields(target_albums,:); % Restrict to target albums
data = [norm_fields, itunes_tracks_delta(target_albums,:)];

% Bucket by number of half sigmas from mean
% (-inf, -2), (-2, -1.5), (-1.5, -1), (-1, -0.5), (-0.5, 0), ...
% 11 buckets total for each number, including NaN bucket
features = zeros(size(data,1), 11 * size(data,2));

