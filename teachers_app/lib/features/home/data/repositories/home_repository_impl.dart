import 'package:dartz/dartz.dart';
import 'package:minty/core/error/failures.dart';
import 'package:minty/features/home/data/datasources/home_datasource.dart';
import 'package:minty/features/home/domain/entities/home.dart';
import 'package:minty/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource datasource;

  HomeRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, Home>> getHome() async {
    try {
      final result = await datasource.getHome();
      return Right(result.toEntity());
    } on Exception {
      return Left(ServerFailure(message: "Something went wrong!"));
    }
  }
}
