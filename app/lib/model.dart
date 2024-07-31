class GestureMacro {
  GestureMacro({
    required this.title,
    required this.binding,
    required this.selectedGesture,
  });

  String title;
  List<Map<String, dynamic>> binding;
  Gesture selectedGesture;
}

class Gesture {
  Gesture({
    required this.name,
    required this.values,
  });

  final String name;
  final Map<String, double> values;

  bool isActive(Map<String, double> blendshapes) {
    bool active = true;
    values.forEach((k, v) {
      if (blendshapes[k]! < v) {
        active = false;
      }
    });
    return active;
  }
}

// class ChartData {
//   ChartData({
//     required this.x,
//     required this.y,
//   });

//   final String x;
//   final String y;
// }