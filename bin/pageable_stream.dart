import 'package:pageable_stream/pageable_stream.dart';

// Developed by Cristovao Wollieson (cristovao.wollieson@gmail.com)
// MIT License

void main(List<String> arguments) async {
  final pageableStream = PageableStream<int>(
    offset: 5,
    onRefresh: (offset, position) async {
      await Future<void>.delayed(
        const Duration(milliseconds: 10),
      ); // Simulate network delay
      return position > 4
          ? StreamCachedList<int>(
              items: [6, 7, 8, 9, 10],
              length: 10,
              position: position,
            )
          : StreamCachedList<int>(
              items: [1, 2, 3, 4, 5],
              length: 10,
              position: position,
            );
    },
  );

  await for (final i in pageableStream) {
    print(i);
  }
}
