import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/shift_controller.dart';
import '../models/shift_model.dart';

class ShiftScreen extends GetView<ShiftsController> {
  final String currentUserName;
  final ScrollController _scrollController = ScrollController();

  ShiftScreen({super.key, required this.currentUserName}) {
    // مستشعر التمرير لتحميل المزيد من البيانات (Pagination)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreShifts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('إدارة الشيفتات',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown)),
              ),
            ),
            Expanded(child: _buildShiftsList()),
          ],
        );
      }),
    );
  }

  // --- واجهة حالة الشيفت الحالي ---
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
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
          border: Border.all(
              color: hasOpenShift ? Colors.green.shade200 : Colors.orange.shade200,
              width: 2),
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
                  ? 'الشيفت الحالي: ${current.type == 'morning' ? 'صباحي' : 'مسائي'}'
                  : 'لا يوجد شيفت مفتوح حالياً',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 25),
            if (!hasOpenShift)
              Row(
                children: [
                  Expanded(child: _shiftButton('صباحي', 'morning', Colors.amber[800]!)),
                  const SizedBox(width: 10),
                  Expanded(child: _shiftButton('مسائي', 'night', Colors.indigo[900]!)),
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
                onPressed: () => controller.endShift(current.id!),
                icon: const Icon(Icons.power_settings_new),
                label: const Text('إغلاق الشيفت الآن',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
      child: Text('فتح $label',
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // --- القائمة الرئيسية مع دعم التحميل التدريجي ---
  Widget _buildShiftsList() {
    return Obx(() => ListView.builder(
      controller: _scrollController,
      itemCount: controller.allShifts.length + (controller.hasMoreData.value ? 1 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        if (index < controller.allShifts.length) {
          return _buildShiftCard(controller.allShifts[index]);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.brown)),
          );
        }
      },
    ));
  }

  // --- تصميم الكارت مع معالجة البيانات ---
  Widget _buildShiftCard(ShiftModel shift) {
    bool isOpen = shift.isOpen == 1;

    // معالجة التاريخ
    String cleanDate;
    String rawDate = shift.date.toString();
    if (rawDate.contains('T')) {
      cleanDate = rawDate.split('T')[0];
    } else if (rawDate.contains(' ')) {
      cleanDate = rawDate.split(' ')[0];
    } else {
      cleanDate = rawDate;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: shift.type == 'morning' ? Colors.orange[50] : Colors.indigo[50],
          child: Icon(
            shift.type == 'morning' ? Icons.wb_sunny : Icons.nightlight_round,
            color: shift.type == 'morning' ? Colors.orange : Colors.indigo,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('شيفت ${shift.type == 'morning' ? 'صباحي' : 'مسائي'}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (!isOpen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_calculateDuration(shift.startTime, shift.endTime, isOpen),
                    style: TextStyle(
                        color: Colors.brown[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.brown),
                const SizedBox(width: 4),
                Text(shift.userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(cleanDate, style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.play_arrow, size: 14, color: Colors.green),
                const SizedBox(width: 5),
                Text('بداية: ${_formatTime(shift.startTime)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.stop, size: 14, color: Colors.red),
                const SizedBox(width: 5),
                Text(isOpen ? 'نهاية: نشط حالياً' : 'نهاية: ${_formatTime(shift.endTime)}',
                    style: TextStyle(
                        color: isOpen ? Colors.green : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: isOpen ? FontWeight.bold : FontWeight.normal)),
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
  }

  // --- دوال تنسيق الوقت والتاريخ (نسختك المفضلة) ---

  String _formatTime(dynamic dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.toString().isEmpty) return "--:--";

    try {
      String timeStr = dateTimeStr.toString();
      DateTime dt = DateTime.parse(timeStr);
      return DateFormat('h:mm a', 'ar').format(dt);
    } catch (e) {
      try {
        String timeStr = dateTimeStr.toString();
        RegExp timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
        Match? match = timeRegex.firstMatch(timeStr);
        if (match != null) {
          int hour = int.parse(match.group(1)!);
          int minute = int.parse(match.group(2)!);
          String period = hour >= 12 ? "م" : "ص";
          int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return "$displayHour:$minute $period";
        }
        return timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;
      } catch (e2) {
        return "--:--";
      }
    }
  }

  String _calculateDuration(dynamic start, dynamic end, bool isOpen) {
    if (isOpen || start == null || end == null) return "";
    try {
      DateTime? startTime = _parseDateTime(start);
      DateTime? endTime = _parseDateTime(end);

      if (startTime == null || endTime == null) return "";

      Duration diff = endTime.difference(startTime);
      if (diff.isNegative) return "";

      int hours = diff.inHours;
      int minutes = diff.inMinutes.remainder(60);

      if (hours > 0) return "⏱️ $hours س و $minutes د";
      return "⏱️ $minutes دقيقة";
    } catch (e) {
      return "";
    }
  }

  DateTime? _parseDateTime(dynamic timeValue) {
    if (timeValue == null) return null;
    try {
      return DateTime.parse(timeValue.toString());
    } catch (e) {
      try {
        String timeStr = timeValue.toString();
        RegExp dateTimeRegex = RegExp(r'(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})');
        Match? match = dateTimeRegex.firstMatch(timeStr);
        if (match != null) {
          return DateTime(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
            int.parse(match.group(4)!),
            int.parse(match.group(5)!),
            int.parse(match.group(6)!),
          );
        }
      } catch (e2) {
        return null;
      }
    }
    return null;
  }
}