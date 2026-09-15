class WebPlacePrediction {
  final String description;
  final String placeId;

  const WebPlacePrediction({
    required this.description,
    required this.placeId,
  });
}

class WebPlaceDetails {
  final String formattedAddress;
  final double latitude;
  final double longitude;

  const WebPlaceDetails({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });
}

Future<List<WebPlacePrediction>> getWebPlacePredictions({
  required String input,
  String countryCode = 'eg',
}) async {
  return const [];
}

Future<WebPlaceDetails?> getWebPlaceDetails({
  required String placeId,
}) async {
  return null;
}
