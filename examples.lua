local Streams <const> = require('Streams')

local function main()
	local numTbl <const> = {7,6,5,8,4,3,2,1,1,1,2,3}
	--find first item which passes. we filter stream to only have values less than five. we then map the stream to multiple elements by 2. finally we find the first item in stream to finsih the pipeline.
	local findFirst <const> = Streams:new(numTbl):filter(function(i) return i < 5  end):map(function(i) return i * 2 end):findFirst()
	--in our exxample, 4 is the first element which is less than 5. it is multiplied by 2 to equal 8. it should be the element returned by findFirst.
	io.write("does find first equals 8 ? ",tostring(findFirst == 8),"\n")

	--lets reduce all the items in numTbl by summing them together
	local sum <const> = Streams:new(numTbl):reduce(function(results,i) return results + i  end,0)
	io.write("sum of all items in numTbl is: ",sum,"\n")

	--lets make a set from numTbl containing only even numbers
	local evenSet <const> = Streams:new(numTbl):filter(function(i) return i % 2 == 0  end):asSet(function(set,i) return set[i]  end)
	io.write("set containing even numbers from numTbl is: {")
	for k,_ in pairs(evenSet) do
		io.write(k,",")
	end
	io.write("}\n")

	--return an array of all keys in the dictionary which have even numbers as values.
	local arr <const> = Streams:dictionaryStream({a = 1, b = 2, c = 3, d = 4}):filter(function(k,v) return v % 2 == 0  end):asArray()
	io.write("keys in dictionary which have even numbers for values is: {")
	for i=1,#arr -1,1 do
		io.write(arr[i],",")
	end
	io.write(arr[#arr],"}\n")

	local alphabet <const> = {"a","b","c","d","e","f"}
	--make a key/value table using letters from alphabet array as keys and the value is the index to that letter.
	local dictionary <const> = Streams:new(numTbl):filter(function(i) return i <= #alphabet end):asMap(function(i)return alphabet[i] end,function(i) return i end)
	io.write("dictionary which list the number of the letter in alphabet array.\n")
	for k,v in pairs(dictionary) do
		io.write(k,":",v,"\n")
	end

	local linkedListStream <const> = Streams:linkedListStream(Streams.LinkedList:new({1,2,3,4,5,6})):filter(function (i) return i < 4 end)
	--make a copy of linked list stream. includes all steps added to it up until the copy operation.
	local copyStream <const> = linkedListStream:copyOf()
	--print each letter which is less than 4 in alphabet array
	linkedListStream:map(function(i) return alphabet[i] end):forEach(function(i) io.write("letter in the linked list is: ",i,"\n")  end)
	io.write("printing copyStream now: \n")
	--the previous map and foreach don't apply to the copy of the stream. copyStream is left unaffected by changes to linkedListStream
	copyStream:forEach(function(i) io.write("i in copyStream is: ",i,"\n")  end)
end


main()
