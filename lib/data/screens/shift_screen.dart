import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/shift_controller.dart';

class ShiftScreen extends GetView<ShiftsController> {
  final String currentUserName;

  const ShiftScreen({super.key, required this.currentUserName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text(
            'إدارة الشيفتات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.brown));
        }
        return Column(
          children: [
            _buildCurrentShiftStatus(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('سجل الشيفتات السابقة',
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown)),
              ),
            ),
            Expanded(child: _buildShiftsHistory()),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentShiftStatus() {
    return Obx(() {
      final current = controller.openShift.value;
      bool hasOpenShift = current != null;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
          border: Border.all(
              color: hasOpenShift ? Colors.green.shade200 : Colors.orange
                  .shade200, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              hasOpenShift ? Icons.check_circle : Icons.warning_amber_rounded,
              size: 60,
              color: hasOpenShift ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              hasOpenShift
                  ? 'الشيفت الحالي: ${current['type'] == 'morning'
                  ? 'صباحي'
                  : 'مسائي'}'
                  : 'لا يوجد شيفت مفتوح حالياً',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 25),
            if (!hasOpenShift)
              Row(
                children: [
                  Expanded(child: _shiftButton(
                      'صباحي', 'morning', Colors.amber[800]!)),
                  const SizedBox(width: 10),
                  Expanded(child: _shiftButton(
                      'مسائي', 'night', Colors.indigo[900]!)),
                ],
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => controller.endShift(current['id']),
                icon: const Icon(Icons.power_settings_new),
                label: const Text('إغلاق الشيفت الآن', style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      );
    });
  }

  Widget _shiftButton(String label, String type, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () => controller.startShift(type, currentUserName),
      child: Text(
          'فتح $label', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShiftsHistory() {
    return Obx(() =>
        ListView.builder(
          itemCount: controller.allShifts.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final shift = controller.allShifts[index];
            bool isOpen = shift['is_open'] == 1;

            String employeeName = shift['user_name'] ?? "غير معروف";

            // ✅ معالجة التاريخ بشكل أفضل (يدعم تنسيقات متعددة)
            String cleanDate;
            String rawDate = shift['date'].toString();
            if (rawDate.contains('T')) {
              cleanDate = rawDate.split('T')[0];
            } else if (rawDate.contains(' ')) {
              cleanDate = rawDate.split(' ')[0];
            } else {
              cleanDate = rawDate;
            }

            // معالجة وقت البداية
            String startTime = _formatTime(shift['start_time']);

            // معالجة وقت النهاية بشكل أفضل
            String endTime;
            if (isOpen) {
              endTime = "نشط حالياً";
            } else {
              // التحقق من وجود end_time
              if (shift['end_time'] != null && shift['end_time']
                  .toString()
                  .isNotEmpty) {
                endTime = _formatTime(shift['end_time']);
              } else {
                endTime = "غير مسجل"; // بدلاً من "---"
              }
            }

            // حساب المدة فقط إذا كان الشيفت مغلق ويوجد end_time
            String duration = "";
            if (!isOpen && shift['end_time'] != null && shift['end_time']
                .toString()
                .isNotEmpty) {
              duration = _calculateDuration(
                  shift['start_time'], shift['end_time'], isOpen);
            }

            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: CircleAvatar(
                  backgroundColor: shift['type'] == 'morning' ? Colors
                      .orange[50] : Colors.indigo[50],
                  child: Icon(
                    shift['type'] == 'morning' ? Icons.wb_sunny : Icons
                        .nightlight_round,
                    color: shift['type'] == 'morning' ? Colors.orange : Colors
                        .indigo,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('شيفت ${shift['type'] == 'morning'
                        ? 'صباحي'
                        : 'مسائي'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (!isOpen && duration.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(duration,
                            style: TextStyle(color: Colors.brown[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    // سطر الموظف والتاريخ
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.brown[300]),
                        const SizedBox(width: 4),
                        Text(employeeName,
                            style: TextStyle(color: Colors.brown[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        const SizedBox(width: 10),
                        Icon(Icons.calendar_month, size: 14,
                            color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(cleanDate, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // سطر وقت البداية
                    Row(
                      children: [
                        const Icon(
                            Icons.play_arrow, size: 14, color: Colors.green),
                        const SizedBox(width: 5),
                        Text('بداية: $startTime',
                            style: TextStyle(color: Colors.grey[700],
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // سطر وقت النهاية
                    Row(
                      children: [
                        const Icon(Icons.stop, size: 14, color: Colors.red),
                        const SizedBox(width: 5),
                        Text('نهاية: $endTime',
                            style: TextStyle(
                              color: isOpen ? Colors.green : (endTime ==
                                  "غير مسجل" ? Colors.orange : Colors
                                  .grey[700]),
                              fontSize: 12,
                              fontWeight: endTime == "غير مسجل" ? FontWeight
                                  .bold : FontWeight.normal,
                            )),
                      ],
                    ),
                  ],
                ),
                trailing: Badge(
                  label: Text(isOpen ? 'نشط' : 'تم الإغلاق'),
                  backgroundColor: isOpen ? Colors.green : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            );
          },
        ));
  }

// دالة محسنة لتنسيق الوقت
// ميثود تحويل النص الطويل لساعة ودقيقة بشكل نظيف
  String _formatTime(dynamic dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.toString().isEmpty) return "--:--";

    try {
      String timeStr = dateTimeStr.toString();

      // محاولة تحويل إلى DateTime
      DateTime dt = DateTime.parse(timeStr);

      // تنسيق الوقت بطريقة جميلة
      return DateFormat('h:mm a', 'ar').format(dt);
      // هذا سيعرض: 2:30 م  أو 10:15 ص

    } catch (e) {
      // إذا فشل التحويل، حاول استخراج الوقت يدوياً
      try {
        String timeStr = dateTimeStr.toString();

        // البحث عن نمط الوقت في النص
        RegExp timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
        Match? match = timeRegex.firstMatch(timeStr);

        if (match != null) {
          int hour = int.parse(match.group(1)!);
          int minute = int.parse(match.group(2)!);

          String period = hour >= 12 ? "مساءً" : "صباحاً";
          int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

          return "$displayHour:$minute $period";
        }

        return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
      } catch (e2) {
        return "--:--";
      }
    }
  }
// دالة محسنة لحساب المدة بدقة
  String _calculateDuration(dynamic start, dynamic end, bool isOpen) {
    if (isOpen || start == null || end == null) return "";

    try {
      DateTime? startTime = _parseDateTime(start);
      DateTime? endTime = _parseDateTime(end);

      if (startTime == null || endTime == null) {
        return "خطأ في الوقت";
      }

      // حساب الفرق
      Duration diff = endTime.difference(startTime);

      // التأكد من أن الفرق موجب
      if (diff.isNegative) {
        return "توقيت غير صحيح";
      }

      int hours = diff.inHours;
      int minutes = diff.inMinutes.remainder(60);
      int seconds = diff.inSeconds.remainder(60);

      // تنسيق المدة بشكل جميل
      if (hours > 0) {
        if (minutes > 0) {
          return "⏱️ $hours ساعة و $minutes دقيقة";
        } else {
          return "⏱️ $hours ساعة";
        }
      } else if (minutes > 0) {
        return "⏱️ $minutes دقيقة";
      } else {
        return "⏱️ $seconds ثانية";
      }
    } catch (e) {
      print("خطأ في حساب المدة: $e");
      return "";
    }
  }

// دالة مساعدة لتحويل أي تنسيق وقت إلى DateTime
  DateTime? _parseDateTime(dynamic timeValue) {
    if (timeValue == null) return null;

    try {
      String timeStr = timeValue.toString();

      // محاولة التحويل المباشر
      return DateTime.parse(timeStr);
    } catch (e) {
      // إذا فشل، نحاول استخراج الوقت يدوياً
      try {
        String timeStr = timeValue.toString();

        // البحث عن التاريخ والوقت
        RegExp dateTimeRegex = RegExp(
            r'(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})');
        Match? match = dateTimeRegex.firstMatch(timeStr);

        if (match != null) {
          int year = int.parse(match.group(1)!);
          int month = int.parse(match.group(2)!);
          int day = int.parse(match.group(3)!);
          int hour = int.parse(match.group(4)!);
          int minute = int.parse(match.group(5)!);
          int second = int.parse(match.group(6)!);

          return DateTime(year, month, day, hour, minute, second);
        }

        // محاولة أخرى: البحث فقط عن الوقت إذا كان التاريخ موجوداً بشكل منفصل
        RegExp timeRegex = RegExp(r'(\d{2}):(\d{2}):(\d{2})');
        match = timeRegex.firstMatch(timeStr);

        if (match != null && timeStr.contains(RegExp(r'\d{4}-\d{2}-\d{2}'))) {
          // استخراج التاريخ
          RegExp dateRegex = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
          Match? dateMatch = dateRegex.firstMatch(timeStr);

          if (dateMatch != null) {
            int year = int.parse(dateMatch.group(1)!);
            int month = int.parse(dateMatch.group(2)!);
            int day = int.parse(dateMatch.group(3)!);
            int hour = int.parse(match.group(1)!);
            int minute = int.parse(match.group(2)!);
            int second = int.parse(match.group(3)!);

            return DateTime(year, month, day, hour, minute, second);
          }
        }

        return null;
      } catch (e2) {
        return null;
      }
    }
  }
}