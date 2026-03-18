import 'dart:io';
import 'dart:math';

const reset = '\x1B[0m';
const red = '\x1B[31m';
const blue = '\x1B[34m';
const green = '\x1B[32m';
const yellowBg = '\x1B[43m';
const brightBlack = '\x1B[90m'; // Erro/Ocupado

bool vezAzul = Random().nextBool();
bool acabou = false;

List<List<String>> matrizAzul = criarCampoVazio();
List<List<String>> matrizVermelha = criarCampoVazio();

List<List<Ponto>> naviosAzul = [];
List<List<Ponto>> naviosVermelho = [];

class Ponto {
  int x;
  int y;
  bool isBlue;
  Ponto(this.x, this.y, this.isBlue);
}

void main() {
  // Título ASCII Inicial
  stdout.write('\x1B[2J\x1B[0;0H');
  print('''$blue
  ██████╗ ██╗      █████╗  ██████╗ █████╗ ██████╗
  ██╔══██╗██║     ██╔══██╗██╔════╝██╔══██╗██╔══██╗
  ██████╔╝██║     ███████║██║     ███████║██████╔╝
  ██╔═══╝ ██║     ██╔══██║██║     ██╔══██║██╔══██╗
  ██║     ███████╗██║  ██║╚██████╗██║  ██║██║  ██║
  ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝$reset''');

  lerPlacar();
  quemComeca();

  print("\nPressione Enter para iniciar o posicionamento...");
  stdin.readLineSync();

  // Posicionamento
  vezAzul = true;
  colocarNaviosInterativo(true);

  print('\x1B[2J\x1B[0;0H');
  print('$red--- VEZ DO VERMELHO ---$reset');
  print('Chame o próximo jogador e pressione Enter...');
  stdin.readLineSync();

  vezAzul = false;
  colocarNaviosInterativo(false);

  vezAzul = Random().nextBool();
  gameLoop();
}

List<List<String>> criarCampoVazio() =>
    List.generate(16, (_) => List.generate(16, (_) => ' . '));

void lerPlacar() {
  File file = File('placar.txt');
  if (!file.existsSync()) file.writeAsStringSync('0,0');
  var v = file.readAsStringSync().split(',');
  print("\n🏆 PLACAR: ${blue}Azul ${v[0]}$reset X ${red}${v[1]} Vermelho$reset");
}

void updatePlacar() {
  File file = File('placar.txt');
  String contents = file.readAsStringSync();
  List<String> values = contents.split(',');
  int vitoriasAzul = int.parse(values[0]);
  int vitoriasVermelho = int.parse(values[1]);

  // Quem ganhou foi quem deu o último tiro (vezAzul atual)
  vezAzul ? vitoriasAzul++ : vitoriasVermelho++;

  file.writeAsStringSync('$vitoriasAzul,$vitoriasVermelho');
  print("\n🔥 PLACAR FINAL: ${blue}Azul $vitoriasAzul$reset X ${red}$vitoriasVermelho Vermelho$reset");
}

void quemComeca() {
  print(vezAzul ? '$blue Azul começa$reset' : '$red Vermelho começa$reset');
}

void vezDoProximo() => vezAzul = !vezAzul;

void colocarNaviosInterativo(bool azul) {
  var navios = azul ? naviosAzul : naviosVermelho;
  var matriz = azul ? matrizAzul : matrizVermelha;

  for (int n = 0; n < 3; n++) {
    while (true) {
      var result = selecionarPosicao(
        matriz,
        azul ? blue : red,
        3,
        navios,
        true,
        posicionando: true,
      );
      var inicio = result.item1;
      var dir = result.item2;

      List<Ponto> navio = [];
      bool valido = true;

      for (int i = 0; i < 3; i++) {
        int x = inicio.x + (dir == 'v' ? i : 0);
        int y = inicio.y + (dir == 'h' ? i : 0);

        if (x >= 16 || y >= 16 || navios.any((nav) => nav.any((p) => p.x == x && p.y == y))) {
          valido = false;
          break;
        }
        navio.add(Ponto(x, y, azul));
      }

      if (valido) {
        navios.add(navio);
        for (var p in navio) {
          matriz[p.x][p.y] = (azul ? blue : red) + '██' + reset;
        }
        break;
      }
    }
  }
}

void gameLoop() {
  while (!acabou) {
    atacarInterativo();
  }
  parabens();
  updatePlacar();
}

void atacarInterativo() {
  var matrizInimiga = vezAzul ? matrizVermelha : matrizAzul;
  var naviosInimigos = vezAzul ? naviosVermelho : naviosAzul;

  var alvo = selecionarPosicao(
    matrizInimiga,
    yellowBg,
    1,
    naviosInimigos,
    false,
  ).item1;

  bool acertou = naviosInimigos.any(
    (nav) => nav.any((p) => p.x == alvo.x && p.y == alvo.y),
  );

  matrizInimiga[alvo.x][alvo.y] = (acertou ? green : brightBlack) + '██' + reset;

  desenharMatrizSimples(matrizInimiga, false);

  if (acertou &&
      naviosInimigos.every(
        (nav) => nav.every((p) => matrizInimiga[p.x][p.y].contains(green)),
      )) {
    print(green + "\nDESTROU O ÚLTIMO NAVIO!" + reset);
    acabou = true;
  } else {
    print(acertou ? green + "\nACERTOU!" : red + "\nÁGUA...");
    print("Pressione ENTER para passar a vez...");
    stdin.readLineSync();
    vezDoProximo();
  }
}

void desenharMatrizSimples(List<List<String>> matriz, bool mostrarNaviosOcultos) {
  stdout.write('\x1B[2J\x1B[0;0H');
  print('>>> RESULTADO DO ATAQUE: ${vezAzul ? blue + "AZUL" : red + "VERMELHO"}$reset\n\n');
  for (int i = 0; i < matriz.length; i++) {
    for (int j = 0; j < matriz[i].length; j++) {
      String celula = matriz[i][j];
      if (celula.contains('\x1B[')) {
        if (!mostrarNaviosOcultos && (celula.contains(blue) || celula.contains(red)) && !celula.contains(green)) {
          stdout.write(' . ');
        } else {
          stdout.write('$celula ');
        }
      } else {
        stdout.write(' . ');
      }
    }
    print('');
  }
}

Tuple2<Ponto, String> selecionarPosicao(
  List<List<String>> matriz,
  String corCursor,
  int tamanhoNavio,
  List<List<Ponto>> naviosExistentes,
  bool mostrarNaviosOcultos, {
  bool posicionando = false,
}) {
  int cursorX = 0;
  int cursorY = 0;
  String dir = 'h';
  bool confirmou = false;

  stdin.lineMode = false;
  stdin.echoMode = false;

  while (!confirmou) {
    stdout.write('\x1B[2J\x1B[0;0H');
    String acao = posicionando ? "POSICIONANDO" : "ATACANDO";
    print('>>> $acao: ${vezAzul ? blue + "AZUL" : red + "VERMELHO"}$reset');
    print('WASD: Mover | H/V: Girar | ENTER: Confirmar | Q: Sair\n');

    bool posicaoInvalidaParaAtaque = false;

    for (int i = 0; i < matriz.length; i++) {
      for (int j = 0; j < matriz[i].length; j++) {
        bool sobCursor = false;
        for (int k = 0; k < tamanhoNavio; k++) {
          int nx = cursorX + (dir == 'v' ? k : 0);
          int ny = cursorY + (dir == 'h' ? k : 0);
          if (i == nx && j == ny) {
            sobCursor = true;
            if (!posicionando && (matriz[i][j].contains(green) || matriz[i][j].contains(brightBlack))) {
              posicaoInvalidaParaAtaque = true;
            }
          }
        }

        if (sobCursor) {
          stdout.write('${posicaoInvalidaParaAtaque ? brightBlack : corCursor}██$reset ');
        } else {
          String celula = matriz[i][j];
          if (celula.contains('\x1B[')) {
            if (!mostrarNaviosOcultos && (celula.contains(blue) || celula.contains(red)) && !celula.contains(green)) {
              stdout.write(' . ');
            } else {
              stdout.write('$celula ');
            }
          } else {
            stdout.write(' . ');
          }
        }
      }
      print('');
    }

    int key = stdin.readByteSync();
    if (key == 119 && cursorX > 0) cursorX--;
    if (key == 115 && cursorX < 15) cursorX++;
    if (key == 97 && cursorY > 0) cursorY--;
    if (key == 100 && cursorY < 15) cursorY++;
    if (key == 104) dir = 'h';
    if (key == 118) dir = 'v';
    if (key == 113) exit(0);
    if (key == 10 || key == 13) {
      if (!posicaoInvalidaParaAtaque) confirmou = true;
    }
  }

  stdin.lineMode = true;
  stdin.echoMode = true;
  return Tuple2(Ponto(cursorX, cursorY, vezAzul), dir);
}

void parabens() {
  File file = File('parabens.txt');
  if (file.existsSync()) {
    print(file.readAsStringSync());
  } else {
    print(green + "\n--- PARABÉNS VENCEDOR! ---" + reset);
  }
}

class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}
