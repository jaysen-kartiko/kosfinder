abstract class KosRowsSource {
  Future<List<Map<String, dynamic>>> fetchActiveKosRows();

  Future<Map<String, dynamic>?> fetchActiveKosRow(String id);
}
