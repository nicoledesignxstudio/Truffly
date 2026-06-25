import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_notifier.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';

PublishTruffleImageDraft _image(String name) {
  return PublishTruffleImageDraft(
    localPath: '/tmp/$name.jpg',
    fileName: name,
    contentType: 'image/jpeg',
    byteCount: 1024,
  );
}

void main() {
  test(
    'reordering images updates the draft order and keeps the first photo as cover',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(publishTruffleNotifierProvider.notifier);
      notifier.addImages([
        _image('a'),
        _image('b'),
        _image('c'),
      ]);

      notifier.reorderImages(0, 2);

      final state = container.read(publishTruffleNotifierProvider);
      expect(
        state.images.map((image) => image.fileName),
        ['b', 'c', 'a'],
      );
      expect(state.images.first.fileName, 'b');
    },
  );
}
