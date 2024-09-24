import 'dart:async';

Future<void> cooldown(int remainingTime, final key, final invoiceDataService) async {

  Timer.periodic(const Duration(seconds: 1), (final t) async {
    remainingTime += 1;

    if (remainingTime >= 30) {
      remainingTime = 0;
      t.cancel();
    }
    await invoiceDataService.remainingTimeBox.put(key, remainingTime);
  });

}
