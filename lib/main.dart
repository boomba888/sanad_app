import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

enum UserRole { merchant, livreur }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _businessName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _otp = TextEditingController();

  UserRole _selectedRole = UserRole.merchant;
  bool _codeSent = false;

  @override
  void dispose() {
    _businessName.dispose();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMerchant = _selectedRole == UserRole.merchant;
    Color primaryColor = isMerchant ? Colors.indigo : Colors.deepOrange;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryColor,
                child: Icon(
                  isMerchant ? Icons.storefront : Icons.delivery_dining,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text('تطبيق سـنـد', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const Text('منصة التحقق والحماية من التكلفة والضياع', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (!_codeSent) setState(() => _selectedRole = UserRole.merchant);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isMerchant ? Colors.indigo : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('متجر / مطعم', textAlign: TextAlign.center, style: TextStyle(color: isMerchant ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (!_codeSent) setState(() => _selectedRole = UserRole.livreur);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isMerchant ? Colors.deepOrange : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('عمال التوصيل', textAlign: TextAlign.center, style: TextStyle(color: !isMerchant ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_codeSent) ...[
                        if (isMerchant) ...[
                          TextField(
                            controller: _businessName,
                            decoration: const InputDecoration(labelText: 'اسم المطعم / الصفحة التجارية', prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'رقم الهاتف للتحقق', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () {
                            if (isMerchant && _businessName.text.trim().isEmpty) {
                              _showMsg('يرجى إدخال اسم المطعم أو الصفحة أولاً');
                              return;
                            }
                            if (_phone.text.trim().isEmpty) {
                              _showMsg('يرجى إدخال رقم الهاتف أولاً');
                              return;
                            }
                            setState(() => _codeSent = true);
                            _showMsg('تم إرسال رمز التحقق (1234)');
                          },
                          child: const Text('إرسال رمز SMS', style: TextStyle(color: Colors.white)),
                        ),
                      ] else ...[
                        Text('أدخل رمز التحقق (1234) المرسل إلى ${_phone.text}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otp,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(hintText: '1234', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () {
                            if (_otp.text.trim() == "1234") {
                              Widget screen = isMerchant
                                  ? MerchantHomeScreen(businessName: _businessName.text.trim(), phone: _phone.text.trim())
                                  : LivreurHomeScreen(phone: _phone.text.trim());
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));
                            } else {
                              _showMsg('الرمز غير صحيح! أعد إدخال 1234');
                            }
                          },
                          child: const Text('تأكيد والدخول', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _codeSent = false),
                          child: const Text('تغيير رقم الهاتف'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MerchantHomeScreen extends StatefulWidget {
  final String businessName;
  final String phone;
  const MerchantHomeScreen({Key? key, required this.businessName, required this.phone}) : super(key: key);

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  final TextEditingController _target = TextEditingController();
  final Map<String, int> _db = {'0555123456': 4, '0666123456': 1};
  final List<String> _myReports = [];
  String _res = "";

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.businessName), backgroundColor: Colors.indigo),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.indigo[50],
              child: Text('حساب موثق: ${widget.businessName} (${widget.phone})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
            const SizedBox(height: 20),
            TextField(controller: _target, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'أدخل رقم الزبون للفحص', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              onPressed: () {
                String p = _target.text.trim();
                if (p.isEmpty) { _showMsg('يرجى كتابة رقم الزبون قبل الفحص'); return; }
                int count = _db[p] ?? 0;
                setState(() {
                  _res = count >= 3 ? "🔴 زبون خطير ملغي متكرر ($count تبليغات)" : count > 0 ? "🟡 زبون مشبوه ($count تبليغات)" : "🟢 زبون سليم وموثوق";
                });
              },
              child: const Text('افحص الرقم الآن', style: TextStyle(color: Colors.white)),
            ),
            if (_res.isNotEmpty) Padding(padding: const EdgeInsets.all(12.0), child: Text(_res, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const Divider(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.report, color: Colors.white),
              label: const Text('تقديم تبليغ موثق عن الزبون', style: TextStyle(color: Colors.white)),
              onPressed: () {
                String p = _target.text.trim();
                if (p.isEmpty) { _showMsg('أدخل رقم الزبون أولاً'); return; }
                if (_myReports.contains(p)) { _showMsg('قمت بالتبليغ عنه مسبقاً'); return; }
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen(targetPhone: p, onSuccess: () {
                  setState(() { _db[p] = (_db[p] ?? 0) + 1; _myReports.add(p); });
                  _showMsg('تم تقديم التبليغ بنجاح');
                })));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LivreurHomeScreen extends StatefulWidget {
  final String phone;
  const LivreurHomeScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<LivreurHomeScreen> createState() => _LivreurHomeScreenState();
}

class _LivreurHomeScreenState extends State<LivreurHomeScreen> {
  final TextEditingController _target = TextEditingController();
  final Map<String, int> _db = {'0777123456': 3, '0666123456': 1};
  final List<String> _myReports = [];
  String _res = "";

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('واجهة عامل التوصيل (Livreur)'), backgroundColor: Colors.deepOrange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange[50],
              child: Text('موصل موثق برقم: ${widget.phone}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ),
            const SizedBox(height: 20),
            TextField(controller: _target, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'أدخل رقم هاتف الزبون', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () {
                String p = _target.text.trim();
                if (p.isEmpty) { _showMsg('يرجى كتابة رقم الزبون أولاً'); return; }
                int count = _db[p] ?? 0;
                setState(() {
                  _res = count >= 3 ? "🔴 زبون يرفض الاستلام باستمرار!" : count > 0 ? "🟡 زبون يتأخر في الرد" : "🟢 زبون ملتزم وموثوق";
                });
              },
              child: const Text('فحص الزبون قبل التوجه', style: TextStyle(color: Colors.white)),
            ),
            if (_res.isNotEmpty) Padding(padding: const EdgeInsets.all(12.0), child: Text(_res, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const Divider(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text('تبليغ عن رفض / إلغاء طلب', style: TextStyle(color: Colors.white)),
              onPressed: () {
                String p = _target.text.trim();
                if (p.isEmpty) { _showMsg('أدخل رقم الزبون أولاً'); return; }
                if (_myReports.contains(p)) { _showMsg('قمت بالتبليغ عن هذا الرقم مسبقاً'); return; }
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen(targetPhone: p, onSuccess: () {
                  setState(() { _db[p] = (_db[p] ?? 0) + 1; _myReports.add(p); });
                  _showMsg('تم تسجيل التبليغ بنجاح');
                })));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReportScreen extends StatefulWidget {
  final String targetPhone;
  final VoidCallback onSuccess;
  const ReportScreen({Key? key, required this.targetPhone, required this.onSuccess}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _details = TextEditingController();
  bool _hasMedia = false;

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تبليغ عن: ${widget.targetPhone}'), backgroundColor: Colors.red[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _details, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب تفاصيل المشكلة بالتفصيل...', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_hasMedia ? 'تم إرفاق الدليل بنجاح' : 'إرفاق دليل مادي (إجباري)'),
              onPressed: () { setState(() => _hasMedia = true); _showMsg('تم إرفاق الدليل بنجاح'); },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: () {
                if (_details.text.trim().isEmpty) { _showMsg('يرجى كتابة التفاصيل أولاً'); return; }
                if (!_hasMedia) { _showMsg('يرجى إرفاق الدليل قبل الإرسال'); return; }
                widget.onSuccess();
                Navigator.pop(context);
              },
              child: const Text('إرسال التبليغ النهائي', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
