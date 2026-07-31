import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/repositories/providers.dart';

/// Public reviews only — approved + real. Never seeded / never invented.
///
/// When Firebase is enabled, loads dynamically from Firestore.
/// When disabled, uses in-memory store (starts empty).
final publicReviewsProvider = StreamProvider<List<Review>>((ref) {
  if (AppConstants.useFirebase) {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Review.fromMap(d.id, d.data()))
              .where((r) => r.isPublic)
              .toList(growable: false),
        );
  }

  final store = ref.watch(sessionStoreProvider);
  return Stream<List<Review>>.value(store.publicReviews);
});
