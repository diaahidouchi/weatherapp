import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather2/bloc/weather_bloc_bloc.dart';
import 'package:weather_icons/weather_icons.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});
  
  @override
  State<Homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return const Icon(WeatherIcons.thunderstorm, size: 50, color: Colors.white);
      case >= 300 && < 400:
        return const Icon(WeatherIcons.showers, size: 50, color: Colors.white);
      case >= 500 && < 600:
        return const Icon(WeatherIcons.rain, size: 50, color: Colors.white);
      case >= 600 && < 700:
        return const Icon(WeatherIcons.snow, size: 50, color: Colors.white);
      case >= 700 && < 800:
        return const Icon(WeatherIcons.fog, size: 50, color: Colors.white);
      case == 800:
        return const Icon(WeatherIcons.day_sunny, size: 50, color: Colors.white);
      case > 800 && <= 804:
        return const Icon(WeatherIcons.cloudy, size: 50, color: Colors.white);
      default:
        return const Icon(WeatherIcons.cloudy, size: 50, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1D1F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<WeatherBlocBloc>().add(
                RefreshWeather(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
        builder: (context, state) {
          if (state is WeatherBlocsuccess) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2E3339),
                    const Color(0xFF1B1D1F),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 1.2 * kToolbarHeight, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isSearching)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search city...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _isSearching = false;
                                    _searchController.clear();
                                  });
                                },
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                context.read<WeatherBlocBloc>().add(
                                  SearchWeather(value),
                                );
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            state.weather.areaName ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: Center(
                                child: Icon(
                                  _getCurrentWeatherIcon(state.weather.weatherConditionCode!),
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${state.weather.temperature!.celsius!.round()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Text(
                              state.weather.weatherMain?.toUpperCase() ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, d MMMM').format(state.weather.date!),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _WeatherInfoItem(
                                  icon: WeatherIcons.thermometer,
                                  label: 'Max Temp',
                                  value: '${state.weather.tempMax?.celsius?.round() ?? 0}°',
                                ),
                                _WeatherInfoItem(
                                  icon: WeatherIcons.thermometer,
                                  label: 'Min Temp',
                                  value: '${state.weather.tempMin?.celsius?.round() ?? 0}°',
                                ),
                                _WeatherInfoItem(
                                  icon: WeatherIcons.thermometer,
                                  label: 'Feels like',
                                  value: '${state.weather.tempFeelsLike?.celsius?.round() ?? 0}°',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _WeatherInfoItem(
                                  icon: WeatherIcons.sunrise,
                                  label: 'Sunrise',
                                  value: DateFormat('HH:mm').format(state.weather.sunrise!),
                                ),
                                _WeatherInfoItem(
                                  icon: WeatherIcons.sunset,
                                  label: 'Sunset',
                                  value: DateFormat('HH:mm').format(state.weather.sunset!),
                                ),
                                _WeatherInfoItem(
                                  icon: WeatherIcons.strong_wind,
                                  label: 'Wind',
                                  value: '${state.weather.windSpeed?.round() ?? 0} km/h',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '5-Day Forecast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  final date = DateTime.now().add(Duration(days: index + 1));
                                  return Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('E').format(date),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Center(
                                            child: Icon(
                                              _getForecastIcon(state.weather.weatherConditionCode!, index),
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${state.weather.temperature!.celsius!.round() + (index * 2)}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is WeatherBlocloading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  IconData _getForecastIcon(int code, int index) {
    // Simulate different weather conditions for each day based on current weather
    final modifiedCode = _getModifiedWeatherCode(code, index);
    
    switch (modifiedCode) {
      case >= 200 && < 300:
        return WeatherIcons.thunderstorm;
      case >= 300 && < 400:
        return WeatherIcons.showers;
      case >= 500 && < 600:
        return WeatherIcons.rain;
      case >= 600 && < 700:
        return WeatherIcons.snow;
      case >= 700 && < 800:
        return WeatherIcons.fog;
      case == 800:
        return WeatherIcons.day_sunny;
      case > 800 && <= 804:
        return WeatherIcons.cloudy;
      default:
        return WeatherIcons.cloudy;
    }
  }

  int _getModifiedWeatherCode(int currentCode, int dayIndex) {
    // Base the forecast on current weather with some variation
    final random = (dayIndex * 13) % 100; // Simple pseudo-random number based on day index
    
    if (currentCode == 800) { // Clear sky
      if (random < 30) return 801; // Partly cloudy
      if (random < 50) return 802; // Scattered clouds
      return 800; // Stay clear
    }
    
    if (currentCode > 800) { // Cloudy
      if (random < 20) return 800; // Clear up
      if (random < 40) return currentCode - 1; // Less cloudy
      if (random < 60) return currentCode + 1; // More cloudy
      return currentCode; // Stay similar
    }
    
    if (currentCode >= 500 && currentCode < 600) { // Rain
      if (random < 20) return 800; // Clear up
      if (random < 40) return 300 + (random % 100); // Light rain
      if (random < 60) return 500 + (random % 100); // Heavy rain
      return currentCode; // Stay similar
    }
    
    if (currentCode >= 600 && currentCode < 700) { // Snow
      if (random < 20) return 800; // Clear up
      if (random < 40) return 600 + (random % 100); // Different snow
      return currentCode; // Stay similar
    }
    
    if (currentCode >= 200 && currentCode < 300) { // Thunderstorm
      if (random < 30) return 500 + (random % 100); // Turn to rain
      if (random < 50) return 800; // Clear up
      return currentCode; // Stay similar
    }
    
    return currentCode; // Default to current weather
  }

  IconData _getCurrentWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return WeatherIcons.thunderstorm;
      case >= 300 && < 400:
        return WeatherIcons.showers;
      case >= 500 && < 600:
        return WeatherIcons.rain;
      case >= 600 && < 700:
        return WeatherIcons.snow;
      case >= 700 && < 800:
        return WeatherIcons.fog;
      case == 800:
        return WeatherIcons.day_sunny;
      case > 800 && <= 804:
        return WeatherIcons.cloudy;
      default:
        return WeatherIcons.cloudy;
    }
  }
}

class _WeatherInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}