import 'package:flutter/material.dart';

void main() {
  runApp(const CostingApp());
}

class CostingApp extends StatelessWidget {
  const CostingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpine Printpack Ujjain Costing Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const CostingHomePage(),
    );
  }
}

class CostingHomePage extends StatefulWidget {
  const CostingHomePage({super.key});

  @override
  State<CostingHomePage> createState() => _CostingHomePageState();
}

class _CostingHomePageState extends State<CostingHomePage> {

  // -------- Film Type Density Map --------
  final Map<String, double> filmDensity = {
    "BOPP/CPP": 0.91,
    "PET": 1.40,
    "LDPE": 0.92,
  };

  // -------- Film Selections --------
  String film1 = "BOPP/CPP";
  String film2 = "PET";
  String film3 = "LDPE";

  // ---------- Layer 1 ----------
  final TextEditingController micron1 = TextEditingController();
  final TextEditingController rate1 = TextEditingController();

  // ---------- Layer 2 ----------
  final TextEditingController micron2 = TextEditingController();
  final TextEditingController rate2 = TextEditingController();

  // ---------- Layer 3 ----------
  final TextEditingController micron3 = TextEditingController();
  final TextEditingController rate3 = TextEditingController();

  // ---------- Ink / Adhesive ----------
  final TextEditingController inkGsmCtrl =
      TextEditingController(text: '1.2');
  final TextEditingController adhesiveGsmCtrl =
      TextEditingController(text: '3');

  // ---------- Wastage / Profit ----------
  final TextEditingController wastageCtrl =
      TextEditingController(text: '5');
  final TextEditingController profitCtrl =
      TextEditingController(text: '0');

  // ---------- Results ----------
  double totalGsm = 0;
  double baseCost = 0;
  double afterWastage = 0;
  double afterFixed = 0;
  double finalSelling = 0;

  void calculateCost() {
    double m1 = double.tryParse(micron1.text) ?? 0;
    double r1Val = double.tryParse(rate1.text) ?? 0;

    double m2 = double.tryParse(micron2.text) ?? 0;
    double r2Val = double.tryParse(rate2.text) ?? 0;

    double m3 = double.tryParse(micron3.text) ?? 0;
    double r3Val = double.tryParse(rate3.text) ?? 0;

    double inkGsm = double.tryParse(inkGsmCtrl.text) ?? 0;
    double adhesiveGsm = double.tryParse(adhesiveGsmCtrl.text) ?? 0;

    double wastage = double.tryParse(wastageCtrl.text) ?? 0;
    double profit = double.tryParse(profitCtrl.text) ?? 0;

    // ---------- Auto GSM using density ----------
    double gsm1 = m1 * (filmDensity[film1] ?? 0);
    double gsm2 = m2 * (filmDensity[film2] ?? 0);
    double gsm3 = m3 * (filmDensity[film3] ?? 0);

    totalGsm = gsm1 + gsm2 + gsm3 + inkGsm + adhesiveGsm;

    if (totalGsm == 0) {
      setState(() {});
      return;
    }

    // ---------- Cost Contribution ----------
    double cost1 = (gsm1 / totalGsm) * r1Val;
    double cost2 = (gsm2 / totalGsm) * r2Val;
    double cost3 = (gsm3 / totalGsm) * r3Val;

    double inkCost = (inkGsm / totalGsm) * 1400;
    double adhesiveCost = (adhesiveGsm / totalGsm) * 192;

    // ---------- Base ----------
    baseCost = cost1 + cost2 + cost3 + inkCost + adhesiveCost;

    // ---------- After Wastage ----------
    afterWastage = baseCost * (1 + wastage / 100);

    // ---------- Fixed ₹20 ----------
    afterFixed = afterWastage + 20;

    // ---------- Final Selling ----------
    finalSelling = afterFixed * (1 + profit / 100);

    setState(() {});
  }

  Widget filmLayer(String title, String film,
      void Function(String?) onFilmChange,
      TextEditingController micronCtrl,
      TextEditingController rateCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: film,
          isExpanded: true,
          items: filmDensity.keys
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onFilmChange,
        ),
        TextField(
          controller: micronCtrl,
          decoration: const InputDecoration(labelText: "Micron"),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: rateCtrl,
          decoration:
              const InputDecoration(labelText: "Rate per KG"),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Alpine Printpack Ujjain Costing Calculator"
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            filmLayer("Film Layer 1", film1,
                (v) => setState(() => film1 = v!), micron1, rate1),

            filmLayer("Film Layer 2", film2,
                (v) => setState(() => film2 = v!), micron2, rate2),

            filmLayer("Film Layer 3", film3,
                (v) => setState(() => film3 = v!), micron3, rate3),

            TextField(
              controller: inkGsmCtrl,
              decoration: const InputDecoration(labelText: "Ink GSM"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: adhesiveGsmCtrl,
              decoration:
                  const InputDecoration(labelText: "Adhesive GSM"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: wastageCtrl,
              decoration:
                  const InputDecoration(labelText: "Wastage %"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: profitCtrl,
              decoration:
                  const InputDecoration(labelText: "Profit %"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: calculateCost,
                child: const Text("CALCULATE"),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total GSM: ${totalGsm.toStringAsFixed(2)}"),
                    Text("Base Cost: ₹ ${baseCost.toStringAsFixed(2)}"),
                    Text("After Wastage: ₹ ${afterWastage.toStringAsFixed(2)}"),
                    Text("After Fixed ₹20: ₹ ${afterFixed.toStringAsFixed(2)}"),
                    const SizedBox(height: 10),
                    Text(
                      "FINAL SELLING PRICE / KG",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    Text(
                      "₹ ${finalSelling.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}