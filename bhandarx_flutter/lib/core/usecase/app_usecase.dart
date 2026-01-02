import 'package:dartz/dartz.dart';
import '../error/failures.dart';

// Info: For use case with parameter
abstract interface class UseCaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

// Info: For use case without parameter
abstract interface class UseCaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}


// import 'package:vedaverse/core/error/failures.dart';
