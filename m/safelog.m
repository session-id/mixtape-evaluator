function result = safelog( v )
%SAFELOG safe version of log10
%   Ensures that output is never imaginary\
    result = log10(max(v,1));
    result(isnan(v)) = NaN;
end

