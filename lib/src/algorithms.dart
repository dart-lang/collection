// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' as math;

import 'utils.dart';

/// Returns a position of the [value] in [sortedList], if it is there.
///
/// If the list isn't sorted according to the [compare] function, the result
/// is unpredictable.
///
/// If [compare] is omitted, this defaults to calling [Comparable.compareTo] on
/// the objects. If any object is not [Comparable], this throws a [TypeError]
/// (`CastError` on some SDK versions).
///
/// Returns -1 if [value] is not in the list by default.
int binarySearch<T>(List<T> sortedList, T value, {int Function(T, T) compare}) {
  compare ??= defaultCompare<T>();
  var min = 0;
  var max = sortedList.length;
  while (min < max) {
    var mid = min + ((max - min) >> 1);
    var element = sortedList[mid];
    var comp = compare(element, value);
    if (comp == 0) return mid;
    if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return -1;
}

/// Returns the first position in [sortedList] that does not compare less than
/// [value].
///
/// If the list isn't sorted according to the [compare] function, the result
/// is unpredictable.
///
/// If [compare] is omitted, this defaults to calling [Comparable.compareTo] on
/// the objects. If any object is not [Comparable], this throws a [TypeError]
/// (`CastError` on some SDK versions).
///
/// Returns [sortedList.length] if all the items in [sortedList] compare less
/// than [value].
int lowerBound<T>(List<T> sortedList, T value, {int Function(T, T) compare}) {
  compare ??= defaultCompare<T>();
  var min = 0;
  var max = sortedList.length;
  while (min < max) {
    var mid = min + ((max - min) >> 1);
    var element = sortedList[mid];
    var comp = compare(element, value);
    if (comp < 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return min;
}

/// Shuffles a list randomly.
///
/// A sub-range of a list can be shuffled by providing [start] and [end].
void shuffle(List list, [int start = 0, int end]) {
  var random = math.Random();
  end ??= list.length;
  var length = end - start;
  while (length > 1) {
    var pos = random.nextInt(length);
    length--;
    var tmp1 = list[start + pos];
    list[start + pos] = list[start + length];
    list[start + length] = tmp1;
  }
}

/// Reverses a list, or a part of a list, in-place.
void reverse(List list, [int start = 0, int end]) {
  end ??= list.length;
  _reverse(list, start, end);
}

/// Internal helper function that assumes valid arguments.
void _reverse(List list, int start, int end) {
  for (var i = start, j = end - 1; i < j; i++, j--) {
    var tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}

/// Sort a list between [start] (inclusive) and [end] (exclusive) using
/// insertion sort.
///
/// If [compare] is omitted, this defaults to calling [Comparable.compareTo] on
/// the objects. If any object is not [Comparable], this throws a [TypeError]
/// (`CastError` on some SDK versions).
///
/// Insertion sort is a simple sorting algorithm. For `n` elements it does on
/// the order of `n * log(n)` comparisons but up to `n` squared moves. The
/// sorting is performed in-place, without using extra memory.
///
/// For short lists the many moves have less impact than the simple algorithm,
/// and it is often the favored sorting algorithm for short lists.
///
/// This insertion sort is stable: Equal elements end up in the same order
/// as they started in.
void insertionSort<T>(List<T> list,
    {int Function(T, T) compare, int start = 0, int end}) {
  // If the same method could have both positional and named optional
  // parameters, this should be (list, [start, end], {compare}).
  compare ??= defaultCompare<T>();
  end ??= list.length;

  for (var pos = start + 1; pos < end; pos++) {
    var min = start;
    var max = pos;
    var element = list[pos];
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      var comparison = compare(element, list[mid]);
      if (comparison < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    list.setRange(min + 1, pos + 1, list, min);
    list[min] = element;
  }
}

/// Limit below which merge sort defaults to insertion sort.
const int _MERGE_SORT_LIMIT = 32;

/// Sorts a list between [start] (inclusive) and [end] (exclusive) using the
/// merge sort algorithm.
///
/// If [compare] is omitted, this defaults to calling [Comparable.compareTo] on
/// the objects. If any object is not [Comparable], this throws a [TypeError]
/// (`CastError` on some SDK versions).
///
/// Merge-sorting works by splitting the job into two parts, sorting each
/// recursively, and then merging the two sorted parts.
///
/// This takes on the order of `n * log(n)` comparisons and moves to sort
/// `n` elements, but requires extra space of about the same size as the list
/// being sorted.
///
/// This merge sort is stable: Equal elements end up in the same order
/// as they started in.
void mergeSort<T>(List<T> list,
    {int start = 0, int end, int Function(T, T) compare}) {
  end ??= list.length;
  compare ??= defaultCompare<T>();

  var length = end - start;
  if (length < 2) return;
  if (length < _MERGE_SORT_LIMIT) {
    insertionSort(list, compare: compare, start: start, end: end);
    return;
  }
  // Special case the first split instead of directly calling
  // _mergeSort, because the _mergeSort requires its target to
  // be different from its source, and it requires extra space
  // of the same size as the list to sort.
  // This split allows us to have only half as much extra space,
  // and it ends up in the original place.
  var middle = start + ((end - start) >> 1);
  var firstLength = middle - start;
  var secondLength = end - middle;
  // secondLength is always the same as firstLength, or one greater.
  var scratchSpace = List<T>(secondLength);
  _mergeSort(list, compare, middle, end, scratchSpace, 0);
  var firstTarget = end - firstLength;
  _mergeSort(list, compare, start, middle, list, firstTarget);
  _merge(compare, list, firstTarget, end, scratchSpace, 0, secondLength, list,
      start);
}

/// Performs an insertion sort into a potentially different list than the
/// one containing the original values.
///
/// It will work in-place as well.
void _movingInsertionSort<T>(List<T> list, int Function(T, T) compare,
    int start, int end, List<T> target, int targetOffset) {
  var length = end - start;
  if (length == 0) return;
  target[targetOffset] = list[start];
  for (var i = 1; i < length; i++) {
    var element = list[start + i];
    var min = targetOffset;
    var max = targetOffset + i;
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      if (compare(element, target[mid]) < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    target.setRange(min + 1, targetOffset + i + 1, target, min);
    target[min] = element;
  }
}

/// Sorts [list] from [start] to [end] into [target] at [targetOffset].
///
/// The `target` list must be able to contain the range from `start` to `end`
/// after `targetOffset`.
///
/// Allows target to be the same list as [list], as long as it's not
/// overlapping the `start..end` range.
void _mergeSort<T>(List<T> list, int Function(T, T) compare, int start, int end,
    List<T> target, int targetOffset) {
  var length = end - start;
  if (length < _MERGE_SORT_LIMIT) {
    _movingInsertionSort(list, compare, start, end, target, targetOffset);
    return;
  }
  var middle = start + (length >> 1);
  var firstLength = middle - start;
  var secondLength = end - middle;
  // Here secondLength >= firstLength (differs by at most one).
  var targetMiddle = targetOffset + firstLength;
  // Sort the second half into the end of the target area.
  _mergeSort(list, compare, middle, end, target, targetMiddle);
  // Sort the first half into the end of the source area.
  _mergeSort(list, compare, start, middle, list, middle);
  // Merge the two parts into the target area.
  _merge(compare, list, middle, middle + firstLength, target, targetMiddle,
      targetMiddle + secondLength, target, targetOffset);
}

/// Merges two lists into a target list.
///
/// One of the input lists may be positioned at the end of the target
/// list.
///
/// For equal object, elements from [firstList] are always preferred.
/// This allows the merge to be stable if the first list contains elements
/// that started out earlier than the ones in [secondList]
void _merge<T>(
    int Function(T, T) compare,
    List<T> firstList,
    int firstStart,
    int firstEnd,
    List<T> secondList,
    int secondStart,
    int secondEnd,
    List<T> target,
    int targetOffset) {
  // No empty lists reaches here.
  assert(firstStart < firstEnd);
  assert(secondStart < secondEnd);
  var cursor1 = firstStart;
  var cursor2 = secondStart;
  var firstElement = firstList[cursor1++];
  var secondElement = secondList[cursor2++];
  while (true) {
    if (compare(firstElement, secondElement) <= 0) {
      target[targetOffset++] = firstElement;
      if (cursor1 == firstEnd) break; // Flushing second list after loop.
      firstElement = firstList[cursor1++];
    } else {
      target[targetOffset++] = secondElement;
      if (cursor2 != secondEnd) {
        secondElement = secondList[cursor2++];
        continue;
      }
      // Second list empties first. Flushing first list here.
      target[targetOffset++] = firstElement;
      target.setRange(targetOffset, targetOffset + (firstEnd - cursor1),
          firstList, cursor1);
      return;
    }
  }
  // First list empties first. Reached by break above.
  target[targetOffset++] = secondElement;
  target.setRange(
      targetOffset, targetOffset + (secondEnd - cursor2), secondList, cursor2);
}
