import 'dart:io';
import 'dart:convert';

void main() {
  stdin.echoMode = false;
  stdin.lineMode = false;

  print('Press WASD to move, q to quit');

  stdin.listen((data) {
    final key = utf8.decode(data);

    switch (key) {
      case 'w':
        print('Move up');
        break;
      case 'a':
        print('Move left');
        break;
      case 's':
        print('Move down');
        break;
      case 'd':
        print('Move right');
        break;
      case 'q':
        exit(0);
    }
  });
}
