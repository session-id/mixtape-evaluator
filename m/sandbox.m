nan_ratio = zeros(1, length(C));
for i=5:length(C)
    nan_ratio(i) = sum(isnan(C{i})) / length(C{i});
end

paths = zeros(14,length(target_albums));
for i=1:length(target_albums)
    vec = C{103}(target_albums(i)-6:target_albums(i)+7);
    paths(:,i) = vec / sum(vec);
end
plot(paths)

temp = C{103};
temp(isnan(temp)) = 0; % Set all NaN's to zero
n_itunes_tracks_delta = shift(n_delta(cumsum(temp), shift_back), -shift_back+1);
n_itunes_tracks_delta2 = shift(n_delta(cumsum(temp), shift_forward), 1);