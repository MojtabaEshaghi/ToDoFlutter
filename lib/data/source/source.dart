abstract class DataSource<T> {
  Future<List<T>> getAll({String searchKeyword});

  Future<T> findById({dynamic id});

  Future<void> deleteAll();

  Future<void> deleteByTask(dynamic id);

  Future<void> delete(T data);

  Future<T> createOrUpdate(T data);
}
