import 'dart:io';
import 'dart:math';

void main() {
  gameloop();
}

var vezAzul = Random().nextBool();
var matrizAzul = criarCampo();
var matrizVermelha = criarCampo();
bool acabou = false;

// Cada jogador agora tem uma lista de pontos (navio) e uma lista de acertos
List<Ponto> navioAzul = [];
List<Ponto> navioVermelho = [];
List<Ponto> acertosAzul = [];
List<Ponto> acertosVermelho = [];

const blue = '\x1B[34m';
const red = '\x1B[31m';
const reset = '\x1B[0m';

void gameloop() {
  lerPlacar();
  quemComeca();

  // Cada jogador posiciona seu navio de 3 pontos
  criarPonto(); // Primeiro jogador
  criarPonto(); // Segundo jogador

  // Fase de ataque
  while (!acabou) {
    atacar();
  }

  parabens();
  updatePlacar();
}

// Inicialização da matriz
criarCampo() {
  return List.generate(16, (i) {
    String letra = String.fromCharCode(65 + i);
    return List.generate(16, (j) {
      int numero = j + 1;
      String numeroFormatado = numero < 10 ? '$numero ' : '$numero';
      return '$letra$numeroFormatado';
    });
  });
}

void quemComeca() {
  print(vezAzul ? "Azul começa" : "Vermelho começa");
}

// Classe Ponto
class Ponto {
  int x;
  int y;
  Ponto(this.x, this.y);
}

// Criar navio (mantendo função criarPonto)
void criarPonto() {
  print(vezAzul ? "Azul" : "Vermelho");
  print("Escolha a posição inicial do navio de 3 casas (ex: B5):");
  var posInicial = getPos();

  print("Escolha a orientação: H (horizontal) ou V (vertical)");
  String? orientacao = stdin.readLineSync()?.toUpperCase();
  if (orientacao != "H" && orientacao != "V") {
    print(red + "Orientação inválida" + reset);
    return criarPonto();
  }

  List<Ponto> navio = [];

  for (int i = 0; i < 3; i++) {
    int x = posInicial[0];
    int y = posInicial[1];
    if (orientacao == "H") y += i;
    if (orientacao == "V") x += i;

    if (x >= 16 || y >= 16) {
      print(red + "Navio não cabe aqui, escolha outra posição" + reset);
      return criarPonto();
    }

    // Checa sobreposição
    List<Ponto> navioAtual = vezAzul ? navioAzul : navioVermelho;
    for (var p in navioAtual) {
      if (p.x == x && p.y == y) {
        print(red + "Navio se sobrepõe a outro, escolha outra posição" + reset);
        return criarPonto();
      }
    }

    navio.add(Ponto(x, y));
  }

  if (vezAzul) {
    navioAzul = navio;
  } else {
    navioVermelho = navio;
  }

  print('\x1B[2J\x1B[0;0H'); // limpa tela
  vezDoProximo();
}

// Função para pegar input e converter para coordenadas
getPos() {
  String Letras = "ABCDEFGHIJKLMNOP";
  print("from A-P 1-16 ex: G6");
  String? position = stdin.readLineSync();
  if (position == null || position.isEmpty) {
    print(red + "celula valida por favor" + reset);
    return getPos();
  }

  int x = Letras.indexOf(position[0].toUpperCase());
  if (x == -1) {
    print(red + "celula valida por favor" + reset);
    return getPos();
  }

  int? y;
  try {
    y = int.parse(position.substring(1));
  } catch (e) {
    print(red + "celula valida por favor" + reset);
    return getPos();
  }

  if (y > 16) {
    print(red + "celula valida por favor" + reset);
    return getPos();
  }

  return [x, y - 1];
}

// Ataque
void atacar() {
  stdout.write('\x1B[2J\x1B[0;0H');
  print(vezAzul ? "Azul" : "Vermelho");
  print("Escolha uma casa para atacar");
  var pos = getPos();
  int x = pos[0];
  int y = pos[1];

  var matriz = vezAzul ? matrizAzul : matrizVermelha;
  if (matriz[x][y].contains(blue) || matriz[x][y].contains(red)) {
    print(red + "Celula já atacada" + reset);
    atacar();
    return;
  }

  List<Ponto> navioAlvo = vezAzul ? navioVermelho : navioAzul;
  List<Ponto> acertos = vezAzul ? acertosAzul : acertosVermelho;

  bool acertou = false;

  for (var p in navioAlvo) {
    if (p.x == x && p.y == y) {
      acertou = true;
      if (!acertos.any((ap) => ap.x == x && ap.y == y)) {
        acertos.add(Ponto(x, y));
      }
      break;
    }
  }

  if (acertou) {
    print(blue + "Acertou!" + reset);
    matriz[x][y] = blue + matriz[x][y] + reset;
    if (acertos.length == 3) {
      print(blue + (vezAzul ? "Azul" : "Vermelho") + " venceu!" + reset);
      acabou = true;
    }
  } else {
    print(red + "Água!" + reset);
    matriz[x][y] = red + matriz[x][y] + reset;
  }

  printMatriz(matriz);

  // Espera o jogador apertar Enter antes de passar a vez
  print("\nPressione Enter para passar a vez...");
  stdin.readLineSync();

  vezDoProximo();
}

void vezDoProximo() {
  vezAzul = !vezAzul;
}

// Placar
void lerPlacar() {
  File file = File('placar.txt');
  String contents = file.readAsStringSync();
  List<String> values = contents.split(',');
  int vitoriasAzul = int.parse(values[0]);
  int vitoriasVermelho = int.parse(values[1]);
  print("Azul $vitoriasAzul X $vitoriasVermelho Vermelho");
}

void updatePlacar() {
  File file = File('placar.txt');
  String contents = file.readAsStringSync();
  List<String> values = contents.split(',');
  int vitoriasAzul = int.parse(values[0]);
  int vitoriasVermelho = int.parse(values[1]);
  vezAzul ? vitoriasAzul++ : vitoriasVermelho++;
  file.writeAsStringSync('$vitoriasAzul,$vitoriasVermelho');
  print("Azul $vitoriasAzul X $vitoriasVermelho Vermelho");
}

printMatriz(matriz) {
  for (int i = 0; i < matriz.length; i++) {
    print(matriz[i]);
  }
}

void parabens() {
  print('''
    ██╗   ██╗██╗████████╗ ██████╗ ██████╗ ██╗ █████╗ ██╗
    ██║   ██║██║╚══██╔══╝██╔═══██╗██╔══██╗██║██╔══██╗██║
    ██║   ██║██║   ██║   ██║   ██║██████╔╝██║███████║██║
    ╚██╗ ██╔╝██║   ██║   ██║   ██║██╔══██╗██║██╔══██║╚═╝
     ╚████╔╝ ██║   ██║   ╚██████╔╝██║  ██║██║██║  ██║██╗
      ╚═══╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝
    ''');
}
