import 'dart:async';
import 'dart:js' as js;

import 'package:google_maps_flutter/google_maps_flutter.dart';

js.JsObject? _mapsNamespace() {
  final google = js.context['google'];
  if (google == null) return null;
  final maps = google['maps'];
  return maps is js.JsObject ? maps : null;
}

double? _coordinate(js.JsObject point, String name) {
  final value = point[name];
  if (value is num) return value.toDouble();

  try {
    final result = point.callMethod(name);
    if (result is num) return result.toDouble();
  } catch (_) {}

  return null;
}

Future<List<LatLng>?> getWebRoutePath({
  required LatLng origin,
  required LatLng destination,
}) async {
  final maps = _mapsNamespace();
  if (maps == null) return null;

  final importLibrary = maps['importLibrary'];
  if (importLibrary == null) return null;

  final completer = Completer<List<LatLng>?>();

  try {
    final libraryPromise = maps.callMethod('importLibrary', ['routes']);
    if (libraryPromise is! js.JsObject) return null;

    libraryPromise.callMethod('then', [
      js.allowInterop((dynamic routesLibrary) {
        try {
          if (routesLibrary is! js.JsObject) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          final routeClass = routesLibrary['Route'];
          if (routeClass is! js.JsObject) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          final request = js.JsObject.jsify({
            'origin': {
              'lat': origin.latitude,
              'lng': origin.longitude,
            },
            'destination': {
              'lat': destination.latitude,
              'lng': destination.longitude,
            },
            'travelMode': 'DRIVING',
            'routingPreference': 'TRAFFIC_AWARE',
            'fields': ['path', 'distanceMeters', 'durationMillis'],
          });

          final computePromise = routeClass.callMethod('computeRoutes', [request]);
          if (computePromise is! js.JsObject) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          computePromise.callMethod('then', [
            js.allowInterop((dynamic response) {
              try {
                if (response is! js.JsObject) {
                  if (!completer.isCompleted) completer.complete(null);
                  return;
                }

                final routes = response['routes'];
                if (routes is! js.JsArray || routes.isEmpty) {
                  if (!completer.isCompleted) completer.complete(null);
                  return;
                }

                final firstRoute = routes.first;
                if (firstRoute is! js.JsObject) {
                  if (!completer.isCompleted) completer.complete(null);
                  return;
                }

                final rawPath = firstRoute['path'];
                if (rawPath is! js.JsArray || rawPath.length < 2) {
                  if (!completer.isCompleted) completer.complete(null);
                  return;
                }

                final points = <LatLng>[];
                for (final rawPoint in rawPath) {
                  if (rawPoint is! js.JsObject) continue;
                  final lat = _coordinate(rawPoint, 'lat');
                  final lng = _coordinate(rawPoint, 'lng');
                  if (lat != null && lng != null) {
                    points.add(LatLng(lat, lng));
                  }
                }

                if (!completer.isCompleted) {
                  completer.complete(points.length >= 2 ? points : null);
                }
              } catch (_) {
                if (!completer.isCompleted) completer.complete(null);
              }
            }),
            js.allowInterop((dynamic _) {
              if (!completer.isCompleted) completer.complete(null);
            }),
          ]);
        } catch (_) {
          if (!completer.isCompleted) completer.complete(null);
        }
      }),
      js.allowInterop((dynamic _) {
        if (!completer.isCompleted) completer.complete(null);
      }),
    ]);
  } catch (_) {
    if (!completer.isCompleted) completer.complete(null);
  }

  return completer.future.timeout(
    const Duration(seconds: 8),
    onTimeout: () => null,
  );
}
