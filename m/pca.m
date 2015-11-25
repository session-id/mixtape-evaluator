% Facebook_likes, Insta_commments, Insta_followers, Insta_likes,
% Tw_followers, Tw_likes
pca_field_ids = [4 7 9 13 72 78];
pca_fields = data(:, pca_field_ids);
log_pca_fields = log10(pca_fields + 1); % Prevent the existence of zeros

average_sigma = zeros(length(pca_fields));

% Normalize fields to mean 0 and stdev 1
means = nanmean(log_pca_fields);
stdevs = nanstd(log_pca_fields);

norm_fields = (log_pca_fields - repmat(means, [length(pca_fields) 1]))...
    ./ repmat(stdevs, [length(pca_fields) 1]);

% Multiple imputation for missing values from N(0,1)
indices = find(isnan(norm_fields));
for i = 1:5
    norm_fields(indices) = randn([length(indices) 1]);
    sigma = cov(norm_fields);
end