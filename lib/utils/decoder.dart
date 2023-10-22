import 'package:mapbox_gl/mapbox_gl.dart';

List<LatLng> decodeLine(String polyline) {
  List<LatLng> points = <LatLng>[];
  List<int> byteArray = polyline.codeUnits;
  int index = 0;
  int lat = 0;
  int lng = 0;
  while (index < byteArray.length) {
    int b;
    int shift = 0;
    int result = 0;
    do {
      b = byteArray[index++] - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = byteArray[index++] - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}
