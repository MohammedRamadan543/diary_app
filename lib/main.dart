import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(DiaryApp());

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مفكرة يومية',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: DiaryHomePage(),
    );
  }
}

class DiaryHomePage extends StatefulWidget {
  @override
  _DiaryHomePageState createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  final TextEditingController _noteController = TextEditingController();
  Map<String, String> _notes = {}; // التاريخ => الملاحظة
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes = prefs.getString('diary_notes');
    if (savedNotes != null) {
      setState(() {
        _notes = Map<String, String>.from(json.decode(savedNotes));
        _noteController.text = _notes[_selectedDate] ?? '';
      });
    }
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    _notes[_selectedDate] = _noteController.text;
    await prefs.setString('diary_notes', json.encode(_notes));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم حفظ الملاحظة!')));
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale("ar", "AE"),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked.toIso8601String().split('T')[0];
        _noteController.text = _notes[_selectedDate] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مفكرة يومية'),
        actions: [
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _pickDate),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'الملاحظة ليوم $_selectedDate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اكتب ملاحظتك هنا...',
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _saveNote, child: Text('حفظ')),
          ],
        ),
      ),
    );
  }
}
