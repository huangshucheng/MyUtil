print("luaplus---------------")
num = 120;

function addNum(a,b)
    return a+b;
end

mytb = {1,2,4,6,8,5,34}

--/////////////////////////////////////
--[[
print("addfunc: " .. tostring(addFunc(100,200)))
for k,v in pairs(MyTable) do
	print(k,v)
end

for k,v in pairs(hcctb) do
	print(k,v)
end
]]

--print(tostring(mymodule))
--print(mymodule.add1(3,4))

local logger = Logger();

--local logger2 = Logger2(250);
--local logger3 = Logger3(logger);
--logger:LogMember("hcc--->LogMember")
--logger:LogVirtual("hcc--->LogVirtual")
--logger:setValue(255)
--print(logger:getValue())

--logger:Free()

--print("callfunc:  " .. tostring(logger:callFunc(nil)))