-- just intonation chord progression sequencer
-- in1 new step trigger
-- out1-4 v/oct quantized to ji scale
s = sequins
available_tunings = {
    ptolemaic = {1 / 1, 16 / 15, 9 / 8, 6 / 5, 5 / 4, 4 / 3, 45 / 32, 3 / 2, 8 / 5, 5 / 3, 9 / 5, 15 / 8},
    overtone = {1 / 1, 17 / 16, 9 / 8, 19 / 16, 5 / 4, 21 / 16, 11 / 8, 3 / 2, 13 / 8, 27 / 16, 7 / 4, 15 / 8},
    kgcentaurasubharmonic = {1 / 1, 15 / 14, 10 / 9, 40 / 33, 5 / 4, 4 / 3, 10 / 7, 3 / 2, 45 / 28, 5 / 3, 20 / 11,
                             15 / 8},
    welltunedpiano = {1 / 1, 567 / 512, 9 / 8, 147 / 128, 21 / 16, 1323 / 1024, 189 / 128, 3 / 2, 49 / 32, 7 / 4,
                      441 / 256, 63 / 32},
    island313edo = {1 / 1, 9 / 8, 15 / 13, 13 / 10, 4 / 3, 3 / 2, 17 / 11, 19 / 11, 16 / 9},
    superpyth17edo = {1 / 1, 24 / 23, 13 / 12, 20 / 17, 27 / 22, 4 / 3, 18 / 13, 13 / 9, 25 / 16, 31 / 19, 23 / 13,
                      24 / 13},
    orwell22edo = {1 / 1, 33 / 31, 34 / 29, 81 / 65, 63 / 46, 289 / 198, 77 / 48, 299 / 175, 62 / 33}
}

root_notes = {
    ["C"] = 0,
    ["C#"] = 1,
    ["Db"] = 1,
    ["D"] = 2,
    ["D#"] = 3,
    ["Eb"] = 3,
    ["E"] = 4,
    ["F"] = 5,
    ["F#"] = 6,
    ["Gb"] = 6,
    ["G"] = 7,
    ["G#"] = 8,
    ["Ab"] = 8,
    ["A"] = 9,
    ["A#"] = 10,
    ["Bb"] = 10,
    ["B"] = 11
}

progressions = {
    ['6711'] = s {9, 11, 0, 0},
    ['147'] = s {1, 5, 11}
}

scales = {
    ['major'] = {{4, 7, 11}, {5, 7, 11}, {3, 7, 11}, {5, 7, 11}, {3, 7, 11}, {4, 7, 11}, {5, 7, 11}, {4, 7, 11},
                 {5, 7, 11}, {3, 7, 11}, {5, 7, 11}, {3, 6, 11}},
    ['minor'] = {{3, 7, 10}, {5, 7, 10}, {3, 6, 10}, {4, 7, 10}, {5, 7, 10}, {3, 7, 10}, {5, 7, 10}, {3, 7, 10},
                 {4, 7, 10}, {5, 7, 10}, {4, 7, 10}, {5, 7, 10}}
}

-- setup
root = 'D#'
tuning = 'welltunedpiano'
progression = '147'
scale = 'minor'
octave_offset = 1
public {
    do_random_inversion = false
}

-- code
function make_chord(volts, third, fifth, seventh)
    return {
        root = volts + octave_offset,
        third = volts + 1 / 12 * third + octave_offset,
        fifth = volts + 1 / 12 * fifth + octave_offset,
        seventh = volts + 1 / 12 * seventh + octave_offset
    }
end

function apply_inversion(notes)
    if not public.do_random_inversion then
        return notes
    end
    inversion = math.random(3)
    if inversion == 2 then
        notes = {
            root = notes.third,
            third = notes.fifth,
            fifth = notes.seventh,
            seventh = notes.root + 1
        }
    elseif inversion == 3 then
        notes = {
            root = notes.fifth,
            third = notes.seventh,
            fifth = notes.root + 1,
            seventh = notes.third + 1
        }
    else
        notes = {
            root = notes.seventh,
            third = notes.root + 1,
            fifth = notes.third + 1,
            seventh = notes.fifth + 1
        }
    end
    return notes
end

function apply_scale(v)
    local interval = math.floor((v % 1) * #tuning)
    local degree = scale[interval + 1]
    local notes = make_chord(v, degree[1], degree[2], degree[3])
    return notes
end

input[1].change = function()
    local notes = apply_scale(tuning[progression() % #tuning + 1])

    output[1].volts = notes.root
    output[2].volts = notes.third
    output[3].volts = notes.fifth
    output[4].volts = notes.seventh
end

function init()
    print("root:       ", root)
    print("scale:      ", scale)
    print("octave offset:", octave_offset)
    print("progression:", progression)

    root = root_notes[root]
    tuning = available_tunings[tuning]
    progression = progressions[progression]
    scale = scales[scale]

    input[1].mode('change', 1, 0.1, 'rising')
    for n = 1, 3 do
        output[n].scale(just12(tuning, 2 ^ (root / 12)), #tuning)
        output[n].volts = 0
        output[n].slew = 0
    end
end
