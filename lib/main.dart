import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:StartupName/database_helpers.dart';
import 'package:StartupName/styles.dart';
import 'package:StartupName/suggestions.dart';

void main() => runApp(App());

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();

  RandomWordsState() {
    DatabaseHelper.instance.queryAllNames().then((names) {
      var wordPairs = names.map((name) => name.toWordPair());
      setState(() {
        _suggestions.insertAll(0, wordPairs);
        _saved.addAll(wordPairs);
      });
    });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: biggerFont,
      ),
      trailing: IconButton(
        icon: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onPressed: () async {
          var name = Name.fromWordPair(pair);
          if (alreadySaved) {
            await DatabaseHelper.instance.deleteName(name.first, name.second);
          } else {
            await DatabaseHelper.instance.insert(name);
          }

          setState(() {
            if (alreadySaved) {
              _saved.remove(pair);
            } else {
              _saved.add(pair);
            }
          });
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index]);
        });
  }

  void _pushSaved() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Suggestions(_saved)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Padding(
            padding: EdgeInsets.only(left: 14.0),
            child: Text('Startup Name Generator')),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: IconButton(icon: Icon(Icons.history), onPressed: _pushSaved),
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator',
      home: RandomWords(),
      theme: ThemeData(primaryColor: Colors.green),
    );
  }
}
