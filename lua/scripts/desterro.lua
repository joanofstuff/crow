-- desterro
local s = sequins
local tl = timeline

public {pattern = 1}
public {pattern_length = 9}:range(3, 64)
public {step_interval = 1 / 16}:range(1 / 32, 4 / 1)
public {octave_range = {0, 2}}:range(-2, 5)
public {length_range = {0.5, 1}}:range(0, 5)
public {variation_probability = 0.45}:range(0, 1)
public {probability_range = {0.15, 0.65}}:range(0, 1)

local _count = 0
local _notes = {
  -- ["E"] = 1,
  -- ["F"] = 2,
  -- ["F#"] = 3,
  -- ["A"] = 4,
  -- ["A#"] = 5,
  -- ["C#"] = 6,
  -- ["D#"] = 7,
  -- [1] = "E",
  -- [2] = "F",
  -- [3] = "F#",
  -- [4] = "A",
  -- [5] = "A#",
  -- [6] = "C#",
  -- [7] = "D#",
  ["C"] = 1,
  ["C#"] = 2,
  ["D"] = 3,
  ["D#"] = 4,
  ["E"] = 5,
  ["F"] = 6,
  ["F#"] = 7,
  ["G"] = 8,
  ["G#"] = 9,
  ["A"] = 10,
  ["A#"] = 11,
  ["B"] = 12,
  [1] = "C",
  [2] = "C#",
  [3] = "D",
  [4] = "D#",
  [5] = "E",
  [6] = "F",
  [7] = "F#",
  [8] = "G",
  [9] = "G#",
  [10] = "A",
  [11] = "A#",
  [12] = "B",
}
local _default_note = 1
local _default_octave = 1
local _default_length = 1
local _default_probability = 0.67

local function print_step(step)
  return string.format("%s,%s,%s,%s",
                       _notes[math.floor(step.note * #_notes)] or _default_note,
                       step.octave or _default_octave,
                       step.length or _default_length,
                       step.probability or _default_probability)
end

local function new_step(step)
  return {
    note = step and (step.note or _default_note) or
      (math.random(#_notes - 1) + 1) / #_notes,
    octave = step and (step.octave or _default_octave) or
      math.random(public.octave_range[1], public.octave_range[2]),
    length = step and (step.length or _default_length) or
      math.random(public.length_range[1] * 100, public.length_range[2] * 100) /
      100,
    probability = step and (step.probability or _default_probability) or
      math.random(public.probability_range[1] * 100,
                  public.probability_range[2] * 100) / 100,
  }
end

local function new_pattern(length)
  local pattern = {}

  for i = 1, length, 1 do
    if math.random() < public.variation_probability then
      local step1, step2 = new_step(), new_step()
      pattern[i] = s {step1, step2}
      print(print_step(step1), print_step(step2))
    else
      local step1 = new_step()
      pattern[i] = s {step1}
      print(print_step(step1))
    end
  end

  return {step_interval = public.step_interval, pattern = s(pattern)}
end

local function parse_pattern(pattern)
  local seq = {}

  for _, line in ipairs(pattern) do
    local step = {}

    for note in line:gmatch("%S+") do
      local iter = note:gmatch("[^,]+")
      local chroma = iter()
      local octave = iter()
      local length = iter()
      local probability = iter()
      table.insert(step, new_step({
        note = _notes[chroma] / #_notes,
        octave = octave,
        length = length,
        probability = tonumber(probability),
      }))
    end

    table.insert(seq, s(step))
  end

  return s(seq)
end

local function sequencer(step)
  _count = _count + 1
  if _count % (public.pattern_length - 1) == 0 then _count = 0 end

  local roll = math.random()

  -- print(roll, step.probability)
  -- print(step.note, step.octave, step.length, step.probability)
  if roll < step.probability then
    -- print(step.note, step.octave, step.length, step.probability)
    output[3].volts = step.length
    output[4].volts = step.note + step.octave
    output[2]()
  end
end

function init()
  print("initialising")

  local seqs = {
    [1] = {
      step_interval = 1 / 16,
      pattern = parse_pattern({
        "E,1,1.64,0.47  E,0,1.07,0.43",
        "E,1,1.95,0.16  B,1,1.92,0.61",
        "F,1,1.75,0.38  F#,0,0.92,0.57",
        "B,0,0.88,0.32  F#,1,1.11,0.64",
        "B,0,1.99,0.3  C#,1,1.17,0.59",
        "F#,1,1.2,0.17  F,1,0.84,0.5",
        "G#,0,1.2,0.38",
        "A#,1,1.43,0.5  D,0,1.51,0.2",
        "G,0,1.26,0.61",
      }),
    },
    [2] = {
      step_interval = 1 / 16,
      pattern = parse_pattern({
        "G,-2,1,0.27 E,-2,1,0.14",
        "E,-1,1,0.17 D,2,1,0.17",
        "D,-1,1,0.16 F#,-2,1,0.2",
        "C#,2,1,0.26 F#,2,1,0.27",
        "D,2,1,0.24 G,1,1,0.32",
        "D,1,1,0.07 C,-2,1,0.22",
        "G,-2,1,0.27",
        "F#,0,1,0.34 G#,-2,1,0.2",
        "E,-1,1,0.07 E,0,1,0.11",
      }),
    },
    [3] = {
      step_interval = 1 / 16,
      pattern = parse_pattern({
        "F,0,0.64,0.43",
        "A#,0,0.65,0.4  D#,2,0.55,0.16",
        "A#,2,0.9,0.33",
        "A,0,0.76,0.52",
        "C#,0,0.97,0.41",
        "C#,0,0.91,0.5  F,0,0.78,0.24",
        "D#,0,0.84,0.54  F,2,0.97,0.36",
        "D#,2,0.72,0.4",
        "A,0,0.7,0.33  A,2,1.0,0.43",
      }),
    },
    [4] = {
      step_interval = 1 / 16,
      pattern = parse_pattern({
        "D#,0,1,0.63",
        "G,0,1,0.58 C,-1,1,0.5",
        "G,-1,1,0.64 A,0,1,0.23",
        "D#,0,1,0.24 G#,0,1,0.49",
        "D#,0,1,0.22 C#,-1,1,0.58",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D,0,1,0.29 A,-1,1,0.37",
        "D#,0,1,0.63",
        "G,0,1,0.58 C,-1,1,0.5",
        "G,-1,1,0.64 A,0,1,0.23",
        "D#,0,1,0.24 G#,0,1,0.49",
        "D#,0,1,0.22 C#,-1,1,0.58",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D#,0,1,0.63",
        "D,0,1,0.29 A,-1,1,0.37",
      }),
    },
  }

  -- local pattern = public.pattern and
  --                   (seqs[public.pattern] or new_pattern(public.pattern_length)) or
  --                   new_pattern(public.pattern_length)

  local idx = 1
  local pattern = seqs[idx]
  public.pattern_length = #pattern.pattern

  input[1].mode("change", 0.1, 0.2, "rising")
  input[1].change = function()
    idx = idx + 1
    print("new idx:", idx)
    pattern = seqs[idx]
  end

  clock.tempo = 160
  output[1]:clock(4 * 1 / 16)
  output[2].action = pulse()
  output[3].action = ar()

  print("playing " .. (public.pattern or "<random>"))
  tl.loop {4 * pattern.step_interval, {sequencer, pattern.pattern}}
end
