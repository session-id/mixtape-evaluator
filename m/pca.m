% Facebook_likes, Tw_followers, Tw_likes
pca_field_ids = [6 74 80];
pca_fields = cell2mat(C(:, pca_field_ids));
log_pca_fields = log10(pca_fields + 1); % Prevent the existence of zeros

% Normalize fields to mean 0 and stdev 1
means = nanmean(log_pca_fields);
stdevs = nanstd(log_pca_fields);

norm_fields = (log_pca_fields - repmat(means, [length(pca_fields) 1]))...
    ./ repmat(stdevs, [length(pca_fields) 1]);

% Multiple imputation for missing values from N(0,1)
indices = find(isnan(norm_fields));
average_sigma = zeros(size(pca_fields, 2));
for i = 1:5
    norm_fields(indices) = randn([length(indices) 1]);
    sigma = cov(norm_fields);
    average_sigma = average_sigma + sigma;
end
average_sigma = average_sigma / 5;

norm_deltas = zeros(size(norm_fields));
for i=1:size(norm_deltas,2)
    norm_deltas(:,i) = n_delta(norm_fields(:,i), shift_forward);
end