Monarch.RecordRetriever =
  retrieveRecords: Monarch.Util.Visitor.visit

  visit_Relations_Selection: (r) ->
    _.filter(r.operand.all(), (tuple) =>
      r.predicate.evaluate(tuple))

  visit_Relations_Difference: (r) ->
    _.difference(r.left.all(), r.right.all())

  visit_Relations_InnerJoin: (r) ->
    all = []
    r.left.each (leftTuple) =>
      r.right.each (rightTuple) =>
        composite = r.buildComposite(leftTuple, rightTuple)
        all.push(composite) if r.predicate.evaluate(composite)
    all

  visit_Relations_Limit: (r) ->
    r.operand.all()[0...r.count]

  visit_Relations_Offset: (r) ->
    r.operand.all()[r.count..]

  visit_Relations_OrderBy: (r) ->
    r.operand.all().sort(r.buildComparator(true))

  visit_Relations_Projection: (r) ->
    r.operand.map((composite) =>
      composite.getRecord(r.table.name))

  visit_Relations_Union: (r) ->
    _.union(r.left.all(), r.right.all()).
      sort(r.buildComparator(true))
