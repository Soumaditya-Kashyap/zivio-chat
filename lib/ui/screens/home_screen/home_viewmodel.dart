import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';


class HomeViewmodel extends BaseViewModel {
  final DatabaseService _db;

  HomeViewmodel(this._db);

}
