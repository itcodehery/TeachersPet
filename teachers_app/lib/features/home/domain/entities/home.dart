import 'package:equatable/equatable.dart';

class Home extends Equatable {
  final String id;
  final String name;

  const Home({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];
}
