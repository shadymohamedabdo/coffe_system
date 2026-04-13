import 'package:flutter/material.dart';
import '../repositories/shifts_repository.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final repo = ShiftsRepository();
  Map<String, dynamic>? openShift;
  List<Map<String, dynamic>> allShifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final current = await repo.getOpenShift();
    final history = await repo.getAllShifts();
    setState(() {
      openShift = current;
      allShifts = history;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('إدارة الشيفتات'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : Column(
        children: [
          _buildCurrentShiftStatus(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('سجل الشيفتات السابقة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
            ),
          ),
          Expanded(child: _buildShiftsHistory()),
        ],
      ),
    );
  }

  Widget _buildCurrentShiftStatus() {
    bool hasOpenShift = openShift != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasOpenShift ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hasOpenShift ? Colors.green : Colors.orange, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            hasOpenShift ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 50,
            color: hasOpenShift ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            hasOpenShift ? 'الشيفت الحالي: ${openShift!['type'] == 'morning' ? 'صباحي' : 'مسائي'}' : 'لا يوجد شيفت مفتوح حالياً',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (!hasOpenShift)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shiftButton('صباحي', 'morning', Colors.amber[800]!),
                _shiftButton('مسائي', 'night', Colors.indigo[900]!),
              ],
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () async {
                await repo.closeShift(openShift!['id']);
                loadData();
              },
              icon: const Icon(Icons.power_settings_new),
              label: const Text('إغلاق الشيفت الآن', style: TextStyle(fontSize: 18)),
            ),
        ],
      ),
    );
  }

  Widget _shiftButton(String label, String type, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      onPressed: () async {
        await repo.openShift(type);
        loadData();
      },
      child: Text('فتح شيفت $label'),
    );
  }

  Widget _buildShiftsHistory() {
    return ListView.builder(
      itemCount: allShifts.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final shift = allShifts[index];
        bool isOpen = shift['is_open'] == 1;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              shift['type'] == 'morning' ? Icons.wb_sunny : Icons.nightlight_round,
              color: shift['type'] == 'morning' ? Colors.orange : Colors.indigo,
            ),
            title: Text('شيفت ${shift['type'] == 'morning' ? 'صباحي' : 'مسائي'}'),
            subtitle: Text(shift['date'].toString().split('T')[0]), // عرض التاريخ فقط
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isOpen ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOpen ? 'مفتوح' : 'مغلق',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}