# PageableStream Example

This example demonstrates how to use the `pageable_stream` package to handle paginated data streams in Dart.

## Overview

The `pageable_stream` package provides a convenient way to work with paginated data as a Dart Stream. This is particularly useful when:
- Loading large datasets in chunks
- Implementing infinite scrolling
- Working with paginated APIs

## Running the Example

1. Make sure you're in the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Run the example:
   ```bash
   dart run example.dart
   ```

## Code Example

```dart
import 'package:pageable_stream/pageable_stream.dart';

void main() async {
  // Create a pageable stream that loads 10 numbers at a time
  final pageableStream = PageableStream<int>(
    offset: 10,  // Page size of 10
    onRefresh: (offset, position) async {
      // Simulate fetching data from a source
      await Future.delayed(Duration(milliseconds: 100));
      
      final items = List.generate(offset, (i) => position + i);
      
      return StreamCachedList(
        items: items,
        length: 100,  // Total items available
        position: position,
      );
    },
  );

  // Listen to the stream
  await for (final number in pageableStream) {
    print('Number: $number');
    // Process each number as it comes
  }
}
```

## Key Features

1. **Automatic Pagination**: The stream automatically handles loading the next page when needed.

2. **Cached Data**: Uses `StreamCachedList` to efficiently cache and manage loaded data.

3. **Stream Interface**: Works with all standard Dart Stream features:
   ```dart
   // Get first item
   final first = await pageableStream.first;
   
   // Get last item
   final last = await pageableStream.last;
   
   // Get total length
   final total = await pageableStream.length;
   ```

4. **Error Handling**: Built-in error handling with standard Stream error propagation.

## Real-world Usage

In a real application, you might use this to load data from an API:

```dart
final userStream = PageableStream<User>(
  offset: 20,  // Load 20 users at a time
  onRefresh: (offset, position) async {
    // Fetch users from API
    final response = await http.get(
      Uri.parse('/api/users?offset=$position&limit=$offset')
    );
    
    final data = json.decode(response.body);
    
    return StreamCachedList(
      items: data['users'].map((u) => User.fromJson(u)).toList(),
      length: data['total'],
      position: position,
    );
  },
);
```

## Additional Resources

- [Package Documentation](https://github.com/cristovao/pageable_stream)
- [API Reference](https://pub.dev/documentation/pageable_stream)
- [Source Code](https://github.com/cristovao/pageable_stream)
