import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:StartupName/database_helpers.dart';
import 'package:StartupName/styles.dart';

class SuggestionsState extends State<Suggestions> {
  final Set<WordPair> _saved;

  SuggestionsState(this._saved);

  Future<void> _deleteItem(WordPair pair) async {
    await DatabaseHelper.instance.deleteName(pair.first, pair.second);
    setState(() {
      _saved.remove(pair);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _saved.map((WordPair pair) {
      return Dismissible(
          key: ObjectKey(pair.hashCode),
          child: ListTile(
            title: Text(
              pair.asPascalCase,
              style: biggerFont,
            ),
          ),
          onDismissed: (DismissDirection dir) async => await _deleteItem(pair));
    });
    final divided =
        ListTile.divideTiles(context: context, tiles: tiles).toList();
    return Scaffold(
        appBar: AppBar(
          title: Text('Saved suggestions'),
        ),
        body: ListView(children: divided));
  }
}

class Suggestions extends StatefulWidget {
  final Set<WordPair> saved;

  Suggestions(this.saved);

  @override
  SuggestionsState createState() => SuggestionsState(saved);
}
