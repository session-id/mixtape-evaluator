function [ v ] = shift( v, shift_forward )
%SHIFT Summary of this function goes here
%   Detailed explanation goes here
    if shift_forward < 0
        shift_back = -shift_forward;
        v = [v(shift_back+1:end); NaN*ones([shift_back, 1])];
    elseif shift_forward > 0
        v = [NaN*ones([shift_forward,1]); v(1:end-shift_forward)];
    end
end