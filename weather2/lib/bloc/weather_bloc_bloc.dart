import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather/weather.dart';
import 'package:weather2/data/my_data.dart';

part 'weather_bloc_event.dart';
part 'weather_bloc_state.dart';

class WeatherBlocBloc extends Bloc<WeatherBlocEvent, WeatherBlocState> {
  WeatherBlocBloc() : super(WeatherBlocInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherBlocloading());
      try {
        // 🌍 Reverse Geocode: Convert Lat/Lon to City Name
        List<Placemark> placemarks = await placemarkFromCoordinates(
          event.position.latitude,
          event.position.longitude,
        );
        String cityName = placemarks.isNotEmpty ? placemarks[0].locality ?? "Unknown" : "Unknown";

        // 🌤️ Fetch Weather Using City Name
        WeatherFactory wf = WeatherFactory(API_KEY, language: Language.ENGLISH);
        Weather weather = await wf.currentWeatherByCityName(cityName);

        print("City Detected: $cityName");
        print(weather);

        emit(WeatherBlocsuccess(weather));
      } catch (e) {
        emit(WeatherBlocfail());
      }
    });

    on<RefreshWeather>((event, emit) async {
      if (state is WeatherBlocsuccess) {
        emit(WeatherBlocloading());
        try {
          Position position = await Geolocator.getCurrentPosition();
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          String cityName = placemarks.isNotEmpty ? placemarks[0].locality ?? "Unknown" : "Unknown";

          WeatherFactory wf = WeatherFactory(API_KEY, language: Language.ENGLISH);
          Weather weather = await wf.currentWeatherByCityName(cityName);

          emit(WeatherBlocsuccess(weather));
        } catch (e) {
          emit(WeatherBlocfail());
        }
      }
    });

    on<SearchWeather>((event, emit) async {
      emit(WeatherBlocloading());
      try {
        WeatherFactory wf = WeatherFactory(API_KEY, language: Language.ENGLISH);
        Weather weather = await wf.currentWeatherByCityName(event.cityName);

        emit(WeatherBlocsuccess(weather));
      } catch (e) {
        emit(WeatherBlocfail());
      }
    });
  }
}
