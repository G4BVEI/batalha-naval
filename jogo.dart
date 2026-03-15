import 'dart:io';
import 'dart:math';

void main() {
  gameloop();
}

// true or false, with equal chance.(copiei da wiki flutter)
var vezAzul = Random().nextBool();
var matrizAzul = criarCampo();
var matrizVermelha = criarCampo();
bool acabou = false; //define se ja acabou
dynamic pontoazul = ""; // deixo vazio pra iterar depois
dynamic pontovermelho = "";
const red = '\x1B[31m'; // corzinha alerta terminal
const reset = '\x1B[0m'; // Reseta a cor

void gameloop() {
  lerPlacar(); //autodescritivo
  quemComeca();
  criarPonto();
  criarPonto();
  while (acabou == false) {
    atacar();
  } //ataque dos dois lados até alguem acertar
  parabens();
  updatePlacar();
}

//inicialization
criarCampo() {
  var campo = List.generate(16, (i) {
    String letra = String.fromCharCode(65 + i); // pega de A até P

    return List.generate(16, (j) {
      int numero = j + 1; // Sequência 1-16
      String numeroFormatado = numero < 10
          ? '$numero '
          : '$numero'; // adiciona espaço se for numero menor
      return '$letra$numeroFormatado';
    });
  });
  return campo;
} // cria um campo de marcação para cada jogador

void quemComeca() {
  if (vezAzul == true) {
    print("Azul começa");
  } else {
    print("Vermelho começa");
  }
}

//odeio oop mas vamo nessa
class Ponto {
  int x;
  int y;

  Ponto(this.x, this.y);
}

void criarPonto() {
  print(vezAzul ? "Azul" : "Vermelho"); //chama quem ta na vez
  print("Escolha um lugar para colocar um ponto");
  var position = getPos();
  Ponto ponto = Ponto(position[0], position[1]);
  vezDoProximo();
  print('\x1B[2J\x1B[0;0H');
  //limpa a tela pra esconder o ponto(pedi pro gpt essa)
  vezAzul ? pontoazul = ponto : pontovermelho = ponto;
  //se tiver na vez do azul o ponto é dele, se n é do vermelho
}

//funcão reutilizavel que recebe uma string e retorna a posição
getPos() {
  String Letras = "ABCDEFGHIJKLMNOP"; //pega as letras possiveis
  print("from A-P 1-16 ex: G6");
  String? position = stdin.readLineSync(); //puxa input cli
  if (position == null || position.isEmpty) {
    //se tiver vazio faz denovo
    print(red + "celula valida por favor" + reset);
    return getPos();
  }
  int x = Letras.indexOf(position[0].toUpperCase());
  if (x == -1) {
    print(red + "celula valida por favor" + reset); //se n tiver letra denovo
    return getPos();
  }
  int? y;
  try {
    y = int.parse(position.substring(1));
  } catch (e) {
    print(
      red + "celula valida por favor" + reset,
    ); //sem numero ou errado faz denovo
    return getPos();
  }
  if (y > 16) {
    print(red + "celula valida por favor" + reset); //numero invalido faz denovo
    return getPos();
  }
  return [x, y - 1]; // retorna ambos com -1 pq o index da matrix começa no 0 }
}
//game loop

void atacar() {
  print(vezAzul ? "Azul" : "Vermelho");
  print("Escolha uma casa para atacar");
  var position = getPos();
  var x = position[0];
  var y = position[1];
  var matriz = vezAzul
      ? matrizAzul
      : matrizVermelha; //ve qual matriz printa e marca
  if (matriz[x][y].length > 3) {
    print(red + "celula ja preenchida chefia" + reset); //avisa se ja ta marcada
    atacar(); //renova a função
    return;
  }
  var ponto = vezAzul ? pontoazul : pontovermelho; //verifica se acertou
  if (ponto.x == x && ponto.y == y) {
    acabou = true; //finaliza o games
  }
  matriz[x][y] = red + matriz[x][y] + reset; //aplica corzinha no texto
  printMatriz(matriz); //printa a matriz marcada
  vezDoProximo(); //passa a vez
}

//inversão de jogada reutilizavel
void vezDoProximo() {
  vezAzul = !vezAzul;
}

//placar

void lerPlacar() {
  File file = File('placar.txt'); //puxa arquivo placar.txt
  String contents = file.readAsStringSync(); //le como string
  List<String> values = contents.split(','); //separa valores
  int vitoriasAzul = int.parse(values[0]); //separa em variaveis
  int vitoriasVermelho = int.parse(values[1]);
  print("Azul ${vitoriasAzul} X ${vitoriasVermelho} Vermelho"); //printa placar
}

void updatePlacar() {
  File file = File('placar.txt'); //puxa arquivo placar.txt
  String contents = file.readAsStringSync(); //le como string
  List<String> values = contents.split(','); //separa valores
  int vitoriasAzul = int.parse(values[0]); //separa em variaveis
  int vitoriasVermelho = int.parse(values[1]);
  vezAzul
      ? vitoriasAzul++
      : vitoriasVermelho++; //puxa quem ta na vez pra ganhar ponto
  file.writeAsStringSync(
    '$vitoriasAzul,$vitoriasVermelho',
  ); // update no arquivo
  print("Azul ${vitoriasAzul} X ${vitoriasVermelho} Vermelho"); //printa
}

printMatriz(matriz) {
  for (int i = 0; i < matriz.length; i++) {
    print(matriz[i]); //printa a matriz linha por linha
  }
}

void parabens() {
  File file = File('parabens.txt'); //puxa ascii
  String parabens = file.readAsStringSync(); //le como string
  print(parabens); //printa ascii
}
