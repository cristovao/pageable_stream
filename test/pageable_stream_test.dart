import 'package:pageable_stream/pageable_stream.dart';
import 'package:test/test.dart';

// Developed by Cristovao Wollieson (cristovao.wollieson@gmail.com)
// MIT License

void main() {
  test('PageableStream basic operations', () async {
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

    // Test basic properties
    expect(await pageableStream.length, 10);
    expect(await pageableStream.first, 1);
    expect(await pageableStream.last, 10);
    expect(await pageableStream.isEmpty, false);

    // Test stream iteration
    final items = await pageableStream.toList();
    expect(items, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    // Test random access
    expect(await pageableStream[0], 1);
    expect(await pageableStream[4], 5);
    expect(await pageableStream[9], 10);
  });
  test('PageableStream basic iterate for', () async {
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

    // Test stream iteration
    final items = <int>[];
    await for (final item in pageableStream) {
      items.add(item);
    }
    expect(items, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  });

  test('PageableStream empty list', () async {
    final pageableStream = PageableStream<int>(
      offset: 5,
      onRefresh: (offset, position) async {
        await Future<void>.delayed(
          const Duration(milliseconds: 10),
        ); // Simulate network delay
        return StreamCachedList<int>(items: [], length: 0, position: position);
      },
    );

    expect(await pageableStream.isEmpty, true);
    expect(await pageableStream.length, 0);

    final items = await pageableStream.toList();
    expect(items, isEmpty);
  });

  test('PageableStream pagination', () async {
    final pageableStream = PageableStream<int>(
      offset: 3,
      onRefresh: (offset, position) async {
        await Future<void>.delayed(
          const Duration(milliseconds: 10),
        ); // Simulate network delay
        final start = position;
        final items = List.generate(
          3,
          (i) => start + i + 1,
        ).where((i) => i <= 9).toList();
        return StreamCachedList<int>(
          items: items,
          length: 9,
          position: position,
        );
      },
    );

    expect(await pageableStream.length, 9);

    final items = await pageableStream.toList();
    expect(items, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  });

  test('PageableStream error handling', () async {
    final pageableStream = PageableStream<int>(
      offset: 5,
      onRefresh: (offset, position) async {
        await Future<void>.delayed(
          const Duration(milliseconds: 10),
        ); // Simulate network delay
        if (position > 4) {
          throw Exception('Failed to load page');
        }
        return StreamCachedList<int>(
          items: [1, 2, 3, 4, 5],
          length: 10,
          position: position,
        );
      },
    );

    expect(
      pageableStream.toList,
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load page'),
        ),
      ),
    );
  });
}
