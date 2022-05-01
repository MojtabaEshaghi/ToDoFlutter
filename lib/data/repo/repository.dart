import 'package:flutter/cupertino.dart';
import 'package:todo_list/data/source/source.dart';

class Repository<T> with ChangeNotifier implements DataSource {
  final DataSource<T> localDataSource;

  Repository(this.localDataSource);

  @override
  Future createOrUpdate(data) async {
    final T createData = await localDataSource.createOrUpdate(data);
    notifyListeners();
    return createData;
  }

  @override
  Future<void> delete(data) async {
    localDataSource.delete(data);
    notifyListeners();
  }

  @override
  Future<void> deleteAll() async {
    await localDataSource.deleteAll();
    notifyListeners();
  }

  @override
  Future<void> deleteByTask(id) async {
    localDataSource.deleteByTask(id);
    notifyListeners();
  }

  @override
  Future<T> findById({id}) async {
    final T result = await localDataSource.findById(id: id);
    notifyListeners();
    return result;
  }

  @override
  Future<List<T>> getAll({String searchKeyword = ''}) async {
    return await localDataSource.getAll(searchKeyword: searchKeyword);
  }
}
