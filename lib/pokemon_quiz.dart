import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class PokemonQuiz extends StatefulWidget {
  @override
  _PokemonQuizState createState() => _PokemonQuizState();
}

class _PokemonQuizState extends State<PokemonQuiz> {
  List<String> pokemonList = [];
  String correctPokemon = "";
  int score = 0;
  int questionsAnswered = 0;
  List<String> questionOptions = [];

  _PokemonQuizState() {
    _loadPokemonList();
  }

  void _loadPokemonList() async {
    final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=150'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      pokemonList = List<String>.from(data['results'].map((pokemon) => pokemon['name']));
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    if (questionsAnswered < 10) {
      final random = Random();
      correctPokemon = pokemonList[random.nextInt(pokemonList.length)];

      questionOptions = [];
      questionOptions.add(correctPokemon);

      for (int i = 0; i < 3; i++) {
        String option;
        do {
          option = pokemonList[random.nextInt(pokemonList.length)];
        } while (questionOptions.contains(option));
        questionOptions.add(option);
      }

      questionOptions.shuffle();

      setState(() {
        score = score;
        questionsAnswered++;
      });
    } else {
      _showSummaryScreen();
    }
  }

  void _showSummaryScreen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Complete'),
          content: Text('You scored $score out of 10.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  score = 0;
                  questionsAnswered = 0;
                });
                _nextQuestion();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokemon Quiz',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Arial',
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Score: $score / 10',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemonList.indexOf(correctPokemon) + 1}.png',
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: questionOptions.map((option) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              if (option == correctPokemon) {
                                score++;
                                Fluttertoast.showToast(
                                  msg: "Acertou!",
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Errou. A resposta correta era $correctPokemon.",
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                );
                              }
                              _nextQuestion();
                            },
                            child: Text(
                              option.toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              fixedSize: Size(200, 50),
                              elevation: 0,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Pergunta ${questionsAnswered + 0}/10',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
