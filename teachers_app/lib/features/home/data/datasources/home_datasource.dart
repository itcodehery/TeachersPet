import 'package:minty/features/home/data/models/home_model.dart';

abstract class HomeDatasource {
  Future<HomeModel> getHome();
}

class HomeDatasourceImpl implements HomeDatasource {
  @override
  Future<HomeModel> getHome() async {
    // TODO: implement actual data source logic
    // This is just a placeholder implementation
    return HomeModel(id: '1', name: 'Home Name');
  }
}
