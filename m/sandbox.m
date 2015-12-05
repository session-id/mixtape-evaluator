nan_ratio = zeros(1, length(C));
for i=5:length(C)
    nan_ratio(i) = sum(isnan(C{i})) / length(C{i});
end