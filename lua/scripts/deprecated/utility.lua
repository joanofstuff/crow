-- utility functions
-- in1 0-10v v/oct
-- out1 in1 scaled to pleasant -5-5v filter freq mod
input[1].stream = function(v)
    output[1].volts = v / 3 + 0.5
end

function init()
    input[1].mode('stream', 0.005)
    for n = 1, 4 do
        output[n].scale = 'none'
        output[n].volts = 0
        output[n].slew = 0
    end
end
