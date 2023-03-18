A lua module which attempts to implement a simple and simplistic mimicry of java 8 streams. 
see 'examples.lua' for some examples of use.  

## API
### constructors
 - Streams:dictionaryStream(data)
   - create a stream from a key/value table.
 - Streams:setStream(data)
   - create a stream from a table used as a set.
 - Streams:intRange(start,stop)
   - create a stream consisting of all integers from start to stop. range is inclusive.
 - Streams:linkedListStream(linkedList,[getData])
   - create a stream from a linked list.
     - the linkedlsit used must have a 'next' field which points to the next node
     - must also have a getData method to extract data from node.
   - ```getData``` needs to be provided if linked list implementation doesn't provide the function
     - getData must take in node and return data in that node. ```getData(node) return data from node```
 - Streams:new(dataRange,[start],[limit])
   - return new stream from table used as array.
     - ```start``` is optional start index. Default is 1
     - ```stop``` is optional index to stop stream at. default is #dataRange
  
### intermediate operators
 - Streams:filter(func)
   - filter stream elements. 
     - ```func``` should take in stream element and return true or false. only stream elements which return true will pass to next stage.
 - Streams:map(func)
   - takes stream elements and maps them to a different value or item.
     - ```func``` should take in a stream element and return a value which will then be passed to next stage in pipeline.
 - Streams:distinct([keyFunc])
   - will restrict pipeline to only distinct elements. 
     - ``keyFunc`` should take in stream elements and return a unique value. this value determines if entire object is distinct from other stream elements. Default is to use the stream element itself.
  
### terminating operators
 - Streams:concatStr([sep],[getStr])
   - concats stream into a single string.
     - ```sep``` separator for each stream element in string. defaults to none.
     - ```getStr``` function to take in string item and return a string representation of that item. defaults to using the item itself.
 - Streams:count()
   - returns a count of all elements which pass through to the end of the pipeline.
 - Streams:asMap(keyFunc,valueFunc)
   - returns stream elements in a key/value table. ```tbl[key] = value```
     - ```keyFunc``` function to take in stream elements and return a key.
     - ```valueFunc``` function to take in stream elements and return a value.
 - Streams:asLinkedList([linkedList])
   - returns stream elements as a Linked list. if no implementation is provided then the internal Linked List class is used. please see [linked list docs](#internal-linkedlist)
     - ```linkedList``` user provided Linked List class
       - class must implement a constructor as 'new' ```linkedList:new()```
       - class must implement an add function to add items to list ```list:add(item)```
 - Streams:asSet([comparator])
   - returns set consisting of stream elements
     - ```comparator``` function to check for distinctness. should return true if set contains the item already. Otherwise, return false. ```comparator(list,data) return true/false ```
 - Streams:asArray()
   - returns stream elements as an array
 - Streams:findFirst()
   - returns the very first stream element which reaches end of pipeline.
 - Streams:anyMatch(func)
   - returns true if any stream element causes 'func' to return true.
     - ```func``` function takes in stream element and returns true/false.
 - Streams:allMatch(func)
   - returns true if all stream elements cause 'func' to return true
     - ```func``` function which takes in stream element and returns true/false.
 - Streams:reduce(func,initialVal)
   - reduce stream elements down to a single item using an associative function on each item and result of previous call to 'func'
     - ```func``` associative function which takes in accumulated results and stream element. returns a single value to use as new results value. ```results = func(results,item) return value```
     - ```intialVal``` the initial value to use for the results.
 - Streams:forEach(func)
   - run 'func' on each stream element.
     - ```func``` function takes in stream element. expects no return value  ```func(element) do stuff here  end```

### convenience functions
 - DictionaryStream:copyOf()
   - return a copy of the Dictionary Stream
 - SetStream:copyOf()
     - return a copy of the Set Stream
 - IntStream:copyOf()
     - return a copy of the Int Stream
 - LinkedListStream:copyOf()
     - return a copy of the Linked List Stream
 - Streams:copyOf()
     - return a copy of the Stream

### internal LinkedList
 - A very simple and simplistic Linked List implementation with is used internally and is exposed as a convenience. I would recommend to use a more robust and complete implementation of Linked List.
   - each node in list implements next,prev,and item field.
     - next: next node in list
     - prev: previous node in list
     - item: the data which the node holds.
   - List implements a head node and a tail node.
     - head.prev == nil
     - tail.next == nil
#### Linked List API
  - LinkedList:replaceTail(item)
    - replace tail node with a node containing this item
  - LinkedList:new([tbl])
    - returns new linked list.
      - ```tbl``` an array of values to add to the linked list. each item in array is added as a node in linked list in order of array traversal.
  - LinkedList:remove(n)
    - remove the Nth node in the linked list
  - LinkedList:add(item)
    - add item to the linked list.

