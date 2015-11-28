function [ result ] = sigma_bucket(x, div, cutoff)
%SIGMA_BUCKET Returns a logical vector corresponding the the bucket of x
%   Detailed explanation goes here

    % Divisions consist of within cutoff divisions and 
    num_divs = 2 * int32(cutoff / div) + 3;
    result = false([num_divs 1]);
    if (x < -cutoff)
        result(1) = true;
    elseif (x > cutoff)
        result(num_divs - 1) = true;
    elseif isnan(x)
        result(num_divs) = true;
    else
        result(int32(x / div) + int32(cutoff / div) + 1) = true;
    end
end

