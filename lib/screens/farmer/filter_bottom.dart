import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class FilterBottomSheet extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final Function(int bulan, int tahun) onFilter;

  const FilterBottomSheet({
    super.key,
    required this.onFilter,
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}


class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // DateTime selectedDate = DateTime.now();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(widget.initialYear, widget.initialMonth);
  }

  void _selectMonthYear() async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMMM yyyy').format(selectedDate);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Center(
            child: Text(
              'Filter Data per Bulan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(formatted),
            trailing: TextButton(
              onPressed: _selectMonthYear,
              child: const Text('Pilih'),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              widget.onFilter(selectedDate.month, selectedDate.year);
              Navigator.pop(context); // Tutup bottom sheet
            },
            icon: const Icon(Icons.search),
            label: const Text('Terapkan Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
