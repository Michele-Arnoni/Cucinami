import 'package:flutter/material.dart';

class IngredientCard extends StatefulWidget {
  final String nome;
  final double quantita;
  final String unita;
  final bool showDeleteButton; //sceglie se mostrare il bottone elimina, nella home non verrà mostrato
  final VoidCallback? onDelete;

  const IngredientCard({
    super.key,
    required this.nome,
    required this.quantita,
    required this.unita,
    required this.showDeleteButton,
    this.onDelete,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  @override
  Widget build(BuildContext context) {
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
          // Nome ingrediente
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.nome,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${widget.quantita} ${widget.unita}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // Pulsante elimina
          if (widget.showDeleteButton)
          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'Elimina ingrediente',
          ),
        ],
      ),
    );
  }
}
