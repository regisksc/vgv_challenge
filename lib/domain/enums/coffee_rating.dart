enum CoffeeRating {
  unrated,
  oneStar,
  twoStars,
  threeStars,
  fourStars,
  fiveStars,
}

extension RateConverter on CoffeeRating {
  int get intValue => index;
}
