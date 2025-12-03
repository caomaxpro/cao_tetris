import 'dart:ui';

class TileData {
  final Color color;
  // ...other fields...

  TileData({required this.color});

  // Convert TileData to string (ví dụ dùng mã màu hex)
  String toShortString() {
    return color.value.toRadixString(16); // VD: 'ff0000ff'
  }

  // Nếu cần parse lại từ string
  static TileData? fromShortString(String s) {
    if (s == '.') return null;
    return TileData(color: Color(int.parse(s, radix: 16)));
  }
}

// Convert playfieldMatrix to string
String playfieldMatrixToString(List<List<TileData?>> matrix) {
  return matrix
      .map(
        (row) => row
            .map((cell) => cell == null ? '.' : cell.toShortString())
            .join(','),
      )
      .join('\n');
}

// Convert string về lại matrix
List<List<TileData?>> playfieldMatrixFromString(String str) {
  return str
      .split('\n')
      .map(
        (row) => row
            .split(',')
            .map((cellStr) => TileData.fromShortString(cellStr))
            .toList(),
      )
      .toList();
}
