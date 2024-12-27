import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('es', 'ES'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey, // Set primary color to amber
        ),
        appBarTheme: AppBarTheme(
          backgroundColor:  Colors.lightBlue, // Set AppBar color to light blue
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Calculadora de Edad'.tr, textAlign: TextAlign.center),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final controller = Get.find<AgeCalculatorController>();
              controller.reset();
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              if (Get.locale?.languageCode == 'es') {
                Get.updateLocale(const Locale('en', 'US'));
              } else {
                Get.updateLocale(const Locale('es', 'ES'));
              }
              final controller = Get.find<AgeCalculatorController>();
              controller.calculateAge(); // Recalculate to update the message
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Check out this awesome Age Calculator app!');
            },
          ),
        ],
      ),
      body: const AgeCalculator(),
    );
  }
}

class AgeCalculatorController extends GetxController {
  var birthDate = Rxn<DateTime>();
  var age = ''.obs;
  var daysUntilNextBirthday = ''.obs;

  void calculateAge() {
    if (birthDate.value == null) return;

    final now = DateTime.now();
    int years = now.year - birthDate.value!.year;
    int months = now.month - birthDate.value!.month;
    int days = now.day - birthDate.value!.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(now.year, now.month, 0).day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final hours = now.hour - birthDate.value!.hour;

    age.value = '$years ${'años'.tr}, $months ${'meses'.tr}, $days ${'días'.tr}, $hours ${'horas'.tr}';

    // Calculate days until next birthday
    DateTime nextBirthday = DateTime(now.year, birthDate.value!.month, birthDate.value!.day);
    if (nextBirthday.isAtSameMomentAs(now) || (nextBirthday.year == now.year && nextBirthday.month == now.month && nextBirthday.day == now.day)) {
      daysUntilNextBirthday.value = '¡Hoy es tu cumpleaños!'.tr;
    } else {
      if (nextBirthday.isBefore(now)) {
        nextBirthday = DateTime(now.year + 1, birthDate.value!.month, birthDate.value!.day);
      }
      final daysUntil = nextBirthday.difference(now).inDays;
      daysUntilNextBirthday.value = '$daysUntil ${'días hasta el próximo cumpleaños'.tr}';
    }
  }

  void reset() {
    birthDate.value = null;
    age.value = '';
    daysUntilNextBirthday.value = '';
  }
}

class AgeCalculator extends StatelessWidget {
  const AgeCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    final AgeCalculatorController controller = Get.put(AgeCalculatorController());

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.lightBlue[50],
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => controller.birthDate.value == null
                    ? Text(
                        'Seleccionar Fecha de Nacimiento'.tr,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        '${'Fecha de Nacimiento Seleccionada'.tr}: ${DateFormat('yyyy-MM-dd').format(controller.birthDate.value!)}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      )),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      controller.birthDate.value = pickedDate;
                      controller.calculateAge();
                    }
                  },
                  child: Text('Seleccionar Fecha de Nacimiento'.tr),
                ),
                const SizedBox(height: 20),
                Obx(() => Text(
                      '${'Edad'.tr}: ${controller.age.value}',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(height: 20),
                Obx(() => Text(
                      controller.daysUntilNextBirthday.value,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'es_ES': {
          'Calculadora de Edad': 'Calculadora de Edad',
          'Seleccionar Fecha de Nacimiento': 'Seleccionar Fecha de Nacimiento',
          'Fecha de Nacimiento Seleccionada': 'Fecha de Nacimiento Seleccionada',
          'Edad': 'Edad',
          'días hasta el próximo cumpleaños': 'días hasta el próximo cumpleaños',
          'años': 'años',
          'meses': 'meses',
          'días': 'días',
          'horas': 'horas',
          '¡Hoy es tu cumpleaños!': '¡Hoy es tu cumpleaños!',
        },
        'en_US': {
          'Calculadora de Edad': 'Age Calculator',
          'Seleccionar Fecha de Nacimiento': 'Select Birth Date',
          'Fecha de Nacimiento Seleccionada': 'Selected Birth Date',
          'Edad': 'Age',
          'días hasta el próximo cumpleaños': 'days until next birthday',
          'años': 'years',
          'meses': 'months',
          'días': 'days',
          'horas': 'hours',
          '¡Hoy es tu cumpleaños!': 'Today is your birthday!',
        },
      };
}
