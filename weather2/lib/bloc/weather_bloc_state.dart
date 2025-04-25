part of 'weather_bloc_bloc.dart';

sealed class WeatherBlocState extends Equatable {
  const WeatherBlocState();
  
  @override
  List<Object> get props => [];
}

final class WeatherBlocInitial extends WeatherBlocState {}

final class WeatherBlocloading extends WeatherBlocState {}
final class WeatherBlocfail extends WeatherBlocState {}
final class WeatherBlocsuccess extends WeatherBlocState {
  final Weather weather;
  const WeatherBlocsuccess (this.weather);
  @override
  List<Object> get props => [weather];

}
