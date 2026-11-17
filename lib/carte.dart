class Carte {
  String couleur;
  int valeur;
  int points;
  String image;
  bool selected = false;

  Carte(this.couleur, this.valeur, this.points, this.image);

  @override
  String toString() {
    return couleur + "_" + valeur.toString();
  }
}
