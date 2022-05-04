-- just intonation sequencer
-- in1 clock triggers
-- in2 0-5v controlling chord inversion
-- out1 sequence step quantized to ji scale
-- out2 out1 transposed a fifth up
-- out3 out1 transposed a seventh up
-- out4 gate trigger
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

-- setup
root = 'D#'
tuning = 'orwell22edo'
length_offset = 0.3
length_range = 2 -- length range in clock divisions
public {
    sequence_length = 16
}
public {
    change_probs = false
}
public {
    change_lengths = true
}
public {
    do_slew = false
}
public {
    do_random_inversion = false
}
public {
    do_random_octave = false
}
public {
    octave_offset = 1
}
public {
    octave_range = 1
}

-- code
function counter(k, f)
    count = count + 1
    if count % (k - 1) == 0 then
        f()
        count = 0
    end
end

function apply_inversion(notes)
    if public.do_random_inversion then
        inversion = math.random(3)
    end
    if inversion == 2 then
        notes = {
            root = notes.fifth,
            third = notes.seventh,
            fifth = notes.root + 1
        }
    else
        notes = {
            root = notes.seventh,
            third = notes.root + 1,
            fifth = notes.fifth + 1
        }
    end
    return notes
end

function randomize_octave()
    return math.floor(math.random(-public.octave_range, public.octave_range)) + public.octave_offset
end

function note()
    return {math.random(#tuning),
            public.do_random_octave and (randomize_octave() + public.octave_offset) or public.octave_offset}
end

-- TODO dynamically generate random sequences with length equal to public.sequence_length
function new_notes()
    return s {note(), note(), note(), s {note(), note()}, note(), note(), s {note(), note(), note()}}
end

function new_probs()
    return s {math.random(), math.random(), math.random(), math.random(), math.random(), math.random(), math.random()}
end

function new_lengths()
    return s {math.random() * length_range + length_offset, math.random() * length_range + length_offset,
              math.random() * length_range + length_offset, math.random() * length_range + length_offset,
              math.random() * length_range + length_offset}
end

input[1].change = function()
    output[4].volts = 0
    counter(public.sequence_length, function()
        if public.change_probs then
            probs = new_probs()
        end
        if public.change_lengths then
            lengths = new_lengths()
        end
    end)
    local stepRandom = math.random()
    if stepRandom < probs() then
        local slew = 0
        output[4].volts = 0

        local step = seq() -- index 1 has the note, index 2 has the octave
        local tuned_step = tuning[step[1]]

        if public.do_slew then
            if stepRandom < 0.5 then
                slew = stepRandom
            end
            for n = 1, 4 do
                output[n].slew = slew
            end
        end
        local notes = {
            root = tuned_step + step[2],
            fifth = tuned_step + 7 / 12 + step[2],
            seventh = tuned_step + 10 / 12 + step[2]
        }
        if inversion ~= 1 then
            notes = apply_inversion(notes)
        end
        output[1].volts = notes.root
        output[2].volts = notes.fifth
        output[3].volts = notes.seventh
        output[4].volts = 1
        delay(function()
            output[4].volts = 0
        end, lengths())
    end
end

input[2].window = function(v)
    inversion = v
    print("inversion:", inversion - 1)
end

function init()
    root = root_notes[root]
    tuning = available_tunings[tuning]

    math.randomseed(time() + time() / 13.667)
    count = 0
    probs = new_probs()
    lengths = new_lengths()
    seq = new_notes()

    input[1].mode('change', 1, 0.1, 'rising')
    input[2].mode('window', {1.25, 2.5, 3.75}, 0.01)
    for n = 1, 3 do
        output[n].scale(just12(tuning, 2 ^ (root / 12)), #tuning)
        output[n].volts = 0
        output[n].slew = 0
    end
end
