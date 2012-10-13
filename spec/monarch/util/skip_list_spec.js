describe("Monarch.Util.SkipList", function() {
  describe("insertion, removal, and search", function() {
    it("correctly handles operations for a randomized dataset", function() {
      var skipList, unusedLetters, insertedLetters, removedLetters;

      function randomNumber(upTo) {
        return Math.floor(Math.random() * upTo);
      }

      function randomElement(array, remove) {
        var i = randomNumber(array.length);
        var elt = array[i];
        if (remove) array.splice(i, 1);
        return elt;
      }

      function insert() {
        if (unusedLetters.length === 0) return;
        var letter = randomElement(unusedLetters, 'remove');
        var index = skipList.insert(letter, letter);
        insertedLetters.push(letter);
        insertedLetters = insertedLetters.sort();
        expect(index).toBe(_.sortedIndex(insertedLetters, letter));
        expect(skipList.values()).toEqual(insertedLetters);
      }

      function find() {
        if (insertedLetters.length > 0) {
          var letter = randomElement(insertedLetters);
          var expectedIndex =  _.sortedIndex(insertedLetters, letter);
          expect(skipList.find(letter)).toBe(letter); // key -> value (key and value are both the letter in this case)
          expect(skipList.indexOf(letter)).toBe(expectedIndex);
          expect(skipList.at(expectedIndex)).toBe(letter);
          expect(skipList.at(insertedLetters.length)).toBeUndefined();
        }
        if (removedLetters.length > 0) {
          var letter = randomElement(removedLetters);
          expect(skipList.find(letter)).toBeUndefined();
          expect(skipList.remove(letter)).toBe(-1);
        }
      }

      function remove() {
        if (insertedLetters.length === 0) return;
        var letter = randomElement(insertedLetters, 'remove');
        var index = skipList.remove(letter);
        expect(index).toBe(_.sortedIndex(insertedLetters, letter));
        removedLetters.push(letter);

        expect(skipList.values()).toEqual(insertedLetters.sort());
      }

      function randomAction() {
        switch (randomNumber(3)) {
          case 0: insert(); break;
          case 1: remove(); break;
          case 2: find(); break;
        }
      }

      function runTrial() {
        unusedLetters = [];
        insertedLetters = [];
        removedLetters = [];
        for (var i = 97; i <= 122; i++) { unusedLetters.push(String.fromCharCode(i)) }
        skipList = new Monarch.Util.SkipList();
        _(100).times(randomAction);
      }

      _(100).times(runTrial);
    });
  });

  describe("#indexOf", function() {
    it("returns the index of an entry or -1", function() {
      var skipList = new Monarch.Util.SkipList();
      expect(skipList.indexOf('a')).toBe(-1);
      skipList.insert('a');
      expect(skipList.indexOf('a')).toBe(0);
      expect(skipList.indexOf('b')).toBe(-1);
    });
  });
});
