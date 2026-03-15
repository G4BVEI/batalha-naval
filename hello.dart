import 'dart:io';
import 'dart:math';

void main() {
  gameloop();
}

// true or false, with equal chance.(copiei da wiki flutter)
var vezAzul = Random().nextBool();
var matrizAzul = criarCampo();
var matrizVermelha = criarCampo();
bool acabou = false;
dynamic pontoazul = "";
dynamic pontovermelho = "";
const red = '\x1B[31m';
const reset = '\x1B[0m'; // Reseta a cor

void gameloop() {
  lerPlacar();
  quemComeca();
  criarPonto();
  criarPonto();
  while (acabou == false) {
    atacar();
  }
  parabens();
  updatePlacar();
}

criarCampo() {
  var campo = List.generate(16, (i) {
    String letra = String.fromCharCode(65 + i); // 'A'..'P'

    return List.generate(16, (j) {
      int numero = j + 1; // Sequência 1-16
      String numeroFormatado = numero < 10
          ? '$numero '
          : '$numero'; // adiciona espaço se for numero menor
      return '$letra$numeroFormatado';
    });
  });
  return campo;
}

void quemComeca() {
  if (vezAzul == true) {
    print("Azul começa");
  } else {
    print("Vermelho começa");
  }
}

void lerPlacar() {
  File file = File('placar.txt'); //puxa arquivo placar.txt
  String contents = file.readAsStringSync(); //le como string
  List<String> values = contents.split(','); //separa valores
  int vitoriasAzul = int.parse(values[0]);
  int vitoriasVermelho = int.parse(values[1]);
  print("Azul ${vitoriasAzul} X ${vitoriasVermelho} Vermelho");
}

void updatePlacar() {
  File file = File('placar.txt'); //puxa arquivo placar.txt
  String contents = file.readAsStringSync(); //le como string
  List<String> values = contents.split(','); //separa valores
  int vitoriasAzul = int.parse(values[0]);
  int vitoriasVermelho = int.parse(values[1]);
  vezAzul ? vitoriasAzul++ : vitoriasVermelho++;
  file.writeAsStringSync('$vitoriasAzul,$vitoriasVermelho'); // reescreve
  print("Azul ${vitoriasAzul} X ${vitoriasVermelho} Vermelho");
}

void clearScreen() {
  // Move o cursor para o topo e limpa a tela
  // pedi pro gpt essa
  print('\x1B[2J\x1B[0;0H');
}

//odeio oop mas vamo nessa
class Ponto {
  int x;
  int y;

  Ponto(this.x, this.y);
}

void criarPonto() {
  print(vezAzul ? "Azul:" : "Vermelho");
  print("choose a place to create a point");
  var position = getPos();
  Ponto ponto = Ponto(position[0], position[1]);
  vezDoProximo();
  clearScreen();
  vezAzul ? pontoazul = ponto : pontovermelho = ponto;
}

printMatriz(matriz) {
  for (int i = 0; i < matriz.length; i++) {
    print(matriz[i]);
  }
}

void atacar() {
  print(vezAzul ? "Azul" : "Vermelho");
  print("Escolha uma casa para atacar");
  var position = getPos();
  var x = position[0];
  var y = position[1];
  var matriz = vezAzul ? matrizAzul : matrizVermelha;
  if (matriz[x][y].length > 3) {
    print(red + "celula ja preenchida chefia" + reset);
    atacar();
    return;
  }
  var ponto = vezAzul ? pontoazul : pontovermelho;
  if (ponto.x == x && ponto.y == y) {
    acabou = true;
  }
  matriz[x][y] = red + matriz[x][y] + reset;
  printMatriz(matriz);
  vezDoProximo();
}

//inversão de jogada reutilizavel
void vezDoProximo() {
  vezAzul = !vezAzul;
}

//funcão reutilizavel que recebe uma string e retorna a posição
getPos() {
  String Letras = "ABCDEFGHIJKLMNOP";
  while (true) {
    print("from A-P 1-16 ex: G6");
    String? position = stdin.readLineSync();
    if (position == null || position.isEmpty) continue;
    int x = Letras.indexOf(position[0].toUpperCase());
    if (x == -1) continue;
    int y;
    try {
      y = int.parse(position.substring(1));
    } catch (e) {
      continue;
    }
    if (y < 1 || y > 16) continue;
    return [x, y - 1];
  }
}

void parabens() {
  File file = File('parabens.txt'); //puxa arquivo placar.txt
  String parabens = file.readAsStringSync(); //le como string
  print(parabens);
}
