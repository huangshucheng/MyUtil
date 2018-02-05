num = 1200

print("num=========: " .. num)

--local mylib = require("mylib")
--print("mylib: " .. tostring(mylib))

--[[
local numZ = showZero()
print("numZ: " .. tostring(numZ));

local numOne = showOne()
print("numOne: " .. tostring(numOne));

local numTwo1, numTwo2 = showTwo()
print("numTwo1: " .. tostring(numTwo1) .. "   numTwo2: " .. numTwo2);

local name = getName()
print("name: " .. name)

local tb = getTable()
if tb then
	for i,v in ipairs(tb) do
		print(i,v)
	end
end
]]

--local res1 = mylib.showRes1()
--print("res1: " .. res1)