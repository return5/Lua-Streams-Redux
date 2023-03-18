
local setmetatable <const> = setmetatable
local io <const> = io
local pairs <const> = pairs
local concat <const> = table.concat

local Streams <const> = {}
Streams.__index = Streams

local IntStream <const> = {}
setmetatable(IntStream,Streams)
IntStream.__index = IntStream

local LinkedListStream <const> = {}
setmetatable(LinkedListStream,Streams)
LinkedListStream.__index = LinkedListStream

local DictionaryStream <const> = {}
setmetatable(DictionaryStream,Streams)
DictionaryStream.__index = DictionaryStream

local SetStream <const> = {}
setmetatable(SetStream,DictionaryStream)
SetStream.__index = SetStream

local Operation <const> = {}
Operation.__index = Operation

local LinkedList <const> = {}
LinkedList.__index = LinkedList

local Node <const> = {}
Node.__index = Node

_ENV = Streams

function Operation:new(func,isTerm)
	return setmetatable({func = func,isTerm = isTerm or false},self)
end

function Operation:execute(stream,a,b)
	return self.func(stream,a,b)
end

function Streams:loopOperations(a,b)
	local tempOp = self.operations.head
	self.oPCont = true
	while self.oPCont and tempOp and not self.terminate do
		a,b = tempOp.item:execute(self,a,b)
		tempOp = tempOp.next
	end
	return self
end

local function addOperation(stream,func,isTerm)
	local node <const> = Operation:new(func,isTerm)
	if stream.operations.tail and stream.operations.tail.item.isTerm then
		stream.operations:replaceTail(node)
	else
		stream:addNode(node)
	end
	return stream
end

-- intermediate operations --

function Streams:filter(func)
	local filterFunc <const> = function(stream,a,b) if not func(a,b) then stream.oPCont = false end return a,b end
	return addOperation(self,filterFunc)
end

function Streams:map(func)
	local mapFunc <const> = function(_,a,b) return func(a,b) end
	return addOperation(self,mapFunc)
end

function Streams:distinct(getData)
	local distinct <const> = {}
	local keyFunc <const> = getData or function(a) return a end
	local distinctFunc <const> = function(stream,a,b) local data <const> = keyFunc(a,b); if not distinct[data] then distinct[data] = true; return a,b else stream.oPCont = false; return a,b end end
	return addOperation(self,distinctFunc)
end

local function LinkedListLoop(list,func)
	local temp = list.data.head
	local getItem <const> = temp.getData and temp.getData or list.getData
	while temp and not list.terminate do
		func(getItem(temp),list)
		temp = temp.next
	end
	return list:returnFunction()
end

local function loopStream(stream,func,getData)
	local start <const> = stream.start and stream.start or 1
	local stop <const> = stream.limit and stream.limit or #stream.data
	local i = start
	while i <= stop and not stream.terminate do
		func(getData(stream,i),stream)
		i = i + 1
	end
	return stream:returnFunction()
end

local function loopDictionary(stream,func)
	for k,v in pairs(stream.data) do
		func(k,v,stream)
		if stream.terminate then
			break
		end
	end
	return stream:returnFunction()
end

-- terminating operations --

local function setAndRunTerminator(stream,func)
	addOperation(stream,func,true)
	stream.terminate = false
	return stream:execute()
end

function Streams:concatStr(sep,getStr)
	self.returnValue = {}
	self.returnFunction = function(stream) return concat(stream.returnValue,sep) end
	local getString <const> = getStr or function(a) return a end
	local concatFunc <const> = function(stream,a,b) stream.returnValue[#stream.returnValue + 1] = getString(a,b); return a,b end
	return setAndRunTerminator(self,concatFunc)
end

local function returnValueFunc(stream)
	return stream.returnValue
end

function Streams:count()
	self.returnFunction = returnValueFunc
	self.returnValue = 0
	self.returnFunction = returnValueFunc
	local countFunc <const> = function(stream,a,b) stream.returnValue  = stream.returnValue + 1; return a,b end
	return setAndRunTerminator(self,countFunc)
end

function Streams:asMap(keyFunc,valueFunc)
	self.returnFunction = returnValueFunc
	self.returnValue = {}
	local func <const> = function(stream,a,b) stream.returnValue[keyFunc(a,b)] = valueFunc(a,b); return a,b end
	return setAndRunTerminator(self,func)
end

function Streams:asLinkedList(linkedList)
	self.returnFunction = returnValueFunc
	self.returnValue = linkedList and linkedList:new() or LinkedList:new()
	local func <const> = function(stream,a) stream.returnValue:add(a); return a end
	return setAndRunTerminator(self,func)
end

function Streams:asSet()
	self.returnFunction = returnValueFunc
	self.returnValue = {}
	local func <const> = function(stream,data) stream.returnValue[data] = true; return data end
	return setAndRunTerminator(self,func)
end

function Streams:asArray()
	self.returnFunction = returnValueFunc
	self.returnValue = {}
	local func <const> = function(stream,data) stream.returnValue[#stream.returnValue + 1] = data; return data end
	return setAndRunTerminator(self,func)
end

function Streams:findFirst()
	self.returnFunction = returnValueFunc
	self.returnValue = nil
	local func <const> = function(stream,data) stream.returnValue = data; stream.terminate = true; return data end
	return setAndRunTerminator(self,func)
end

function Streams:anyMatch(func)
	self.returnFunction = returnValueFunc
	self.returnValue = false
	local matchFunc <const> = function(stream,a,b) if func(a,b) then stream.returnValue = true; stream.terminate = true; end  end
	return setAndRunTerminator(self,matchFunc)
end

function Streams:allMatch(func)
	self.returnFunction = returnValueFunc
	self.returnValue = true
	local matchFunc <const> = function(stream,a,b) if not func(a,b) then stream.returnValue = false; stream.terminate = true end  end
	return setAndRunTerminator(self,matchFunc)
end

function Streams:reduce(func,initialVal)
	self.returnFunction = returnValueFunc
	self.returnValue = initialVal
	local reduceFunc <const> = function(stream,a,b) if stream.returnValue == nil then stream.returnValue = a else stream.returnValue = func(stream.returnValue,a,b) end end
	return setAndRunTerminator(self,reduceFunc)
end

function Streams:forEach(func)
	self.returnFunction = returnValueFunc
	local forEach <const> = function(_,a,b) func(a,b); return a,b end
	setAndRunTerminator(self,forEach)
	return self
end

function IntStream:execute()
	return loopStream(self,function(value,list) return list:loopOperations(value) end,function(_,i) return i end)
end

function DictionaryStream:execute()
	return loopDictionary(self,function(k,v,s) return s:loopOperations(k,v) end)
end

function LinkedListStream:execute()
	return LinkedListLoop(self,function(value,list) return list:loopOperations(value) end)
end

function Streams:execute()
	return loopStream(self,function(value,stream) return stream:loopOperations(value) end,function(stream,i) return stream.data[i] end)
end

function Streams:dictionaryStream(data)
	return setmetatable(Streams:new(data),DictionaryStream)
end

function Streams:setStream(data)
	return setmetatable(Streams:new(data),SetStream)
end

function Streams:intRange(start,stop)
	return setmetatable(Streams:new(nil,start,stop),IntStream)
end

function Streams:linkedListStream(dataRange,getData)
	local o <const> =  setmetatable(Streams:new(dataRange),LinkedListStream)
	o.getData = getData
	return o
end

local function addNewNode(list,item)
	local node <const> = Node:new(item)
	list.tail.next = node
	node.prev = list.tail
	list.tail = node
	list.size = list.size + 1
	return list
end

local function addHeadNode(list,item)
	local node <const> = Node:new(item)
	list.head = node
	list.tail = node
	list.add = addNewNode
	list.size = list.size + 1
	return list
end

function Node:new(item)
	return setmetatable({item = item},self)
end

function Node:getData()
	return self.item
end

local function removeHeadNode(list)
	list.head = list.head.next
	list.head.prev = nil
	list.size = list.size - 1
	if list.head == nil then
		list.add = addHeadNode
	end
	return true
end

local function removeTailNode(list)
	list.size = list.size - 1
	list.tail = list.tail.prev
	list.tail.next = nil
	return true
end

local function removeNode(list,node)
	list.size = list.size - 1
	node.prev.next = node.next
	node.next.prev = node.prev
	return true
end

function LinkedList:remove(n)
	if n > self.size then
		return false
	elseif n == 1 and self.head then
		return removeHeadNode(self)
	else
		local temp = self.head.next
		local i = 2
		while temp and i < n do
			temp = temp.next
			i = i + 1
		end
		if temp == self.tail  then
			return removeTailNode(self)
		end
		return removeNode(self,temp)
	end
	return false
end

function LinkedList:replaceTail(item)
	if self.head == self.tail then
		addHeadNode(self,item)
	else
		self.tail = self.tail.prev
		addNewNode(self,item)
	end
	return self
end

function LinkedList:new(tbl)
		local o <const> = setmetatable({head = nil,tail = nil,add = addHeadNode,size = 0},self)
	if tbl then
		for i=1,#tbl,1 do
			o:add(tbl[i])
		end
	end
	return o
end

function Streams:addNode(node)
	self.operations:add(node)
	return self
end

local function copyOperations(copy,original)
	local temp = original.operations.head
	while temp do
		addOperation(copy,temp.item.func)
		temp = temp.next
	end
	if copy.operations.tail and original.operations.tail.item.isTerm then
		copy.operations.tail.item.isTerm = true
	end
end

function DictionaryStream:copyOf()
	local o <const> = Streams:dictionaryStream(self.data)
	copyOperations(o,self)
	return o
end

function IntStream:copyOf()
	local o <const> = Streams:intRange(self.start,self.limit)
	copyOperations(o,self)
	return o
end

function LinkedListStream:copyOf()
	local o <const> = Streams:linkedListStream(self.data,self.getData)
	copyOperations(o,self)
	return o
end

function Streams:copyOf()
	local o <const> = Streams:new(self.data,self.start,self.limit)
	copyOperations(o,self)
	return o
end

function Streams:new(dataRange,start,limit)
	local operations <const> = LinkedList:new()
	return setmetatable({ data = dataRange,start = start,limit = limit,terminate = false,
			  oPCont = true,returnValue = nil,operations = operations},self)
end

Streams.LinkedList = LinkedList

return Streams
