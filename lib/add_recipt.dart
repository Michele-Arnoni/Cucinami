import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ingredient_card.dart';
import 'database_helper.dart';
import 'home.dart';

class AddRecipt extends StatefulWidget {
  final int? reciptId;
  final String initialName; // Sempre non null

  const AddRecipt({super.key, this.reciptId, this.initialName = ''});

  @override
  State<AddRecipt> createState() => _AddReciptState();
}

class _AddReciptState extends State<AddRecipt> {
  final TextEditingController _nomeRicettaController = TextEditingController();
  final TextEditingController _nomeIngredienteController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();
  final TextEditingController _unitaController = TextEditingController();

  final List<Map<String, dynamic>> _ingredienti = [];

  @override
  void initState() {
    super.initState();
    if (widget.reciptId != null) {
      _loadRecipt(widget.reciptId!);
    } else {
      _nomeRicettaController.text = widget.initialName;
    }
  }

  Future<void> _loadRecipt(int id) async {
    final db = DatabaseHelper.instance;
    final ricetta = await db.getReciptById(id);
    final ingredienti = await db.getIngredientsForRecipt(id);

    setState(() {
      _nomeRicettaController.text = ricetta?['name'] ?? '';
      _ingredienti.addAll(ingredienti.map((i) => {
        'nome': i['name'] ?? '',
        'quantita': i['quantity'] ?? 0.0,
        'unita': i['unitName'] ?? '',
      }));
    });
  }

  void _aggiungiIngrediente() {
    final nome = _nomeIngredienteController.text.trim();
    final quantita = double.tryParse(_quantitaController.text.trim()) ?? 0.0;
    final unita = _unitaController.text.trim();

    if (nome.isEmpty || quantita <= 0 || unita.isEmpty) return;

    setState(() {
      _ingredienti.add({
        'nome': nome,
        'quantita': quantita,
        'unita': unita,
      });
    });

    _nomeIngredienteController.clear();
    _quantitaController.clear();
    _unitaController.clear();
  }

  Future<void> _salvaRicetta() async {
    final nomeRicetta = _nomeRicettaController.text.trim();
    if (nomeRicetta.isEmpty || _ingredienti.isEmpty) return;

    final db = DatabaseHelper.instance;

    int ricettaId;
    if (widget.reciptId == null) {
      ricettaId = await db.insertRecipt(nomeRicetta);
    } else {
      ricettaId = widget.reciptId!;
      await db.updateRecipt(ricettaId, nomeRicetta);
      await db.clearIngredientsFromRecipt(ricettaId);
    }

    for (var ingrediente in _ingredienti) {
      int unitId;
      final existingUnits = await db.database.then(
            (d) => d.query(
          'UNIT',
          where: 'name = ?',
          whereArgs: [ingrediente['unita']],
        ),
      );

      if (existingUnits.isNotEmpty) {
        unitId = existingUnits.first['id'] as int;
      } else {
        unitId = await db.insertUnit(ingrediente['unita']);
      }

      final ingredientId = await db.insertIngredient(
        ingrediente['nome'],
        ingrediente['quantita'],
        unitId,
      );

      await db.addIngredientToRecipt(ricettaId, ingredientId);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home(nomeRicetta: nomeRicetta)),
    );
  }

  @override
  void dispose() {
    _nomeRicettaController.dispose();
    _nomeIngredienteController.dispose();
    _quantitaController.dispose();
    _unitaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isEditing = widget.reciptId != null;

    // 🔑 Controllo se la tastiera è aperta
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.03),
          Image.asset('lib/assets/logo.png', width: screenWidth * 0.3),
          SizedBox(height: 0.02 * screenHeight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _nomeRicettaController,
              decoration: InputDecoration(
                hintText: 'Nome ricetta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 0.02 * screenHeight),
          Text(
            "Aggiungi per ogni ingrediente la dose per una persona e la sua unità di misura.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.02 * screenHeight),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _ingredienti.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingrediente = entry.value;

                  return IngredientCard(
                    nome: ingrediente['nome'] ?? '',
                    quantita: ingrediente['quantita'] ?? 0.0,
                    unita: ingrediente['unita'] ?? '',
                    showDeleteButton: true,
                    onDelete: () {
                      setState(() {
                        _ingredienti.removeAt(index);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 0.01 * screenHeight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 0.3 * screenWidth,
                  child: TextField(
                    controller: _nomeIngredienteController,
                    decoration: InputDecoration(
                      hintText: 'Ingrediente',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(
                  width: 0.2 * screenWidth,
                  child: TextField(
                    controller: _quantitaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      hintText: 'Quantità',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(
                  width: 0.2 * screenWidth,
                  child: TextField(
                    controller: _unitaController,
                    decoration: InputDecoration(
                      hintText: 'Unità',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _aggiungiIngrediente,
                  icon: const Icon(Icons.add_circle_outline),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 32,
                ),
              ],
            ),
          ),
          SizedBox(height: 0.02 * screenHeight),

          // 🔑 Bottone che scompare quando la tastiera è aperta
          if (!keyboardOpen)
            SizedBox(
              width: 0.7 * screenWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _salvaRicetta,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEditing ? "Salva modifiche" : "Aggiungi ricetta",
                      style: TextStyle(fontSize: 0.05 * screenWidth),
                    ),
                    SizedBox(width: 0.01 * screenWidth),
                    Icon(
                      isEditing ? Icons.save : Icons.add_circle_outline,
                      size: 0.05 * screenWidth,
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
