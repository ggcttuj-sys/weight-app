import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const WeightLossApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  double currentWeight = 84.0;
  double targetWeight = 75.0;
  int targetCalories = 2200;
  int consumedCalories = 1450;
  
  int waterIntakeMl = 1500;
  int targetWaterMl = 3000;

  List<WeightRecord> weightHistory = [
    WeightRecord(date: '10 Oct', weight: 85.5),
    WeightRecord(date: '12 Oct', weight: 85.0),
    WeightRecord(date: '14 Oct', weight: 84.6),
    WeightRecord(date: '16 Oct', weight: 84.2),
    WeightRecord(date: '18 Oct', weight: 84.0),
  ];

  final List<String> dailyTips = [
    "احرص على شرب كوبين من الماء قبل كل وجبة بـ 30 دقيقة لتعزيز الشعور بالشبع.",
    "البروتين يساعد في الحفاظ على الكتلة العضلية أثناء خسارة الدهون، احرص على مصادره الصحية.",
    "النوم المبكر ولمدة كافية ينظم هرمونات الجوع والشبع (الغريلين واللبتين).",
    "المشي السريع لمدة 30 دقيقة يومياً يرفع من معدل حرق السعرات بشكل ملحوظ."
  ];

  void addWater(int amount) {
    waterIntakeMl += amount;
    if (waterIntakeMl < 0) waterIntakeMl = 0;
    notifyListeners();
  }

  void addMeal(int calories) {
    consumedCalories += calories;
    notifyListeners();
  }

  void updateWeight(double newWeight) {
    currentWeight = newWeight;
    weightHistory.add(WeightRecord(date: 'اليوم', weight: newWeight));
    notifyListeners();
  }

  void calculateBmrAndTdee(double weight, double height, int age, bool isMale, double activityFactor) {
    double bmr;
    if (isMale) {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    double tdee = bmr * activityFactor;
    targetCalories = (tdee - 500).toInt(); // عجز سعرات للخسارة
    notifyListeners();
  }
}

class WeightRecord {
  final String date;
  final double weight;
  WeightRecord({required this.date, required this.weight});
}

class WeightLossApp extends StatelessWidget {
  const WeightLossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الرشاقة ونزول الوزن',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        fontFamily: 'Roboto',
      ),
      home: const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalculatorScreen(),
    const WaterTrackerScreen(),
    const WeightHistoryScreen(),
    const TipsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'الحاسبة'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'الماء'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_weight), label: 'الوزن'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'نصائح'),
        ],
      ),
    );
  }
}

// 1. شاشة لوحة القيادة الرئيسية (Dashboard)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    double calorieProgress = appState.consumedCalories / appState.targetCalories;
    if (calorieProgress > 1.0) calorieProgress = 1.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة المتابعة اليومية'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الوزن
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الوزن الحالي', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${appState.currentWeight} كغ', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(height: 40, width: 1, color: Colors.white30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الوزن المستهدف', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${appState.targetWeight} كغ', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // بطاقة السعرات الحرارية
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('السعرات الحرارية اليومية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المستهلك: ${appState.consumedCalories} سعرة'),
                          Text('الهدف: ${appState.targetCalories} سعرة', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: calorieProgress,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.teal,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // بطاقة الماء السريعة
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blue, size: 36),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('استهلاك الماء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${appState.waterIntakeMl} / ${appState.targetWaterMl} مل', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => appState.addWater(250),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        child: const Text('+ 250 مل'),
                      ),
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

// 2. حاسبة السعرات والماكروز (CalculatorScreen)
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _weightController = TextEditingController(text: '84');
  final _heightController = TextEditingController(text: '176');
  final _ageController = TextEditingController(text: '21');
  bool _isMale = true;
  double _activityFactor = 1.2;
  
  final _mealCaloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حاسبة السعرات والوجبات'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('حساب الاحتياج اليومي (BMR & TDEE)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الوزن (كغ)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الطول (سم)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العمر', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('الجنس: '),
                  Radio<bool>(value: true, groupValue: _isMale, onChanged: (val) => setState(() => _isMale = val!)),
                  const Text('ذكر'),
                  Radio<bool>(value: false, groupValue: _isMale, onChanged: (val) => setState(() => _isMale = val!)),
                  const Text('أنثى'),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<double>(
                value: _activityFactor,
                decoration: const InputDecoration(labelText: 'مستوى النشاط البدني', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1.2, child: Text('قليل النشاط (جلوس طويل)')),
                  DropdownMenuItem(value: 1.375, child: Text('نشاط خفيف (تمارين خفيفة 1-3 أيام)')),
                  DropdownMenuItem(value: 1.55, child: Text('نشاط متوسط (تمارين 3-5 أيام)')),
                  DropdownMenuItem(value: 1.725, child: Text('نشاط عالي (تمارين مكثفة)')),
                ],
                onChanged: (val) => setState(() => _activityFactor = val!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    double w = double.tryParse(_weightController.text) ?? 84;
                    double h = double.tryParse(_heightController.text) ?? 176;
                    int a = int.tryParse(_ageController.text) ?? 21;
                    appState.calculateBmrAndTdee(w, h, a, _isMale, _activityFactor);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث السعرات المستهدفة بنجاح!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('احسب واعتمد السعرات'),
                ),
              ),
              const Divider(height: 40),
              const Text('تسجيل وجبة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _mealCaloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'سعرات الوجبة (كالوري)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    int cals = int.tryParse(_mealCaloriesController.text) ?? 0;
                    if (cals > 0) {
                      appState.addMeal(cals);
                      _mealCaloriesController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تمت إضافة الوجبة بنجاح')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: const Text('إضافة الوجبة للسعرات المستهلكة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. مسجل استهلاك الماء (WaterTrackerScreen)
class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    double progress = appState.waterIntakeMl / appState.targetWaterMl;
    if (progress > 1.0) progress = 1.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مسجل الماء'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                '${appState.waterIntakeMl} مل',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const Text('الهدف اليومي: 3000 مل', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 30),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue.shade100,
                color: Colors.blue,
                minHeight: 14,
                borderRadius: BorderRadius.circular(7),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => appState.addWater(250),
                    icon: const Icon(Icons.add),
                    label: const Text('250 مل'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => appState.addWater(500),
                    icon: const Icon(Icons.add),
                    label: const Text('500 مل'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => appState.addWater(-appState.waterIntakeMl),
                child: const Text('إعادة ضبط الماء اليوم', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. سجل متابعة الوزن (WeightHistoryScreen)
class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  final _newWeightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    List<FlSpot> spots = [];
    for (int i = 0; i < appState.weightHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), appState.weightHistory[i].weight));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الوزن والتقدم'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('رسم بياني لتطور الوزن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.teal,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 40),
              const Text('إدخال الوزن اليومي الجديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _newWeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الوزن الحالي (كغ)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    double? w = double.tryParse(_newWeightController.text);
                    if (w != null && w > 0) {
                      appState.updateWeight(w);
                      _newWeightController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تسجيل الوزن بنجاح')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('حفظ الوزن'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('السجلات السابقة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.weightHistory.length,
                itemBuilder: (context, index) {
                  final record = appState.weightHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.monitor_weight, color: Colors.teal),
                    title: Text('${record.weight} كغ'),
                    trailing: Text(record.date, style: const TextStyle(color: Colors.grey)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 5. نظام التنبيهات والنصائح (TipsScreen)
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نصائح الرشاقة والتغذية'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: appState.dailyTips.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appState.dailyTips[index],
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
