Monarch.Events =
  onInsert: (relation, callback, context) ->
    Monarch.Events.activate(relation)
    relation._insertNode.subscribe(callback, context)
  onUpdate: (relation, callback, context) ->
    Monarch.Events.activate(relation)
    relation._updateNode.subscribe(callback, context)
  onRemove: (relation, callback, context) ->
    Monarch.Events.activate(relation)
    relation._removeNode.subscribe(callback, context)

  publishInsert: (relation, args...) ->
    relation._insertNode.publish(args...)
  publishUpdate: (relation, args...) ->
    relation._updateNode.publish(args...)
  publishRemove: (relation, args...) ->
    relation._removeNode.publish(args...)

  activate: (relation) ->
    @visit(relation) unless relation.isActive
  clear: (relation) ->
    clearEvents(relation)

  # private

  visit: Monarch.Util.Visitor.visit

  visit_Relations_Table: (r) ->
    setupEvents(r)

  visit_Relations_Difference: (r) ->
    subscribeToLeftAndRightOperands r,
      left:
        onInsert: (tuple, index, newKey, oldKey) ->
          r.insert(tuple, newKey, oldKey) unless r.right.containsKey(newKey, oldKey)
        onUpdate: (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
          r.tupleUpdated(tuple, changeset, newKey, oldKey) unless r.right.containsKey(newKey, oldKey)
        onRemove: (tuple, index, newKey, oldKey) ->
          r.remove(tuple) if r.containsKey(oldKey)
      right:
        onInsert: (tuple, index, newKey, oldKey) ->
          r.remove(tuple) if r.containsKey(newKey, oldKey)
        onRemove: (tuple, index, newKey, oldKey) ->
          r.insert(tuple, newKey, oldKey) if r.left.containsKey(newKey, oldKey)

  visit_Relations_InnerJoin: (r) ->
    subscribeToBothOperands r,
      onInsert: (side, tuple1, index, newKey, oldKey) ->
        otherOperand(r, side).each (tuple2) ->
          composite = r.buildComposite(tuple1, tuple2, side)
          newCompositeKey = r.buildKey(composite)
          oldCompositeKey = r.buildKey(composite, oldKey)
          if r.predicate.evaluate(composite)
            r.insert(composite, newCompositeKey, oldCompositeKey)
      onUpdate: (side, tuple1, changeset, newIndex, oldIndex, newKey, oldKey) ->
        otherOperand(r, side).each (tuple2) ->
          composite = r.buildComposite(tuple1, tuple2, side)
          newCompositeKey = r.buildKey(composite)
          oldCompositeKey = r.buildKey(composite, oldKey)
          existingComposite = r.findByKey(oldCompositeKey)
          if r.predicate.evaluate(composite)
            if existingComposite
              r.tupleUpdated(existingComposite, changeset, newCompositeKey, oldCompositeKey)
            else
              r.insert(composite, newCompositeKey, oldCompositeKey)
          else
            if existingComposite
              r.remove(existingComposite, newCompositeKey, oldCompositeKey, changeset)
      onRemove: (side, tuple1, index, newKey, oldKey) ->
        otherOperand(r, side).each (tuple2) ->
          newComposite = r.buildComposite(tuple1, tuple2, side)
          newCompositeKey = r.buildKey(newComposite)
          oldCompositeKey = r.buildKey(newComposite, oldKey)
          existingComposite = r.findByKey(oldCompositeKey)
          if existingComposite
            r.remove(existingComposite, newCompositeKey, oldCompositeKey)

  visit_Relations_Limit: (r) ->
    subscribeToOperand r,
      onInsert: (tuple, index, newKey, oldKey) ->
        if index < r.count
          oldLastTuple = r.at(r.count - 1)
          r.remove(oldLastTuple) if oldLastTuple
          r.insert(tuple, newKey, oldKey)
      onUpdate: (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
        if oldIndex < r.count
          if newIndex < r.count
            r.tupleUpdated(tuple, changeset, newKey, oldKey)
          else
            r.remove(tuple, newKey, oldKey, changeset)
            newLastTuple = r.operand.at(r.count - 1)
            r.insert(newLastTuple) if newLastTuple
        else
          if newIndex < r.count
            oldLastTuple = r.at(r.count - 1)
            r.remove(oldLastTuple) if oldLastTuple
            r.insert(tuple, newKey, oldKey)
      onRemove: (tuple, index, newKey, oldKey) ->
        r.remove(tuple, newKey, oldKey)
        newLastTuple = r.operand.at(r.count - 1)
        r.insert(newLastTuple) if newLastTuple

  visit_Relations_Offset: (r) ->
    subscribeToOperand r,
      onInsert: (tuple, index, newKey, oldKey) ->
        if index < r.count
          newFirstTuple = r.operand.at(r.count)
          r.insert(newFirstTuple) if newFirstTuple
        else
          r.insert(tuple, newKey, oldKey)
      onUpdate: (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
        if oldIndex < r.count
          if newIndex >= r.count
            oldFirstTuple = r.at(0)
            r.remove(oldFirstTuple) if oldFirstTuple
            r.insert(tuple, newKey, oldKey)
        else
          if newIndex < r.count
            r.remove(tuple, newKey, oldKey, changeset)
            newFirstTuple = r.operand.at(r.count)
            r.insert(newFirstTuple) if newFirstTuple
          else
            r.tupleUpdated(tuple, changeset, newKey, oldKey)
      onRemove: (tuple, index, newKey, oldKey) ->
        if index < r.count
          oldFirstTuple = r.at(0)
          r.remove(oldFirstTuple) if oldFirstTuple
        else
          r.remove(tuple, newKey, oldKey)

  visit_Relations_OrderBy: (r) ->
    subscribeToOperand r,
      onInsert: (tuple) ->
        r.insert(tuple)
      onUpdate: (tuple, changeset) ->
        r.tupleUpdated(tuple, changeset, r.buildKey(tuple), r.buildKey(tuple, changeset))
      onRemove: (tuple, index, newKey, oldKey, changeset) ->
        r.remove(tuple, r.buildKey(tuple), r.buildKey(tuple, changeset))

  visit_Relations_Projection: (r) ->
    subscribeToOperand r,
      onInsert: (tuple, index, newKey, oldKey) ->
        r.insert(tuple.getRecord(r.table.name), newKey, oldKey)
      onUpdate: (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
        r.tupleUpdated(tuple, changeset, newKey, oldKey)
      onRemove: (tuple, index, newKey, oldKey) ->
        r.remove(tuple.getRecord(r.table.name), newKey, oldKey)

  visit_Relations_Selection: (r) ->
    subscribeToOperand r,
      onInsert: (tuple, _, newKey, oldKey) ->
        r.insert(tuple, newKey, oldKey) if r.predicate.evaluate(tuple)
      onUpdate: (tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
        if r.predicate.evaluate(tuple)
          if r.containsKey(oldKey)
            r.tupleUpdated(tuple, changeset, newKey, oldKey)
          else
            r.insert(tuple, newKey, oldKey)
        else
          if r.containsKey(oldKey)
            r.remove(tuple, newKey, oldKey, changeset)
      onRemove: (tuple, _, newKey, oldKey) ->
        r.remove(tuple, newKey, oldKey) if (r.containsKey(oldKey))

  visit_Relations_Union: (r) ->
    subscribeToBothOperands r,
      onInsert: (side, tuple, index, newKey, oldKey) ->
        r.insert(tuple, newKey, oldKey) unless r.containsKey(newKey, oldKey)
      onUpdate: (side, tuple, changeset, newIndex, oldIndex, newKey, oldKey) ->
        r.tupleUpdated(tuple, changeset, newKey, oldKey)
      onRemove: (side, tuple, index, newKey, oldKey) ->
        unless otherOperand(r, side).containsKey(newKey, oldKey)
          r.remove(tuple, newKey, oldKey)

subscribeToOperand = (r, callbacks) ->
  Monarch.Events.activate(r.operand)
  setupEvents(r)
  for event, callback of callbacks
    subscribe(r, r.operand, event, callback)

subscribeToLeftAndRightOperands = (r, callbacksBySide) ->
  Monarch.Events.activate(r.right)
  Monarch.Events.activate(r.left)
  setupEvents(r)
  for side, callbacks of callbacksBySide
    for event, callback of callbacks
      subscribe(r, r[side], event, callback)

subscribeToBothOperands = (r, callbacks) ->
  callbacksBySide = { left: {}, right: {} }
  for side, sideCallbacks of callbacksBySide
    for event, callback of callbacks
      sideCallbacks[event] = _.bind(callback, this, side)
  subscribeToLeftAndRightOperands(r, callbacksBySide)

subscribe = (r, operand, event, callback) ->
  r.subscriptions.add(Monarch.Events[event](operand, callback))

deactivateIfNeeded = (r) ->
  if (hasSubscriptions(r) and r.constructor isnt Monarch.Relations.Table)
    r._insertNode = null
    r._updateNode = null
    r._removeNode = null
    r.subscriptions.destroy()
    r.isActive = false

setupEvents = (r) ->
  r._insertNode = new Monarch.Util.Node()
  r._updateNode = new Monarch.Util.Node()
  r._removeNode = new Monarch.Util.Node()
  r._insertNode.onEmpty -> deactivateIfNeeded(r)
  r._updateNode.onEmpty -> deactivateIfNeeded(r)
  r._removeNode.onEmpty -> deactivateIfNeeded(r)
  r.subscriptions = new Monarch.Util.SubscriptionBundle()
  r.isActive = true
  r.contents()

clearEvents = (r) ->
  r._insertNode.clear()
  r._updateNode.clear()
  r._removeNode.clear()

hasSubscriptions = (r) ->
  return false unless r.isActive
  (r._insertNode.size() + r._updateNode.size() + r._removeNode.size()) > 0

otherOperand = (r, side) ->
  if side == 'left' then r.right else r.left
