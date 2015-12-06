function plot_average_with_error( X )
%PLOT_AVERAGE_WITH_ERROR plots the average value at each step with error
%   Detailed explanation goes here
    errorbar(nanmean(X,2), nanstd(X')');

end

