import 'package:flutter_test/flutter_test.dart';
import 'package:happy_view/services/pixabay_services.dart';

void main() {
  test('PixabayService tracks request count for debugging', () {
    PixabayService.resetRequestCounter();
    expect(PixabayService.requestCount, 0);

    PixabayService.incrementRequestCount();
    expect(PixabayService.requestCount, 1);

    PixabayService.resetRequestCounter();
    expect(PixabayService.requestCount, 0);
  });
}
