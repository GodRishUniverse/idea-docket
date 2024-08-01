enum RepeatChoices {
  doesNotRepeat,
  daily,
  weekly,
  monthly,
  custom,
}

enum EndChoices {
  never,
  onDate,
  after,
}

enum RepeatsEvery {
  day,
  week,
  month,
  year,
}
//TODO: Later: To be edited to accomodate features of custom repetition

class Repetitions {
  RepeatChoices choices = RepeatChoices.doesNotRepeat;
  int? repeatsEveryIntervalNumber = 1;
  RepeatsEvery? repeatsEvery = RepeatsEvery.week;
  EndChoices? endChoices = EndChoices.never;

  Repetitions({
    required this.choices,
    this.repeatsEveryIntervalNumber,
    this.repeatsEvery,
    this.endChoices,
  });
}
