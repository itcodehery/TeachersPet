import 'package:dartz/dartz.dart';
import 'package:minty/core/error/failures.dart';
import 'package:minty/features/home/domain/entities/home.dart';
import 'package:minty/features/home/domain/repositories/home_repository.dart';

class GetHome {
  final HomeRepository repository;

  GetHome(this.repository);

  Future<Either<Failure, Home>> call() async {
    return await repository.getHome();
  }
}
