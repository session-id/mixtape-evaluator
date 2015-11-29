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

X_master = features(:,1:end-11);
y_master = features(:,end-10:end);
num_features = size(X,2); % Number of non-y features

% Build training set
X = X_master(1:int32(end*2/3),:);
y = y_master(1:int32(end*2/3),:);

phi_k_given_y = ones(size(y,2), size(X,2));
phi_y = ones(size(y,2), 1);

for i=1:size(X,1)
    index = find(y(i,:));
    phi_y(index) = phi_y(index) + 1;
    % Increase frequency of each (class, feature) event
    phi_k_given_y(index,:) = phi_k_given_y(index,:) + X(i,:);
end

% Perform normalization
for i=1:num_buckets:size(phi_k_given_y,2)
    norm_factor = sum(phi_k_given_y(:,i+num_buckets-1),2);
    phi_k_given_y(:,i:i+num_buckets-1) = phi_k_given_y(:,i:i+num_buckets-1)...
        ./ repmat(norm_factor, [1 num_buckets]);
end

phi_y = phi_y / sum(phi_y);

% Take log of data
log_phi_k_given_y = log(phi_k_given_y);
log_phi_y = log(phi_y);

% Make test set
X = X_master(int32(end*2/3)+1:end,:);
y = y_master(int32(end*2/3)+1:end,:);

num_correct = 0;
total_error = 0;
for i=1:size(X,1)
    probabilities = log_phi_k_given_y * X(i,:)' + log_phi_y;
    prediction = find(probabilities == max(probabilities));
    if (y(i,prediction) == 1)
        num_correct = num_correct + 1;
    end
    total_error = total_error + abs(prediction - find(y(i,:)));
end

accuracy = num_correct / size(X,1)
avg_error = total_error / size(X,1)