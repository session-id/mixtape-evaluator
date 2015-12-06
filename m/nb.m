% Only requirements are that deltas remain within current artist and itunes
% data is available.
target_albums = find(album_releases & has_itunes_delta & viable_days & track_momentum > -1 & track_momentum < 1);

%field_ids = 74;
field_ids = [6 19 74 80]; % FB, Last, Tw, Tw
%field_ids = 19
%field_ids = [6 9 11 15 19 21 23 26 28 30 32 34 36 38 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 91 93 95 97 99 101];
fields = cell2mat(C(:, field_ids));
log_fields = [%safelog(fields(target_albums, :)),...
    track_momentum(target_albums),...
    delta_tracks(target_albums)];
means = nanmedian(log_fields);
stdevs = nanstd(log_fields);
norm_fields = (log_fields - repmat(means, [length(log_fields) 1]))...
    ./ repmat(stdevs, [length(log_fields) 1]);
data = norm_fields;

disp('Data loaded.')

% Bucket by number of half sigmas from mean
% (-inf, -2), (-2, -1.5), (-1.5, -1), (-1, -0.5), (-0.5, 0), ...
% 11 buckets total for each number, including NaN bucket
num_buckets = 10;
features = zeros(size(data,1), num_buckets * size(data,2));

for i=1:size(data,1)
    for j=1:size(data,2)
        features(i, num_buckets*(j-1)+1:num_buckets*j) = sigma_bucket2(data(i,j),0.5,1.75)';
    end
end

% Hand coded Naive Bayes to work with the prescribed labels
t = cputime;

X_master = features(:,1:end-num_buckets);
y_master = features(:,end-num_buckets+1:end);
num_features = size(X,2); % Number of non-y features
predicted_mapping = [(-2:0.5:2), 0];

training_ratio = 0.9;
num_trials = 1000;
total_variance = 0;
dumb_variance = 0;

for n=1:num_trials
    perm = randperm(size(X_master,1));
    % Build training set
    X = X_master(perm(1:int32(end*training_ratio)),:);
    y = y_master(perm(1:int32(end*training_ratio)),:);

    phi_k_given_y = ones(size(y,2), size(X,2));
    phi_y = ones(size(y,2), 1);

    for i=1:size(X,1)
        index = find(y(i,:));
        phi_y(index) = phi_y(index) + 1;
        % Increase frequency of each (class, feature) event
        phi_k_given_y(index,:) = phi_k_given_y(index,:) + X(i,:);
    end

    % Perform normalization
    normalization_method = 1;

    if (normalization_method == 1)
        for i=1:num_buckets:size(phi_k_given_y,2)
            norm_factor = sum(phi_k_given_y(:,i:i+num_buckets-1),2);
            phi_k_given_y(:,i:i+num_buckets-1) = phi_k_given_y(:,i:i+num_buckets-1)...
                ./ repmat(norm_factor, [1 num_buckets]);
        end
    else
        % Alternate normalization (not exactly NB)
        phi_k_given_y = phi_k_given_y ./ repmat(sum(phi_k_given_y,1), ...
        [size(phi_k_given_y,1) 1]);
    end

    phi_y = phi_y / sum(phi_y);

    % Take log of data
    log_phi_k_given_y = log(phi_k_given_y);
    log_phi_y = log(phi_y);

    % Make test set
    X = X_master(perm(int32(end*training_ratio)+1:end),:);
    y = y_master(perm(int32(end*training_ratio)+1:end),:);
    y_real = data(perm(int32(end*training_ratio)+1:end),end);

    num_correct = 0;
    predictions = zeros(size(X,1),1);
    actual = zeros(size(X,1),1);
    for i=1:size(X,1)
        probabilities = log_phi_k_given_y * X(i,:)';
        if normalization_method == 1
            probabilities = probabilities + log_phi_y;
        end
        prediction = find(probabilities == max(probabilities));
        predictions(i) = prediction;
        if (y(i,prediction) == 1)
            num_correct = num_correct + 1;
        end
        actual(i) = find(y(i,:));
        total_error = total_error + abs(prediction - find(y(i,:)));
    end
    
    total_variance = total_variance + sum((predicted_mapping(predictions)' - y_real).^2) / size(X,1);
    
    %{
    accuracy = num_correct / size(X,1);
    avg_abs_error = sum(abs(actual - predictions)) / size(X,1);
    stdev_error = sqrt(sum((actual - predictions).^2) / size(X,1) + 1/12);
    total_variance = total_variance + stdev_error^2;
    dumb_variance = dumb_variance + sum((actual - 5) .^ 2) / size(X,1) + 1/12;
    %}
end

average_variance = total_variance / num_trials
average_stdev = sqrt(average_variance) * stdevs(end)
variance_explained = 1 - average_variance

e = cputime - t