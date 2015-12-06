function [ result ] = sigma_bucket2(x, div, cutoff)
%SIGMA_BUCKET2 Returns a logical vector corresponding the the bucket of x
%   This version centers one bucket at 0

    % Divisions consist of within cutoff divisions and 
    num_divs = int32(2 * cutoff / div) + 3;
    result = false([num_divs 1]);
    if (x < -cutoff)
        result(1) = true;
    elseif (x > cutoff)
        result(num_divs - 1) = true;
    elseif isnan(x)
        result(num_divs) = true;
    else
        result(floor((x + cutoff) / div) + 2) = true;
    end
end

