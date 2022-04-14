-- microtonal
-- in1 v/oct 12tet
-- in2 0-5v controlling microtonality
-- out1-4 v/oct
public {
    temperament = 12
}
public {
    voltage_range = {0, 5} -- replace window thresholds dynamically for thinner intervals than quarter tones
}
REGULAR = 0
HALF_FLAT = -1 / (public.temperament * 2)
HALF_SHARP = 1 / (public.temperament * 2)

steps = {HALF_FLAT, REGULAR, HALF_SHARP}
micro_step = steps[1]

function chord(volts, fourth, fifth, rand)
    return {
        root = volts + micro_step,
        fourth = volts + 1 / public.temperament * fourth + micro_step,
        fifth = volts + 1 / public.temperament * fifth + micro_step,
        rand = volts + 1 / public.temperament * rand + micro_step
    }
end

input[1].stream = function(v)
    local notes = chord(v, 5, 7, math.random(public.temperament))
    output[1].volts = notes.root
    output[2].volts = notes.fourth
    output[3].volts = notes.fifth
    output[4].volts = notes.rand
end

input[2].window = function(v)
    micro_step = steps[v]
    print("micro_step:", micro_step)
end

function init()
    input[1].mode('stream', 0.005)
    input[2].mode('window', {1.67, 3.33}, 0.01)
    for n = 1, 4 do
        output[n].slew = 0
        output[n].scale('none')
    end
end
