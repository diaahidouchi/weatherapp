import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather2/bloc/weather_bloc_bloc.dart';
import 'package:weather2/screens/homescreen.dart';
import 'package:permission_handler/permission_handler.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Position>(
        future: _determinePosition(),
        builder: (context, snap) {
					if(snap.hasData) {
						return BlocProvider<WeatherBlocBloc>(
							create: (context) => WeatherBlocBloc()..add(
								FetchWeather(snap.data as Position)
							),
							child: const Homescreen(),
						);
					} else {
						return const Scaffold(
							body: Center(
								child: CircularProgressIndicator(),
							),
						);
					}
        }
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    bool opened = await openAppSettings();
    if (!opened) {
      return Future.error(
          'Location permissions are permanently denied. Enable them in settings.');
    }
    return Future.error('Please grant location permissions in settings.');
  }

  return await Geolocator.getCurrentPosition();
}
