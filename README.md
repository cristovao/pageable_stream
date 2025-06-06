# PageableStream

A Dart package that provides an efficient and easy-to-use implementation of paginated streaming. This package is designed to handle large datasets by loading them in chunks (pages) while providing a seamless Stream interface.

## Objective

The main objective of this package is to provide a solution for handling large datasets in Dart applications where loading all data at once would be inefficient or impractical. Common use cases include:

- Loading data from REST APIs with pagination
- Handling large datasets from databases
- Implementing infinite scrolling in UI applications
- Managing memory-efficient data streaming

## Features

- 🔄 Seamless Stream interface integration
- 📦 Efficient pagination with customizable page size
- 🔍 Random access to elements
- ⚡ Async/await support
- 🛡️ Error handling and propagation
- 🧹 Automatic resource cleanup
- 📊 Length and emptiness checks

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pageable_list: ^1.0.0
```

## Usage

### Basic Example

```dart
final pageableStream = PageableStream<int>(
  offset: 5, // Page size of 5 items
  onRefresh: (offset, position) async {
    // Simulate fetching data from an API
    await Future.delayed(Duration(milliseconds: 100));
    
    final start = position;
    final items = List.generate(
      offset,
      (i) => start + i + 1,
    ).where((i) => i <= 20).toList(); // Example with 20 total items
    
    return CachedList<int>(
      items: items,
      length: 20,
      position: position,
    );
  },
);

// Use it as a regular Stream
await for (final item in pageableStream) {
  print(item);
}

// Or use convenience methods
final firstItem = await pageableStream.first;
final lastItem = await pageableStream.last;
final totalLength = await pageableStream.length;
final isEmpty = await pageableStream.isEmpty;
```

### With API Integration

```dart
class UserPageableStream extends PageableStream<User> {
  UserPageableStream({required ApiClient client})
      : super(
          offset: 20,
          onRefresh: (offset, position) async {
            final response = await client.getUsers(
              page: (position / offset).floor(),
              pageSize: offset,
            );
            
            return CachedList<User>(
              items: response.users,
              length: response.totalCount,
              position: position,
            );
          },
        );
}
```

## Error Handling

The PageableStream properly propagates errors that occur during page loading:

```dart
try {
  await for (final item in pageableStream) {
    print(item);
  }
} on Exception catch (e) {
  print('Error loading page: $e');
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
