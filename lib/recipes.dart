import 'package:cucinami/home.dart';
import 'package:flutter/material.dart';
import 'package:cucinami/add_recipt.dart';
import 'package:cucinami/database_helper.dart';
import 'package:cucinami/recipt_card.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  List<Map<String, dynamic>> _recipts = [];

  @override
  void initState() {
    super.initState();
    _loadRecipts();
  }

  Future<void> _loadRecipts() async {
    final data = await DatabaseHelper.instance.getAllRecipts();
    setState(() {
      _recipts = data;
    });
  }

  Future<void> _deleteRecipt(int id) async {
    await DatabaseHelper.instance.deleteRecipt(id);
    _loadRecipts(); // aggiorna lista dopo eliminazione
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: screenHeight*0.03),
          // Logo
          Image.asset(
            'lib/assets/logo.png',
            width: screenWidth * 0.3,
          ),
          SizedBox(height: 0.05 * screenHeight),

          // Lista ricette con scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _recipts.isEmpty
                    ? [const Center(child: Text("Nessuna ricetta trovata"))]
                    : _recipts.map((recipt) {
                  return ReciptCard(
                    id: recipt['id'],
                    nome: recipt['name'],
                    onNameTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(nomeRicetta: recipt['name']),
                        ),
                      );
                    },
                    onDeleteTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Conferma eliminazione"),
                            content: const Text("Sei sicuro di voler eliminare questa ricetta?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Annulla"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Elimina"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        _deleteRecipt(recipt['id']);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 0.05 * screenHeight),

          // Bottone aggiungi ricetta
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
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddRecipt()),
                );
                _loadRecipts(); // aggiorna lista dopo aggiunta
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Aggiungi ricetta", style: TextStyle(fontSize: 0.05 * screenWidth)),
                  SizedBox(width: 0.01 * screenWidth),
                  Icon(Icons.add_circle_outline, size: 0.05 * screenWidth),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight*0.03),
        ],
      ),
    );
  }
}
