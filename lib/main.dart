import 'package:flutter/material.dart';
import 'carte.dart';
import 'jeu_service.dart';

void main() {
  runApp(MonApplication());
}

class MonApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Roguelike',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF1B4D3E),
      ),
      home: EcranJeu(),
    );
  }
}

class EcranJeu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EcranJeuState();
  }
}

class _EcranJeuState extends State<EcranJeu> {
  JeuService service = JeuService();
  List<Carte> paquet = [];
  List<Carte> mainJoueur = [];

  int scoreManche = 0;
  int blindeObjectif = 300;
  int mainsRestantes = 4;
  int defaussesRestantes = 3;
  int argent = 0;

  String messageDernierScore = "";

  @override
  void initState() {
    super.initState();
    demarrerNouvellePartie();
  }

  void demarrerNouvellePartie() {
    paquet = service.creerPaquet();
    mainJoueur = [];
    scoreManche = 0;
    mainsRestantes = 4;
    defaussesRestantes = 3;
    messageDernierScore = "";

    piocherJusquaSept();
  }

  void piocherJusquaSept() {
    while (mainJoueur.length < 7 && paquet.isNotEmpty) {
      Carte c = paquet.removeLast();
      mainJoueur.add(c);
    }
  }

  void toucherCarte(int index) {
    setState(() {
      int nbSelectionnees = 0;
      for (int i = 0; i < mainJoueur.length; i++) {
        if (mainJoueur[i].selected) {
          nbSelectionnees++;
        }
      }

      if (mainJoueur[index].selected) {
        mainJoueur[index].selected = false;
      } else {
        if (nbSelectionnees < 5) {
          mainJoueur[index].selected = true;
        }
      }
    });
  }

  void jouer() {
    List<Carte> selectionnees = [];
    for (int i = 0; i < mainJoueur.length; i++) {
      if (mainJoueur[i].selected) {
        selectionnees.add(mainJoueur[i]);
      }
    }

    if (selectionnees.isEmpty) {
      return;
    }

    Map<String, dynamic> eval = service.evaluerMain(selectionnees);
    String nomHand = eval['nom'];
    int baseJetons = eval['jetons'];
    int baseMulti = eval['multi'];
    List<Carte> cartesQuiScoring = eval['cartesScore'];

    int totalJetons = baseJetons;
    for (int i = 0; i < cartesQuiScoring.length; i++) {
      totalJetons = totalJetons + cartesQuiScoring[i].points;
    }

    int scoreObtenu = totalJetons * baseMulti;

    setState(() {
      scoreManche = scoreManche + scoreObtenu;
      mainsRestantes = mainsRestantes - 1;
      messageDernierScore = nomHand + " : " + totalJetons.toString() + " X " + baseMulti.toString() + " = +" + scoreObtenu.toString();

      for (int i = 0; i < selectionnees.length; i++) {
        mainJoueur.remove(selectionnees[i]);
      }
      piocherJusquaSept();

      verifierFinDeManche();
    });
  }

  void defausser() {
    if (defaussesRestantes <= 0) {
      return;
    }

    List<Carte> selectionnees = [];
    for (int i = 0; i < mainJoueur.length; i++) {
      if (mainJoueur[i].selected) {
        selectionnees.add(mainJoueur[i]);
      }
    }

    if (selectionnees.isEmpty) {
      return;
    }

    setState(() {
      defaussesRestantes = defaussesRestantes - 1;
      for (int i = 0; i < selectionnees.length; i++) {
        mainJoueur.remove(selectionnees[i]);
      }
      piocherJusquaSept();
    });
  }

  void verifierFinDeManche() {
    if (scoreManche >= blindeObjectif) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Victoire !'),
            content: Text('Vous avez battu la blinde ! Score: ' + scoreManche.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    blindeObjectif = (blindeObjectif * 1.5).toInt();
                    argent = argent + 5;
                    demarrerNouvellePartie();
                  });
                },
                child: Text('Manche suivante'),
              )
            ],
          );
        },
      );
    } else if (mainsRestantes <= 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Défaite'),
            content: Text('Plus de mains disponibles !'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    blindeObjectif = 300;
                    argent = 0;
                    demarrerNouvellePartie();
                  });
                },
                child: Text('Recommencer'),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poker Roguelike'),
        backgroundColor: Color(0xFF143B30),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Color(0xFF0F2D24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('BLINDE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(blindeObjectif.toString(), style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('SCORE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(scoreManche.toString(), style: TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('MAINS', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(mainsRestantes.toString(), style: TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('DÉFAUSSES', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(defaussesRestantes.toString(), style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('PIÈCES', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(argent.toString() + ' \$', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          if (messageDernierScore.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                messageDernierScore,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Spacer(),
          Container(
            height: 140,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < mainJoueur.length; i++)
                  GestureDetector(
                    onTap: () {
                      toucherCarte(i);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      padding: EdgeInsets.only(bottom: mainJoueur[i].selected ? 20 : 0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: mainJoueur[i].selected
                              ? Border.all(color: Colors.yellow, width: 3)
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset(
                          mainJoueur[i].image,
                          width: 48,
                          height: 75,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 75,
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  mainJoueur[i].valeur.toString(),
                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: jouer,
                  child: Text('JOUER', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: defausser,
                  child: Text('DÉFAUSSER', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
