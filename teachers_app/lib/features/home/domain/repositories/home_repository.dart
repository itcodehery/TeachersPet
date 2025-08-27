import 'package:dartz/dartz.dart';
import 'package:teachers_app/core/error/failures.dart';
import 'package:teachers_app/features/home/domain/entities/home.dart';

abstract class HomeRepository {
  Future<Either<Failure, Home>> getHome();
}
