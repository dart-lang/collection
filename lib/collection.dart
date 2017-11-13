// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(lrn): Move the classes to this package.
export "dart:collection"
    show
        DoubleLinkedQueue,
        DoubleLinkedQueueEntry,
        HasNextIterator,
        LinkedList,
        LinkedListEntry,
        MapView, // TODO(lrn): Drop this class, it is equivalent to DelegatingMap.
        SplayTreeMap,
        SplayTreeSet,
        UnmodifiableListView,
        UnmodifiableMapBase,
        UnmodifiableMapView;

export "src/algorithms.dart";
export "src/canonicalized_map.dart";
export "src/combined_wrappers/combined_iterable.dart";
export "src/combined_wrappers/combined_list.dart";
export "src/combined_wrappers/combined_map.dart";
export "src/comparators.dart";
export "src/equality.dart";
export "src/equality_map.dart";
export "src/equality_set.dart";
export "src/functions.dart";
export "src/iterable_zip.dart";
export "src/priority_queue.dart";
export "src/queue_list.dart";
export "src/union_set.dart";
export "src/union_set_controller.dart";
export "src/unmodifiable_wrappers.dart";
export "src/wrappers.dart";
