enum Task {
  cutting('cutting', 'Schnibbeln'),
  cleanup('cleanup', 'Aufräumen'),
  shopping('shopping', 'Einkaufen'),
  grilling('grilling', 'Grillen');

  final String value;
  final String description;

  const Task(this.value, this.description);

}
