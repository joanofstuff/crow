-- dual just intonation
-- in1/2 v/oct 12tet
-- out1-2/3-4 in1/2 v/oct respectivelly quantized to ji scale 
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

-- setup
in1_root = 'F#'
in1_tuning = "welltunedpiano"
in1_base_octave = 1

in2_root = 'F#'
in2_tuning = "welltunedpiano"
in2_base_octave = 1

-- code

input[1].stream = function(v)
    output[1].volts = v + in1_base_octave
    output[2].volts = v + 7 / 12 + in1_base_octave
end

input[2].stream = function(v)
    output[3].volts = v + in2_base_octave
    output[4].volts = v + 7 / 12 + in2_base_octave
end

function init()
    print("in1 root:       ", in1_root)
    print("in1 base octave:", in1_base_octave)
    print("in2 root:       ", in2_root)
    print("in2 base octave:", in2_base_octave)

    in1_root = root_notes[in1_root]
    in1_tuning = available_tunings[in1_tuning]
    in2_root = root_notes[in2_root]
    in2_tuning = available_tunings[in2_tuning]

    input[1].mode('stream', 0.005)
    input[2].mode('stream', 0.005)
    output[1].scale(just12(in1_tuning, 2 ^ (in1_root / 12)), #in1_tuning)
    output[2].scale(just12(in1_tuning, 2 ^ (in1_root / 12)), #in1_tuning)
    output[3].scale(just12(in2_tuning, 2 ^ (in2_root / 12)), #in2_tuning)
    output[4].scale(just12(in2_tuning, 2 ^ (in2_root / 12)), #in2_tuning)
end
