num = 1200

--print("num=========: " .. num)

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

name = "hccfuck"
version = 123456
me = { name = "hccfuck", gender = "female"}

mytb = {}

function add (a,b)
    return a+b
end

--local ctb = getCtb()
--print("ctb: " .. tostring(ctb))
--[[
local str = l_split("hai,,there",",");
print("str: " .. tostring(str))    

if next(str) then
    for k , v in pairs(str) do
        print(k,v)
    end
else
    print("tb is null")
end

--mylib
local mylib = require("hcclib");
print("mylib: " .. tostring(mylib))
print(mylib.l_showRes1())
print(mylib.l_showRes2("res222222"))
]]
--array
local array = require("array")
local _array = array.new(100)
print("array: " .. tostring(_array))
array.set(_array,1,2,33,4,6);
print("size: " ..tostring(array.size(_array)));
print("get: " ..tostring(array.get(_array,1)));


local rlt = addNum(111,222);
print("rlt: " ..rlt)