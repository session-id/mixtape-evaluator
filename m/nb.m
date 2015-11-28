% Only requirements are that deltas remain within current artist and itunes
% data is available.
target_albums = find(album_releases & has_itunes_delta & viable_days);

% Norm fields loader taken from pca
pca_field_ids = [6 74 80];
pca_fields = [cell2mat(C(:, pca_field_ids)), itunes_tracks_delta];
log_pca_fields = safelog(pca_fields);
means = nanmean(log_pca_fields);
stdevs = nanstd(log_pca_fields);
norm_fields = (log_pca_fields - repmat(means, [length(pca_fields) 1]))...
    ./ repmat(stdevs, [length(pca_fields) 1]);
norm_fields = norm_fields(target_albums,:); % Restrict to target albums
data = norm_fields;

% Bucket by number of half sigmas from mean
% (-inf, -2), (-2, -1.5), (-1.5, -1), (-1, -0.5), (-0.5, 0), ...
% 11 buckets total for each number, including NaN bucket
num_buckets = 11;
features = zeros(size(data,1), num_buckets * size(data,2));

for i=1:size(data,1)
    for j=1:size(data,2)
        features(i, num_buckets*(j-1)+1:num_buckets*j) = sigma_bucket(data(i,j),0.5,2)';
    end
end

% Hand coded Naive Bayes to work with the prescribed labels

X = features(:,1:end-11);
y = features(:,end-10:end);

phi_k_given_y = ones([2, numTokens]);
phi_y = 0; % Probability of sample being spam

for i = 1:numTrainDocs
    y = full(trainCategory(i)); % Class
    x = trainMatrix(i,:); % Token frequency vector
    
    % Increase frequency of each (class, token) event
    phi_k_given_y(y + 1,:) = phi_k_given_y(y + 1,:) + x;
    % Increase frequency of (class) event
    phi_y = phi_y + y;
end

% Perform normalization
phi_y = phi_y / numTrainDocs;
phi_k_given_y = phi_k_given_y ./ repmat(sum(phi_k_given_y, 2), ...
    [1 size(phi_k_given_y, 2)]);

% Take log of data
log_phi_k_given_y = log(phi_k_given_y);
log_phi_y = log(phi_y);