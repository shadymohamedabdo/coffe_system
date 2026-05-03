import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/shift_manage_controller.dart';
import '../models/shift_model.dart';

// شاشة إدارة الشيفتات
class ShiftScreen extends GetView<ShiftsController> {
  final String currentUserName;

  // سكروول كنترولر عشان نعمل Pagination (تحميل تدريجي)
  final ScrollController _scrollController = ScrollController();

  ShiftScreen({super.key, required this.currentUserName}) {
    // بنراقب السكرول، ولما نوصل لآخر القائمة نحمل داتا جديدة
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

      // AppBar فوق
      appBar: AppBar(
        title: const Text('إدارة الشيفتات',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      // الجسم كله Reactive باستخدام Obx
      body: Obx(() {
        // لو في تحميل أول مرة
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.brown));
        }

        return Column(
          children: [
            // جزء حالة الشيفت الحالي (مفتوح ولا مقفول)
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

            // قائمة الشيفتات
            Expanded(child: _buildShiftsList()),
          ],
        );
      }),
    );
  }

  // ================= حالة الشيفت الحالي =================
  Widget _buildCurrentShiftStatus() {
    return Obx(() {
      final current = controller.openShift.value;
      bool hasOpenShift = current != null;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),

        // شكل الكارد بتاع الحالة
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
          border: Border.all(
              color: hasOpenShift
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
              width: 2),
        ),

        child: Column(
          children: [
            // أيقونة الحالة
            Icon(
              hasOpenShift
                  ? Icons.check_circle
                  : Icons.warning_amber_rounded,
              size: 60,
              color: hasOpenShift ? Colors.green : Colors.orange,
            ),

            const SizedBox(height: 12),

            // نص الحالة
            Text(
              hasOpenShift
                  ? 'الشيفت الحالي: ${current.type == 'morning' ? 'صباحي' : 'مسائي'}'
                  : 'لا يوجد شيفت مفتوح حالياً',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 25),

            // لو مفيش شيفت مفتوح → نعرض أزرار فتح شيفت
            if (!hasOpenShift)
              Row(
                children: [
                  Expanded(child: _shiftButton('صباحي', 'morning', Colors.amber[800]!)),
                  const SizedBox(width: 10),
                  Expanded(child: _shiftButton('مسائي', 'night', Colors.indigo[900]!)),
                ],
              )

            // لو في شيفت مفتوح → زر الإغلاق
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

  // زر فتح شيفت (صباحي / مسائي)
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

  // ================= قائمة الشيفتات =================
  Widget _buildShiftsList() {
    return Obx(() => ListView.builder(
      controller: _scrollController,
      itemCount: controller.allShifts.length +
          (controller.hasMoreData.value ? 1 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        // لو لسه في داتا
        if (index < controller.allShifts.length) {
          return _buildShiftCard(controller.allShifts[index]);
        }

        // loader في آخر القائمة
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.brown)),
        );
      },
    ));
  }

  // ================= كارد الشيفت =================
  Widget _buildShiftCard(ShiftModel shift) {
    bool isOpen = shift.isOpen == 1;

    // تنظيف التاريخ
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

        // أيقونة الشيفت
        leading: CircleAvatar(
          backgroundColor: shift.type == 'morning'
              ? Colors.orange[50]
              : Colors.indigo[50],
          child: Icon(
            shift.type == 'morning'
                ? Icons.wb_sunny
                : Icons.nightlight_round,
            color: shift.type == 'morning'
                ? Colors.orange
                : Colors.indigo,
          ),
        ),

        // عنوان الشيفت
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('شيفت ${shift.type == 'morning' ? 'صباحي' : 'مسائي'}',
                style: const TextStyle(fontWeight: FontWeight.bold)),

            // مدة الشيفت لو مقفول
            if (!isOpen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _calculateDuration(
                      shift.startTime, shift.endTime, isOpen),
                  style: TextStyle(
                      color: Colors.brown[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),

        // تفاصيل الشيفت
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // اسم المستخدم + التاريخ
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.brown),
                const SizedBox(width: 4),
                Text(shift.userName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(cleanDate, style: const TextStyle(fontSize: 12)),
              ],
            ),

            const SizedBox(height: 5),

            // وقت البداية
            Row(
              children: [
                const Icon(Icons.play_arrow,
                    size: 14, color: Colors.green),
                const SizedBox(width: 5),
                Text('بداية: ${_formatTime(shift.startTime)}',
                    style: TextStyle(
                        color: Colors.grey[700], fontSize: 12)),
              ],
            ),

            const SizedBox(height: 2),

            // وقت النهاية
            Row(
              children: [
                const Icon(Icons.stop, size: 14, color: Colors.red),
                const SizedBox(width: 5),
                Text(
                  isOpen
                      ? 'نهاية: شغال دلوقتي'
                      : 'نهاية: ${_formatTime(shift.endTime)}',
                  style: TextStyle(
                    color: isOpen ? Colors.green : Colors.grey[700],
                    fontSize: 12,
                    fontWeight:
                    isOpen ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),

        // حالة الشيفت (نشط / مقفول)
        trailing: Badge(
          label: Text(isOpen ? 'نشط' : 'مقفول'),
          backgroundColor: isOpen ? Colors.green : Colors.grey[400],
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }

  // ================= دوال مساعدة =================

  String _formatTime(dynamic dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.toString().isEmpty) return "--:--";

    try {
      DateTime dt = DateTime.parse(dateTimeStr.toString());
      return DateFormat('h:mm a', 'ar').format(dt);
    } catch (e) {
      return "--:--";
    }
  }

  String _calculateDuration(dynamic start, dynamic end, bool isOpen) {
    if (isOpen || start == null || end == null) return "";

    try {
      DateTime startTime = DateTime.parse(start.toString());
      DateTime endTime = DateTime.parse(end.toString());

      Duration diff = endTime.difference(startTime);

      int hours = diff.inHours;
      int minutes = diff.inMinutes.remainder(60);

      if (hours > 0) return "⏱️ $hours ساعة و $minutes دقيقة";
      return "⏱️ $minutes دقيقة";
    } catch (e) {
      return "";
    }
  }
}