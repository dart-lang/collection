Contains utility functions and classes in the style of `dart:collection` to make
working with collections easier.

## Algorithms

The package contains functions that operate on lists.

It contains ways to shuffle a `List`, do binary search on a sorted `List`, and
various sorting algorithms.

## Equality

The package provides a way to specify the equality of elements and collections.

Collections in Dart have no inherent equality. Two sets are not equal, even
if they contain exactly the same objects as elements.

The `Equality` interface provides a way to define such an equality. In this
case, for example, `const SetEquality(IdentityEquality())` is an equality
that considers two sets equal exactly if they contain identical elements.

Equalities are provided for `Iterable`s, `List`s, `Set`s, and `Map`s, as well as
combinations of these, such as:

```dart
const MapEquality(IdentityEquality(), ListEquality());
```

This equality considers maps equal if they have identical keys, and the
corresponding values are lists with equal (`operator==`) values.

## Iterable Zip

Utilities for "zipping" a list of iterables into an iterable of lists.

## Priority Queue

An interface and implementation of a priority queue.

## Wrappers

The package contains classes that "wrap" a collection.

A wrapper class contains an object of the same type, and it forwards all
methods to the wrapped object.

Wrapper classes can be used in various ways, for example to restrict the type
of an object to that of a supertype, or to change the behavior of selected
functions on an existing object.

## Sort Order

Sort order helpers that make it easier for you to sort `List`s. 

```dart
final list = [1, 3, 2, 4]..sortAsc(); // Results int [1, 2, 3, 4]
final list = [1, 3, 2, 4]..sort((a, b) => sortAsc(a, b)); // Results int [1, 2, 3, 4]

final list = [1, 3, 2, 4]..sortDesc(); // Results in [4, 3, 2, 1]
final list = [1, 3, 2, 4]..sort((a, b) => sortDesc(a, b)); // Results in [4, 3, 2, 1]
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/dart-lang/collection/issues
