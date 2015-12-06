function [ result ] = dlog( X )
%DLOG version of log10 that returns negative values for negative inputs
%   Detailed explanation goes here
    result = zeros(size(X));
    result(X >= 1) = log10(X(X >= 1));
    result(X <= -1) = -log10(-X(X <= -1));
    result(X > -1 & X < 1) = 0;
end

