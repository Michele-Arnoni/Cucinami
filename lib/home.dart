import 'package:cucinami/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ingredient_card.dart';
import 'recipes.dart';

class Home extends StatefulWidget {
  String nomeRicetta = '';

  Home({super.key, required this.nomeRicetta});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String nomeRicetta;
  List<Map<String, dynamic>> ingredienti = [];
  double persone = 1; // numero di persone

  @override
  void initState() {
    super.initState();
    nomeRicetta = widget.nomeRicetta;
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final db = DatabaseHelper.instance;
    final results = await db.getIngredientsByRecipt(nomeRicetta);
    setState(() {
      ingredienti = results;
    });
  }

  Future<void> _selectRicetta() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Recipes()),
    );

    if (selected != null && selected is String) {
      setState(() {
        nomeRicetta = selected;
        persone = 1; // reset numero persone
      });
      _loadIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0; // controllo tastiera

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.03),
          Image.asset(
            'lib/assets/logo.png',
            width: screenWidth * 0.4,
          ),
          SizedBox(height: screenHeight * 0.03),

          // Nome della ricetta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              nomeRicetta,
              style: TextStyle(
                fontSize: 0.1 * screenWidth,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          // Campo per numero di persone
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 0.2 * screenWidth,
                  child: TextField(
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: InputDecoration(
                      hintText: '1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        persone = double.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.man),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          // Lista ingredienti con quantità calcolata per numero di persone
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: ingredienti.isEmpty
                    ? [const Center(child: Text("Nessun ingrediente trovato"))]
                    : ingredienti.map((ing) {
                  double quantitaOriginale = ing['quantity'] ?? 0;
                  double quantitaPerPersone = quantitaOriginale * persone;
                  return IngredientCard(
                    nome: ing['name'] ?? '',
                    quantita: quantitaPerPersone,
                    unita: ing['unitName'] ?? '',
                    showDeleteButton: false,
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.03),

          // Mostro il pulsante solo se la tastiera NON è visibile
          if (!isKeyboardVisible)
            SizedBox(
              width: 0.8 * screenWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _selectRicetta,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Le mie ricette",
                        style: TextStyle(fontSize: 0.05 * screenWidth)),
                    SizedBox(width: 0.01 * screenWidth),
                    Icon(
                      Icons.text_snippet_outlined,
                      size: 0.05 * screenWidth,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }
}
