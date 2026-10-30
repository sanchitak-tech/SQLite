import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: ScienceFair()));
class ScienceFair extends StatefulWidget { const ScienceFair({super.key}); @override State<ScienceFair> createState() => _ScienceFairState(); }

class _ScienceFairState extends State<ScienceFair> {
  Database? db;
  bool loading = true;
  Map<String, dynamic>? stu;

  final name = TextEditingController();
  final cls = TextEditingController();
  final project = TextEditingController();
  final category = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  final bg = const Color(0xFF1A102E), card = const Color(0xFF2E1A5E), card2 = const Color(0xFF3D1F7A), acc = const Color(0xFFD8B4FE), acc2 = const Color(0xFFC084FC);

  @override void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    db = await openDatabase(p.join(await getDatabasesPath(), 'science.db'), version: 1,
        onCreate: (d,v) => d.execute('CREATE TABLE fair(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,class TEXT,project TEXT,category TEXT,email TEXT UNIQUE,password TEXT)'));
    final pref = await SharedPreferences.getInstance();
    final saved = pref.getString('email');
    if(saved!=null){ final r = await db!.query('fair', where: 'email=?', whereArgs: [saved]); if(r.isNotEmpty) stu = r.first; }
    if(mounted) setState(()=>loading=false);
  }

  Widget f(String l, TextEditingController c, {bool s=false, IconData? ic}) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: TextField(controller: c, obscureText: s, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: Color(0xFFD8B4FE), fontSize: 13), prefixIcon: Icon(ic, color: Color(0xFFA78BFA), size: 19), filled: true, fillColor: bg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: acc2)))));

  void m(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t), backgroundColor: card2));

  Future<void> reg() async {
    if(name.text.trim().isEmpty||cls.text.trim().isEmpty||project.text.trim().isEmpty||category.text.trim().isEmpty||email.text.trim().isEmpty||pass.text.isEmpty){m('Fill all fields');return;}
    try{ await db!.insert('fair', {'name':name.text.trim(),'class':cls.text.trim(),'project':project.text.trim(),'category':category.text.trim(),'email':email.text.trim(),'password':pass.text}); await login(email.text.trim(), pass.text); } catch(_){m('Email already registered');}
  }
  Future<void> login(String e, String pw) async {
    final r = await db!.query('fair', where: 'email=? AND password=?', whereArgs: [e.trim(), pw]);
    if(r.isEmpty){m('Invalid email or password');return;}
    final pref = await SharedPreferences.getInstance(); await pref.setString('email', e.trim());
    if(mounted) setState(()=>stu=r.first);
  }
  Future<void> logout() async { final pref = await SharedPreferences.getInstance(); await pref.remove('email'); if(mounted) setState(()=>stu=null); }

  Widget _i(IconData ic, String k, String v) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF4C2B8A))), child: Row(children: [Icon(ic, color: acc, size: 18), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: const TextStyle(color: Color(0xFFC4B5FD), fontSize: 10)), Text(v, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))]))]));

  @override Widget build(BuildContext context) {
    if(loading) return Scaffold(backgroundColor: bg, body: Center(child: CircularProgressIndicator(color: acc2)));
    if(stu!=null){
      return Scaffold(backgroundColor: bg, appBar: AppBar(title: const Text('Science Fair Pass'), backgroundColor: bg, foregroundColor: Colors.white, centerTitle: true, elevation: 0),
        body: Center(child: Container(width: double.infinity, margin: const EdgeInsets.all(18), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [card, card2], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: acc.withOpacity(.2), shape: BoxShape.circle), child: Icon(Icons.science, color: acc, size: 42)),
          const SizedBox(height: 12), Text('Welcome, ${stu!['name']}!', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text('Class ${stu!['class']} - Registered', style: TextStyle(color: acc, fontSize: 12)), const SizedBox(height: 16),
          _i(Icons.person, 'Student', stu!['name']), _i(Icons.class_, 'Class', stu!['class']), _i(Icons.lightbulb, 'Project', stu!['project']), _i(Icons.category, 'Category', stu!['category']), _i(Icons.email, 'Email', stu!['email']),
          const SizedBox(height: 14), Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.qr_code, color: acc2), SizedBox(width: 8), Text('ID: SCI-${stu!['id']}  |  Stall: A-${stu!['id']}', style: TextStyle(color: Colors.white70, fontSize: 12))])) ,
          const SizedBox(height: 14), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: acc, foregroundColor: Color(0xFF2E1A5E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), onPressed: logout, child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)))),
        ]))),
      );
    }
    return DefaultTabController(length: 2, child: Scaffold(backgroundColor: bg, body: Center(child: SingleChildScrollView(child: Container(width: double.infinity, margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(26), border: Border.all(color: Color(0xFF4C2B8A))), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.biotech, color: acc, size: 44), const SizedBox(height: 6), const Text('Science Fair 2026', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text('School Registration', style: TextStyle(color: acc, fontSize: 12)), const SizedBox(height: 14),
      Container(decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: const TabBar(indicator: BoxDecoration(color: Color(0xFF3D1F7A), borderRadius: BorderRadius.all(Radius.circular(10))), labelColor: Colors.white, unselectedLabelColor: Color(0xFF8B7AB0), tabs: [Tab(text: 'Login'), Tab(text: 'Register Project')])),
      const SizedBox(height: 12), SizedBox(height: 440, child: TabBarView(children: [
        ListView(children: [f('Email', email, ic: Icons.email_outlined), f('Password', pass, s:true, ic: Icons.lock_outline), const SizedBox(height: 12), SizedBox(height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: acc, foregroundColor: Color(0xFF2E1A5E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), onPressed: ()=>login(email.text, pass.text), child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold))))]),
        ListView(children: [f('Student Name', name, ic: Icons.person_outline), f('Class (e.g. 10-A)', cls, ic: Icons.class_), f('Project Title', project, ic: Icons.lightbulb_outline), f('Category (Physics/Chem/Bio)', category, ic: Icons.category_outlined), f('Email', email, ic: Icons.email_outlined), f('Password', pass, s:true, ic: Icons.lock_outline), const SizedBox(height: 10), SizedBox(height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: acc2, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), onPressed: reg, child: const Text('REGISTER FOR FAIR', style: TextStyle(fontWeight: FontWeight.bold))))]),
      ]))
    ]))))));
  }
}