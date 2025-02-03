import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:vgv_challenge/domain/domain.dart';

class Coffee extends Equatable {
  const Coffee({
    required this.id,
    required this.imagePath,
    required this.seenAt,
    this.isFavorite = false,
    this.comment,
    this.rating = CoffeeRating.unrated,
  });

  final String id;
  final String imagePath;
  final DateTime seenAt;

  final bool isFavorite;
  final String? comment;
  final CoffeeRating rating;

  File get asFile => File(imagePath);

  @override
  List<Object?> get props => [id, imagePath];
}
