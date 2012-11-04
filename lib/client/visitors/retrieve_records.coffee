class Monarch.Visitors.RetrieveRecords extends Monarch.Visitors.Base
  visitSelection: (r) ->
    _.filter(r.operand.all(), (tuple) =>
      r.predicate.evaluate(tuple))

  visitDifference: (r) ->
    _.difference(r.left.all(), r.right.all())

  visitInnerJoin: (r) ->
    all = []
    r.left.each (leftTuple) =>
      r.right.each (rightTuple) =>
        composite = r.buildComposite(leftTuple, rightTuple)
        all.push(composite) if r.predicate.evaluate(composite)
    all

  visitLimit: (r) ->
    r.operand.all()[0...r.count]

  visitOffset: (r) ->
    r.operand.all()[r.count..]

  visitOrderBy: (r) ->
    r.operand.all().sort(r.buildComparator(true))

  visitProjection: (r) ->
    r.operand.map((composite) =>
      composite.getRecord(r.table.name))

  visitUnion: (r) ->
    _.union(r.left.all(), r.right.all()).
      sort(r.buildComparator(true))
