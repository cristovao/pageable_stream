import 'dart:async';

// Developed by Cristovao Wollieson (cristovao.wollieson@gmail.com)
// MIT License

/// Information cache with size and position
final class StreamCachedList<T> {
  /// Class constructor
  StreamCachedList({
    required List<T> items,
    required int length,
    required int position,
  }) : _items = List.unmodifiable(items),
       _length = length,
       _position = position;

  final List<T> _items;
  final int _length;
  final int _position;

  /// Returns the list of items
  List<T> get items => _items;

  /// Returns the list size
  int get length => _length;

  /// Returns the current position
  int get position => _position;

  /// Checks if the list has more items
  bool get hasMore => _position + _length < _items.length;
}

/// OnRefreshCallback é um callback que é chamado quando a lista precisa ser
/// atualizada.
typedef OnRefreshCallback<T> =
    Future<StreamCachedList<T>> Function(int offset, int position);

/// PageableStream é uma classe que representa uma lista paginável.
/// Ela é usada para armazenar uma lista de itens e fornecer métodos para
/// navegar pela lista.
class PageableStream<E> extends Stream<E> {
  /// Construtor da classe.
  PageableStream({required int offset, required OnRefreshCallback<E> onRefresh})
    : _offset = offset,
      _onRefresh = onRefresh;

  final OnRefreshCallback<E> _onRefresh;
  final int _offset;

  @override
  StreamSubscription<E> listen(
    void Function(E event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final controller = StreamController<E>();
    var isFirstLoad = true;
    var position = 0;
    var length = 0;
    var items = <E>[];
    var currentPage = -1;

    Future<void> loadPage() async {
      if (position < 0 || _offset == 0 || (position >= length && length > 0)) {
        return;
      }

      final page = (position / _offset).floor();
      if (page == currentPage && items.isNotEmpty) {
        return;
      }

      try {
        final cached = await _onRefresh(_offset, position);
        items = cached.items;
        length = cached.length;
        position = cached.position;
        currentPage = page;
      } on Exception catch (e, s) {
        controller.addError(e, s);
        if (cancelOnError ?? false) {
          await controller.close();
        }
      }
    }

    Future<void> processNext() async {
      if (isFirstLoad) {
        isFirstLoad = false;
      } else if (position >= length) {
        await controller.close();
        return;
      }

      await loadPage();

      if (items.isEmpty) {
        await controller.close();
        return;
      }

      controller.add(items[position % _offset]);
      position++;

      if (!controller.isClosed) {
        await processNext();
      }
    }

    controller
      ..onListen = () async {
        await processNext();
      }
      ..onCancel = () async {
        items = [];
        length = 0;
        position = 0;
        currentPage = -1;
      };

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns the first element.
  @override
  Future<E> get first async {
    final cached = await _onRefresh(_offset, 0);
    if (cached.items.isEmpty) {
      throw StateError('No elements');
    }
    return cached.items.first;
  }

  /// Returns the last element.
  @override
  Future<E> get last async {
    var position = 0;
    var length = 0;

    final firstPage = await _onRefresh(_offset, 0);
    length = firstPage.length;

    if (length == 0) {
      throw StateError('No elements');
    }

    position = length - 1;
    final lastPage = await _onRefresh(_offset, position);
    return lastPage.items.last;
  }

  /// Returns the length of the stream.
  @override
  Future<int> get length async {
    final cached = await _onRefresh(_offset, 0);
    return cached.length;
  }

  /// Returns whether the stream is empty.
  @override
  Future<bool> get isEmpty async => await length == 0;

  /// Returns whether the stream is not empty.
  Future<bool> get isNotEmpty async => !await isEmpty;

  /// Returns the element at the given index.
  Future<E> operator [](int index) async {
    final cached = await _onRefresh(_offset, index);
    if (index >= cached.length) {
      throw RangeError.index(index, this, 'index', null, cached.length);
    }
    return cached.items[index % _offset];
  }
}
