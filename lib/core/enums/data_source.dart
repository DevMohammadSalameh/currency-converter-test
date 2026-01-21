/// Indicates the source of data - whether it was fetched from API or loaded from local database
enum DataSource {
  /// Data was fetched from remote API
  api,

  /// Data was loaded from local database cache
  cache,
}
