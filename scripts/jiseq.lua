-- just intonation sequencer
-- in1 clock triggers
-- in2 0-5v controlling chord inversion
-- out1 sequence step quantized to ji scale
-- out2 out1 transposed a {fifth} up
-- out3 out2 transposed a {seventh} up
-- out4 sequence trigger
-- tunings ----------------------------------------------------------------
-- ptolemaic = {1/1, 16/15, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8} --12
-- overtone = {1/1, 17/16, 9/8, 19/16, 5/4, 21/16, 11/8, 3/2, 13/8, 27/16, 7/4, 15/8} --12
-- kgcentaurasubharmonic = {1/1, 15/14, 10/9, 40/33, 5/4, 4/3, 10/7, 3/2, 45/28, 5/3, 20/11, 15/8} --12
-- welltunedpiano = {1 / 1, 567 / 512, 9 / 8, 147 / 128, 21 / 16, 1323 / 1024, 189 / 128, 3 / 2, 49 / 32, 7 / 4, 441 / 256, 63 / 32} -- 12
-- island313edo = {1/1, 9/8, 15/13, 13/10, 4/3, 3/2, 17/11, 19/11, 16/9} --9 
-- superpyth17edo = {1/1, 24/23, 13/12, 20/17, 27/22, 4/3, 18/13, 13/9, 25/16, 31/19, 23/13, 24/13} --12
orwell22edo = {1 / 1, 33 / 31, 34 / 29, 81 / 65, 63 / 46, 289 / 198, 77 / 48, 299 / 175, 62 / 33} -- 9

-- chord progressions
s = sequins
prog6711 = s {{9, 'M'}, {11, 'M'}, {0, 'm'}, {0, 'm'}}
-- prog147 = s{{1, 'm'}, {5, 'm'}, {11, 'M'}}

-- setup ------------------------------------------------------------------
public {
    changeProbs = false
}
public {
    changeLengths = true
}
public {
    doRandomOctave = false
}
public {
    doRandomInversion = false
}
public {
    doSlew = false
}
public {
    octaveOffest = 0
}
public {
    octaveRange = 1
}
public {
    root = 3
}
-- 0   1    2   3    4   5   6    7   8    9   10   11
-- C - C# - D - D# - E - F - F# - G - G# - A - A# - B

tuning = orwell22edo
temperament = 9
lengthRange = 2 -- length range in clock divisions
lengthOffset = 0.3

-- chordProgression
progression = prog6711
stepPeriod = 16 -- periodicity of new steps in clock divisions

-- code -------------------------------------------------------------------
function counter(k, f)
    count = count + 1
    if count % (k - 1) == 0 then
        f()
        count = 0
    end
end

function randomOctave()
    return math.floor(math.random(-public.octaveRange, public.octaveRange)) + public.octaveOffest
end

function note()
    return {math.random(temperament),
            public.doRandomOctave and (randomOctave() + public.octaveOffest) or public.octaveOffest}
end

function chord(r)
    local step = r[1] / 12
    local octave = 0
    if public.doRandomOctave then
        octave = randomOctave()
    end
    return {
        root = step + octave,
        third = step + (r[2] == 'm' and 3 / 12 or 4 / 12) + octave,
        fifth = step + 7 / 12 + octave
    }
end

function doInversion(notes)
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

function newNotes()
    return s {note(), note(), note(), s {note(), note()}, note(), note(), s {note(), note(), note()}}
end

function newProbs()
    return s {math.random(), math.random(), math.random(), math.random(), math.random(), math.random(), math.random()}
end

function newLengths()
    return s {math.random() * lengthRange + lengthOffset, math.random() * lengthRange + lengthOffset,
              math.random() * lengthRange + lengthOffset, math.random() * lengthRange + lengthOffset,
              math.random() * lengthRange + lengthOffset}
end

input[2].window = function(v)
    inversion = v
    print("inversion:", inversion - 1)
end

-- sequencers -------------------------------------------------------------
function probabilitySteps()
    output[4].volts = 0
    counter(16, function()
        if public.changeProbs then
            probs = newProbs()
        end
        if public.changeLengths then
            lengths = newLengths()
        end
    end)
    local stepProb = probs()
    local stepRandom = math.random()
    if stepRandom < stepProb then
        local slew = 0
        local step = seq() -- index 1 has the note, index 2 has the octave
        local tunedStep = tuning[step[1]]
        if public.doSlew then
            if stepRandom < 0.5 then
                slew = stepRandom
            end
            for n = 1, 4 do
                output[n].slew = slew
            end
        end
        local notes = {
            root = tunedStep + step[2],
            fifth = tunedStep + 7 / 12 + step[2],
            seventh = tunedStep + 10 / 12 + step[2]
        }
        if public.doRandomInversion then
            inversion = math.random(3)
            notes = doInversion(notes)
        elseif inversion ~= 1 then
            notes = doInversion(notes)
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

function chordProgression()
    counter(stepPeriod, function()
        local notes = chord(progression())
        if public.doRandomInversion then
            inversion = math.random(3)
            notes = doInversion(notes)
        elseif inversion ~= 1 then
            notes = doInversion(notes)
        end
        output[1].volts = notes.root
        output[2].volts = notes.third
        output[3].volts = notes.fifth
        output[4].volts = 1
        delay(function()
            output[4].volts = 0
        end, lengths())
    end)
end

function init()
    math.randomseed(time() + time() / 13.667)
    count = 0
    probs = newProbs()
    lengths = newLengths()
    seq = newNotes()
    input[1].mode('change', 1, 0.1, 'rising')
    input[1].change = probabilitySteps
    input[2].mode('window', {1.25, 2.5, 3.75}, 0.01)
    for n = 1, 3 do
        output[n].scale(just12(tuning, 2 ^ (public.root / 12)), temperament)
        output[n].volts = 0
        output[n].slew = 0
    end
end
