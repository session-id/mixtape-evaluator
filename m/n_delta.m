% Find differences between elements of v separated by shift
% result(n) = v(n) - v(n - look_back)
function result = n_delta(v, look_back)
    f_buffer = NaN * ones([look_back, 1]);
    shift_f = [f_buffer; v(1:end - look_back)];
    result = v - shift_f;