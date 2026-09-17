enum AppEnvironment {
  development,
  production;

  static AppEnvironment fromName(String name) => switch (name) {
    'development' => development,
    'production' => production,
    _ => throw ArgumentError.value(name, 'APP_ENV', 'Ambiente desconhecido'),
  };

  String get databaseName => switch (this) {
    development => 'contapaga_development.db',
    production => 'contapaga.db',
  };
}
