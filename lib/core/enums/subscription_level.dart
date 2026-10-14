enum SubscriptionLevel {
  level1('SUBSCRIPTION_LEVEL_1'),
  level2('SUBSCRIPTION_LEVEL_2'),
  level3('SUBSCRIPTION_LEVEL_3');

  final String value;
  const SubscriptionLevel(this.value);

  static SubscriptionLevel? fromValue(String? value) {
    if (value == null) return null;
    for (final level in SubscriptionLevel.values) {
      if (level.value == value) return level;
    }
    return null;
  }
}
