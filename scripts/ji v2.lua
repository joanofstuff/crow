-- just intonation
-- in1 v/oct 12tet
-- in2 0-5v controlling chord inversion
-- out1-4 v/oct quantized to ji scale
-- tunings
-- ptolemaic = {1/1, 16/15, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8} -- 12
-- overtone = {1 / 1, 17 / 16, 9 / 8, 19 / 16, 5 / 4, 21 / 16, 11 / 8, 3 / 2, 13 / 8, 27 / 16, 7 / 4, 15 / 8} -- 12
-- kgcentaurasubharmonic = {1 / 1, 15 / 14, 10 / 9, 40 / 33, 5 / 4, 4 / 3, 10 / 7, 3 / 2, 45 / 28, 5 / 3, 20 / 11, 15 / 8} -- 12
welltunedpiano = {1 / 1, 567 / 512, 9 / 8, 147 / 128, 21 / 16, 1323 / 1024, 189 / 128, 3 / 2, 49 / 32, 7 / 4, 441 / 256, 63 / 32} -- 12

-- island313edo = {1/1, 9/8, 15/13, 13/10, 4/3, 3/2, 17/11, 19/11, 16/9} -- 9 
-- superpyth17edo = {1/1, 24/23, 13/12, 20/17, 27/22, 4/3, 18/13, 13/9, 25/16, 31/19, 23/13, 24/13} -- 12
-- orwell22edo = {1 / 1, 33 / 31, 34 / 29, 81 / 65, 63 / 46, 289 / 198, 77 / 48, 299 / 175, 62 / 33} -- 9

-- scales
major = {1, nil, 2, nil, 3, 4, nil, 5, nil, 6, nil, 7}
minor = {1, nil, 2, 3, nil, 4, nil, 5, 6, nil, 7, nil}

-- setup
scale = minor
tuning = welltunedpiano
temperament = 12
inversion = 1
public {
    baseOctave = 1
}
public {
    root = 11
}
-- 0   1    2   3    4   5   6    7   8    9   10   11
-- C - C# - D - D# - E - F - F# - G - G# - A - A# - B

-- code
function chord(volts, third, fifth, seventh)
    return {
        root = volts + public.baseOctave,
        third = volts + 1 / 12 * third + public.baseOctave,
        fifth = volts + 1 / 12 * fifth + public.baseOctave,
        seventh = volts + 1 / 12 * seventh + public.baseOctave
    }
end

function doInversion(notes)
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

function doScale(v)
    local notes
    local interval = math.floor((v % 1) * 12)
    local degree = scale[interval + 1]
    if scale == minor then
        if degree == nil then
            notes = chord(v, 5, 7, 10)
        elseif degree == 1 or degree == 4 or degree == 5 then
            notes = chord(v, 3, 7, 10)
        elseif degree == 2 then
            notes = chord(v, 3, 6, 10)
        else
            notes = chord(v, 4, 7, 10)
        end
    else
        if degree == nil then
            notes = chord(v, 5, 7, 11)
        elseif degree == 1 or degree == 4 or degree == 5 then
            notes = chord(v, 4, 7, 11)
        elseif degree == 7 then
            notes = chord(v, 3, 6, 11)
        else
            notes = chord(v, 3, 7, 11)
        end
    end
    return notes
end

input[1].stream = function(v)
    local notes = doScale(v)
    if inversion ~= 1 then
        notes = doInversion(notes)
    end
    output[1].volts = notes.root
    output[2].volts = notes.third
    output[3].volts = notes.fifth
    output[4].volts = notes.seventh
end

input[2].window = function(v)
    inversion = v
    print("inversion:", inversion - 1)
end

function init()
    input[1].mode('stream', 0.005)
    input[2].mode('window', {1.25, 2.5, 3.75}, 0.01)
    for n = 1, 4 do
        output[n].scale(just12(tuning, 2 ^ (public.root / 12)), temperament)
    end
    print("root:", public.root)
    print("base octave:", public.baseOctave)
    print("inversion:", inversion - 1)
end
