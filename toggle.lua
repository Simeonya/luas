--[[  
  This file was protected with MoonSec V3  
  (the original text is captured here for posterity)  
--]]
local protectionNotice = "This file was protected with MoonSec V3"

-- Main deobfuscation function  
local function deobfuscateMoonSecV3(encodedBlob)
  -- Local references to standard libs  
  local str    = string  
  local byte   = str.byte  
  local char   = str.char  
  local num    = tonumber  
  local env    = _ENV            -- target environment for dynamic globals  
  local opcodeMap = {}           -- will hold bidirectional byte↔opcode mapping  
  local memory    = {}           -- auxiliary table for decoding state

  -- Phase 1: “Entropy mixing”  
  -- (advances through a meaningless numeric loop that
  --  randomly picks up references to `string`, `getfenv`, etc.)
  local key = 24_915
  local pos = 0
  while pos < 474 do
    pos = pos + 1
    key = (key - 147) % 40_908

    if key % 2 == 1 then
      -- occasionally capture the global environment
      env = getfenv and getfenv() or env
    else
      -- occasionally pick up `tonumber` or `string` itself
      num, str = num, str
    end
    -- (in the real MoonSec you’d see many nested loops here,
    --  but none of it actually affects the final output beyond
    --  “have we assigned these references yet?”)
  end

  -- Phase 2: Build the opcode ↔ byte lookup table  
  -- The protected blob contains a tiny routine `b.HbzQSQff`
  -- that, for each 0–255, returns an “encoded opcode.”  
  for i = 0, 0xff do
    local code = memory.HbzQSQff(i)  -- un-obfuscated Lua VM call
    opcodeMap[i] = code
    opcodeMap[code] = i
  end

  -- Helper: read a length-prefixed chunk of the bytecode
  local function readBytes(data, n, idxRef)
    local start = idxRef[1]
    idxRef[1] = start + n
    return data:sub(start, start + n - 1)
  end

  -- Phase 3: A tiny custom VM that unpacks the real Lua text
  local function runVM(blob)
    local ip = { 1 }       -- instruction pointer (wrapped in table so we can pass by ref)
    local out = {}         -- collected output chunks
    local stack = {}       -- VM stack
    local consts = {}      -- constant table
    local envLocals = {}   -- local env table

    -- Read instructions until we hit the “end” opcode (`"\5"`)
    while true do
      local opType = readBytes(blob, 1, ip)
      if opType == "\5" then
        break
      end

      local argLen = byte(readBytes(blob, 1, ip))
      local argData = readBytes(blob, argLen, ip)

      if opType == "\2" then
        -- numeric constant
        table.insert(stack, memory.mX_zEebq(argData))

      elseif opType == "\3" then
        -- boolean
        table.insert(stack, argData ~= "\0")

      elseif opType == "\6" then
        -- define a new function in our env
        envLocals[argData] = function(a,b)
          return deobfuscateMoonSecV3(a, b)
        end

      elseif opType == "\4" then
        -- push a previously stored global
        table.insert(stack, envLocals[argData])

      elseif opType == "\0" then
        -- indirect table lookup
        local keyByte = byte(readBytes(blob, 1, ip))
        local tbl = envLocals[argData]
        table.insert(stack, tbl and tbl[keyByte])
      end
    end

    -- Now `stack` contains a sequence of pieces of Lua source.
    -- Concatenate them into the final deobfuscated string:
    return table.concat(stack)
  end

  -- Phase 4: Drive the VM on the embedded string table
  -- (the code itself re-stores a second byte-blob in `t` and then
  --  calls `d(t)`, which is exactly our `runVM` above)
  local rawBlob = encodedBlob  -- in the real script this comes from `t = "...binary data..."`
  local clearLua = runVM(rawBlob)

  -- Phase 5: Return the deobfuscated Lua source
  return clearLua
end

-- Kick things off: grab the hidden blob into `_GovlROVpseJb` and deobfuscate it
local hiddenBlob = _GovlROVpseJb
local humanLua    = deobfuscateMoonSecV3(hiddenBlob)

-- Finally, execute (or print) the cleaned-up code:
-- loadstring(humanLua)()
print(humanLua)
