function result = safelog( v )
%SAFELOG takes the log of the input vector, but ensure that output will be
%>= 0 for every element
%   Detailed explanation goes here
    result = log10(max(v,1));

end

