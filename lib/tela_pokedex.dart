import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pokedex extends StatefulWidget {
  @override
  _PokedexState createState() => _PokedexState();
}

class _PokedexState extends State<Pokedex> {
  List<dynamic> pokemonList = [];

  @override
  void initState() {
    super.initState();
    _loadPokemonList();
  }

  Future<void> _loadPokemonList() async {
    final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=150'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pokemonList = data['results'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = pokemonList[index];
          return ListTile(
            leading: Image.network(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${index + 1}.png',
            ),
            title: Text(pokemon['name']),
            onTap: () {
              _showPokemonDetails(pokemon['name'], index + 1);
            },
          );
        },
      ),
    );
  }

  void _showPokemonDetails(String pokemonName, int pokemonId) async {
    final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final height = data['height'];
      final weight = data['weight'];
      final abilities = data['abilities'];
      final types = data['types'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetails(
            pokemonName: pokemonName,
            height: height,
            weight: weight,
            abilities: abilities,
            types: types,
            pokemonImage: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png',
          ),
        ),
      );
    }
  }
}

class PokemonDetails extends StatelessWidget {
  final String pokemonName;
  final int height;
  final int weight;
  final List<dynamic> abilities;
  final List<dynamic> types;
  final String pokemonImage;

  PokemonDetails({
    required this.pokemonName,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.types,
    required this.pokemonImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Pokémon'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 5, // Adicione sombra ao card
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.network(
                    pokemonImage,
                    width: 200, // Defina o tamanho da imagem
                    height: 200,
                  ),
                  Text('Nome do Pokémon: $pokemonName'),
                  Text('Altura: $height'),
                  Text('Peso: $weight'),
                  Text('Habilidades: ${abilities.map((ability) => ability['ability']['name']).join(', ')}'),
                  Text('Tipos: ${types.map((type) => type['type']['name']).join(', ')}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
