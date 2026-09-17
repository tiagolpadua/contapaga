/// Small application preferences only. Financial data needs typed repositories.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> close();
}
