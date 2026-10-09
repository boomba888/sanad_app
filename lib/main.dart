import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SanadApp());
}

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سند',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: const PhoneAuthScreen(),
    );
  }
}

// شاشة التحقق من رقم الهاتف
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _codeSent = false;

  void _sendSMS() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ادخل رقم الهاتف أولاً')),
      );
      return;
    }

    // هنا يتم ربط إرسال الرسالة عبر Firebase
    setState(() {
      _codeSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال رمز التحقق إلى ${_phoneController.text}')),
    );
  }

  void _verifyCode() {
    if (_codeController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل الرمز الصحيح')),
      );
      return;
    }

    // الانتقال لشاشة التبليغ بعد التحقق
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ReportScreen(phoneNumber: _phoneController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التحقق من رقم الهاتف'),
          backgroundColor: Colors.red[800],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '07XXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              if (_codeSent) ...[
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق (OTP)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.green[700],
                  ),
                  child: const Text('تأكيد الرمز والدخول', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _sendSMS,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.red[800],
                  ),
                  child: const Text('إرسال رمز التحقق SMS', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// شاشة إرسال التبليغ مع إرفاق ملف حقيقي
class ReportScreen extends StatefulWidget {
  final String phoneNumber;
  const ReportScreen({super.key, required this.phoneNumber});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _detailsController = TextEditingController();
  String? _selectedFileName;

  // ميزة فتح ملفات الهاتف الحقيقية
  Future<void> _pickRealFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرفاق الملف: $_selectedFileName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitReport() {
    if (_detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة تفاصيل المشكلة')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال التبليغ بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تبليغ عن: ${widget.phoneNumber}'),
          backgroundColor: Colors.red[800],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '...اكتب تفاصيل المشكلة بالتفصيل',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickRealFile,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  _selectedFileName != null
                      ? 'تم إرفاق: $_selectedFileName'
                      : 'إرفاق دليل من الهاتف (صورة/ملف)',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: _selectedFileName != null ? Colors.green[100] : Colors.grey[200],
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.red[800],
                ),
                child: const Text(
                  'إرسال التبليغ النهائي',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
