enum Food {
  veggie('veggie', 'Veggie'),
  meat('meat', 'Fleisch'),
  sausage('sausage', 'Wurst'),
  all('all', 'Fleisch und Wurst');

  final String value;
  final String description;

  const Food(this.value, this.description);
}
