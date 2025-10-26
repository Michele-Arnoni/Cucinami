import 'package:cucinami/add_recipt.dart';
import 'package:flutter/material.dart';

class ReciptCard extends StatelessWidget {
  final int id;
  final String? nome;
  final VoidCallback? onNameTap;
  final VoidCallback? onDeleteTap;

  const ReciptCard({
    super.key,
    required this.id,
    this.nome,
    this.onNameTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Se il nome è null, usare stringa vuota
    final displayName = nome ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nome ricetta tappabile
          TextButton(
            onPressed: onNameTap ?? () => print("Nome premuto"),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              displayName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bottoni azione (modifica + elimina)
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddRecipt(
                        reciptId: id,
                        initialName: displayName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Modifica',
              ),
              IconButton(
                onPressed: onDeleteTap ?? () => print("Elimina premuto"),
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.error,
                tooltip: 'Elimina',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
