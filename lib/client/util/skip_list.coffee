class Monarch.Util.SkipList
  constructor: (@comparator=@defaultComparator) ->
    @maxLevels = 8
    @p = 0.25
    @currentLevel = 0

    # javascript has built in infinities, but we need to compare our infinities against
    # any kind of key, including non-numbers
    @minusInfinity = {}
    @plusInfinity = {}

    @head = new Monarch.Util.SkipListNode(@maxLevels, @minusInfinity, undefined)
    @nil = new Monarch.Util.SkipListNode(@maxLevels, @plusInfinity, undefined)
    for i in [0...@maxLevels]
      @head.pointer[i] = @nil
      @head.distance[i] = 1

  insert: (key, value=key) ->
    next = @buildNextArray()
    nextDistance = @buildNextDistanceArray()
    closestNode = @findClosestNode(key, next, nextDistance)

    # if the key is a duplicate, replace its value. otherwise insert a node
    if closestNode.key == key
      closestNode.value = value
    else
      level = @randomLevel()

      # if the overall level in increasing, set the new level and fill in the next array with @head for the new levels
      if level > @currentLevel
        next[i] = @head for i in [@currentLevel + 1..level]
        @currentLevel = level

      # create a new node and insert it by updating pointers at every level
      newNode = new Monarch.Util.SkipListNode(level, key, value)
      steps = 0
      for i in [0..level]
        prevNode = next[i]
        newNode.pointer[i] = prevNode.pointer[i]
        prevNode.pointer[i] = newNode
        newNode.distance[i] = prevNode.distance[i] - steps
        prevNode.distance[i] = steps + 1
        steps += nextDistance[i]

      maxLevels = @maxLevels
      for i in [level + 1...maxLevels]
        next[i].distance[i] += 1

      _.sum(nextDistance)

  insertAll: (array) ->
    @insert(element) for element in array

  remove: (key) ->
    next = @buildNextArray()
    nextDistance = @buildNextDistanceArray()
    cursor = @findClosestNode(key, next, nextDistance)

    if @compare(cursor.key, key) == 0
      for i in [0..@currentLevel]
        if next[i].pointer[i] == cursor
          next[i].pointer[i] = cursor.pointer[i]
          next[i].distance[i] += cursor.distance[i] - 1
        else
          next[i].distance[i] -= 1

      # Check if we have to lower level
      @currentLevel-- while @currentLevel > 0 && @head.pointer[@currentLevel] == @nil

      _.sum(nextDistance)
    else
      -1

  find: (key) ->
    cursor = @findClosestNode(key)
    if @compare(cursor.key, key) == 0
      cursor.value
    else
      undefined

  indexOf: (key) ->
    nextDistance = @buildNextDistanceArray()
    cursor = @findClosestNode(key, null, nextDistance)
    if @compare(cursor.key, key) == 0
      _.sum(nextDistance)
    else
      -1

  at: (index) ->
    index += 1
    cursor = @head

    for i in [@currentLevel..0]
      while cursor.distance[i] <= index
        index -= cursor.distance[i]
        cursor = cursor.pointer[i]

    if cursor == @nil
      undefined
    else
      cursor.value

  keys: ->
    keys = []
    cursor = @head.pointer[0]
    while cursor != @nil
      keys.push(cursor.key)
      cursor = cursor.pointer[0]
    keys

  values: ->
    values = []
    cursor = @head.pointer[0]
    while cursor != @nil
      values.push(cursor.value)
      cursor = cursor.pointer[0]
    values

  compare: (a, b) ->
    if (a == @minusInfinity) then return (if (b == @minusInfinity) then 0 else -1)
    if (b == @minusInfinity) then return (if (a == @minusInfinity) then 0 else 1)
    if (a == @plusInfinity) then return (if (b == @plusInfinity) then 0 else 1)
    if (b == @plusInfinity) then return (if (a == @plusInfinity) then 0 else -1)
    return @comparator(a, b)

  defaultComparator: (a, b) ->
    return -1 if a < b
    return 1 if a > b
    0

  findClosestNode: (key, next, nextDistance) ->
    # search the skiplist in a stairstep descent, following the highest path that doesn't overshoot the key
    cursor = @head
    for i in [@currentLevel..0]
      # move forward as far as possible while keeping the cursor node's key less than the inserted key
      while @compare(cursor.pointer[i].key, key) < 0
        nextDistance?[i] += cursor.distance[i]
        cursor = cursor.pointer[i]
      # when the next link would be bigger than our key, drop a level
      # before we do, note that this is the last node we visited at level i in the next array
      next?[i] = cursor

    # advance to the next node... it is the nearest node whose key is >= the search key
    cursor.pointer[0]

  randomLevel: ->
    maxLevels = @maxLevels
    level = 0
    level++ while Math.random() < @p and level < maxLevels - 1
    level

  buildNextArray: ->
    next = new Array(@maxLevels)
    for i in [0...@maxLevels]
      next[i] = @head
    next

  buildNextDistanceArray: ->
    nextDistance = new Array(@maxLevels)
    for i in [0...@maxLevels]
      nextDistance[i] = 0
    nextDistance
