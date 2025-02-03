import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:vgv_challenge/domain/domain.dart';

class CoffeeModel extends Equatable {
  const CoffeeModel({
    required this.id,
    required this.file,
    required this.seenAt,
    this.isFavorite = false,
    this.comment,
    this.rating = 0,
  });

  factory CoffeeModel.fromEntity(Coffee coffee) => CoffeeModel(
        id: coffee.id,
        file: coffee.imagePath,
        seenAt: coffee.seenAt,
        isFavorite: coffee.isFavorite,
        comment: coffee.comment,
        rating: coffee.rating.intValue,
      );

  factory CoffeeModel.fromJson(Map<String, dynamic> json) {
    final isLocal = json.containsKey('id');

    final seenAt = json['seenAt'] as String?;
    final now = DateTime.now().toUtc().toString();
    final ratingCheck = json['rating'] != null && json['rating'] is int;
    final dateTimeFromData = DateTime.parse(seenAt ?? now);
    return CoffeeModel(
      id: isLocal ? json['id'] as String : const Uuid().v4(),
      file: json['file'] as String,
      seenAt: isLocal ? dateTimeFromData : DateTime.now().toUtc(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      comment: json['comment'] as String?,
      rating: ratingCheck ? json['rating'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'file': file,
        'seenAt': seenAt.toIso8601String(),
        'isFavorite': isFavorite,
        'comment': comment,
        'rating': rating,
      };

  Coffee get asEntity => Coffee(
        id: id,
        imagePath: file,
        seenAt: seenAt,
        isFavorite: isFavorite,
        comment: comment,
        rating: CoffeeRating.values[rating],
      );

  CoffeeModel copyWith({
    String? id,
    String? file,
    DateTime? seenAt,
    bool? isFavorite,
    String? comment,
    int? rating,
  }) {
    return CoffeeModel(
      id: id ?? this.id,
      file: file ?? this.file,
      seenAt: seenAt ?? this.seenAt,
      isFavorite: isFavorite ?? this.isFavorite,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
    );
  }

  final String id;
  final String file;
  final DateTime seenAt;
  final bool isFavorite;
  final String? comment;
  final int rating;

  @override
  List<Object?> get props => [
        id,
        file,
        seenAt,
        isFavorite,
        comment,
        rating,
      ];
}

extension CoffeeModelListExtension on List<CoffeeModel> {
  List<Coffee> get asEntities => map((model) => model.asEntity).toList();
}
