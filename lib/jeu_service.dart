import 'carte.dart';

class JeuService {
  List<Carte> creerPaquet() {
    List<Carte> paquet = [];
    List<String> couleurs = ['club', 'diamond', 'heart', 'spade'];

    for (int i = 0; i < couleurs.length; i++) {
      String c = couleurs[i];
      for (int v = 1; v <= 13; v++) {
        int pts = v;
        if (v == 1) {
          pts = 11;
        } else if (v > 10) {
          pts = 10;
        }
        String img = "assets/cartes/" + c + "_" + v.toString() + ".png";
        Carte carte = Carte(c, v, pts, img);
        paquet.add(carte);
      }
    }
    paquet.shuffle();
    return paquet;
  }

  Map<String, dynamic> evaluerMain(List<Carte> cartesJouees) {
    if (cartesJouees.isEmpty) {
      return {'nom': 'Rien', 'jetons': 0, 'multi': 0, 'cartesScore': <Carte>[]};
    }

    Map<int, int> occValeurs = {};
    for (int i = 0; i < cartesJouees.length; i++) {
      int val = cartesJouees[i].valeur;
      if (occValeurs.containsKey(val)) {
        occValeurs[val] = occValeurs[val]! + 1;
      } else {
        occValeurs[val] = 1;
      }
    }

    Map<String, int> occCouleurs = {};
    for (int i = 0; i < cartesJouees.length; i++) {
      String c = cartesJouees[i].couleur;
      if (occCouleurs.containsKey(c)) {
        occCouleurs[c] = occCouleurs[c]! + 1;
      } else {
        occCouleurs[c] = 1;
      }
    }

    bool isCouleur = false;
    for (String c in occCouleurs.keys) {
      if (occCouleurs[c] == 5) {
        isCouleur = true;
      }
    }

    bool isSuite = false;
    if (cartesJouees.length == 5) {
      List<int> vals = [];
      for (int i = 0; i < cartesJouees.length; i++) {
        vals.add(cartesJouees[i].valeur);
      }
      vals.sort();

      if (vals[0] + 1 == vals[1] &&
          vals[1] + 1 == vals[2] &&
          vals[2] + 1 == vals[3] &&
          vals[3] + 1 == vals[4]) {
        isSuite = true;
      } else if (vals[0] == 1 &&
          vals[1] == 10 &&
          vals[2] == 11 &&
          vals[3] == 12 &&
          vals[4] == 13) {
        isSuite = true;
      }
    }

    int nbCarre = 0;
    int valCarre = 0;
    int nbBrelan = 0;
    int valBrelan = 0;
    int nbPaires = 0;
    List<int> valsPaires = [];

    for (int v in occValeurs.keys) {
      int count = occValeurs[v]!;
      if (count == 4) {
        nbCarre++;
        valCarre = v;
      } else if (count == 3) {
        nbBrelan++;
        valBrelan = v;
      } else if (count == 2) {
        nbPaires++;
        valsPaires.add(v);
      }
    }

    if (isSuite && isCouleur) {
      List<int> vals = [];
      for (int i = 0; i < cartesJouees.length; i++) {
        vals.add(cartesJouees[i].valeur);
      }
      vals.sort();
      if (vals.contains(1) && vals.contains(10) && vals.contains(13)) {
        return {
          'nom': 'Quinte flush royale',
          'jetons': 100,
          'multi': 10,
          'cartesScore': cartesJouees,
        };
      } else {
        return {
          'nom': 'Quinte flush',
          'jetons': 100,
          'multi': 8,
          'cartesScore': cartesJouees,
        };
      }
    }

    if (nbCarre == 1) {
      List<Carte> scoreList = [];
      for (int i = 0; i < cartesJouees.length; i++) {
        if (cartesJouees[i].valeur == valCarre) {
          scoreList.add(cartesJouees[i]);
        }
      }
      return {
        'nom': 'Carré',
        'jetons': 60,
        'multi': 7,
        'cartesScore': scoreList,
      };
    }

    if (nbBrelan == 1 && nbPaires >= 1) {
      List<Carte> scoreList = [];
      int valPaire = valsPaires[0];
      for (int i = 0; i < cartesJouees.length; i++) {
        if (cartesJouees[i].valeur == valBrelan || cartesJouees[i].valeur == valPaire) {
          scoreList.add(cartesJouees[i]);
        }
      }
      return {
        'nom': 'Main pleine',
        'jetons': 40,
        'multi': 4,
        'cartesScore': scoreList,
      };
    }

    if (isCouleur) {
      return {
        'nom': 'Couleur',
        'jetons': 35,
        'multi': 4,
        'cartesScore': cartesJouees,
      };
    }

    if (isSuite) {
      return {
        'nom': 'Suite',
        'jetons': 30,
        'multi': 4,
        'cartesScore': cartesJouees,
      };
    }

    if (nbBrelan == 1) {
      List<Carte> scoreList = [];
      for (int i = 0; i < cartesJouees.length; i++) {
        if (cartesJouees[i].valeur == valBrelan) {
          scoreList.add(cartesJouees[i]);
        }
      }
      return {
        'nom': 'Brelan',
        'jetons': 30,
        'multi': 3,
        'cartesScore': scoreList,
      };
    }

    if (nbPaires >= 2) {
      List<Carte> scoreList = [];
      int p1 = valsPaires[0];
      int p2 = valsPaires[1];
      for (int i = 0; i < cartesJouees.length; i++) {
        if (cartesJouees[i].valeur == p1 || cartesJouees[i].valeur == p2) {
          scoreList.add(cartesJouees[i]);
        }
      }
      return {
        'nom': 'Double paire',
        'jetons': 20,
        'multi': 2,
        'cartesScore': scoreList,
      };
    }

    if (nbPaires == 1) {
      List<Carte> scoreList = [];
      int p1 = valsPaires[0];
      for (int i = 0; i < cartesJouees.length; i++) {
        if (cartesJouees[i].valeur == p1) {
          scoreList.add(cartesJouees[i]);
        }
      }
      return {
        'nom': 'Paire',
        'jetons': 10,
        'multi': 2,
        'cartesScore': scoreList,
      };
    }

    Carte plusHaute = cartesJouees[0];
    for (int i = 1; i < cartesJouees.length; i++) {
      int valCourante = cartesJouees[i].valeur;
      int valMax = plusHaute.valeur;
      if (valCourante == 1) {
        valCourante = 14;
      }
      if (valMax == 1) {
        valMax = 14;
      }
      if (valCourante > valMax) {
        plusHaute = cartesJouees[i];
      }
    }
    return {
      'nom': 'Carte haute',
      'jetons': 5,
      'multi': 1,
      'cartesScore': [plusHaute],
    };
  }
}
