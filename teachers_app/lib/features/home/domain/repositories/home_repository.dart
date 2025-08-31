import 'package:dartz/dartz.dart';
import 'package:minty/core/error/failures.dart';
import 'package:minty/features/home/domain/entities/home.dart';

abstract class HomeRepository {
  Future<Either<Failure, Home>> getHome();
}
