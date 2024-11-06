import 'dart:io';
import 'dart:math';

class Character { // 캐릭터 클래스: 이름, 체력, 공격력, 방어력
  String name; // 이름은 입력받을 것
  int health;
  int attack;
  int defense;

  Character(this.name, this.health, this.attack, this.defense);

  void showStatus() {
    print('캐릭터 상태 - 이름: $name, 체력: $health, 공격력: $attack, 방어력: $defense');
  }
}

class Monster {
  String name;
  int health;
  int maxAttack;
  int defense = 0;

  Monster(this.name, this.health, this.maxAttack);

  void showStatus() {
    print('몬스터 상태 - 이름: $name, 체력: $health, 공격력: $maxAttack');
  }
}


Character loadCharacter(String name) { // 캐릭터 정보 파일에서 불러오는 함수
  try {
    final file = File('C:\\Users\\KGE\\dart\\characters.txt');
    final contents = file.readAsStringSync();
    final stats = contents.split(','); // 데이터 파일 형식은 CSV
    
    if (stats.length != 3) throw FormatException('Invalid character data');

    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);

    return Character(name, health, attack, defense);
  } catch (e) {
    print('캐릭터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
}
List<Monster> loadMonsters() {
  List<Monster> monsters = [];
  try {
    final file = File('C:\\Users\\KGE\\dart\\monsters.txt');
    final lines = file.readAsLinesSync();
    for (var line in lines) {
      var stats = line.split(',');
      var name = stats[0];
      int health = int.parse(stats[1]);
      int maxAttack = int.parse(stats[2]);
      monsters.add(Monster(name, health, maxAttack));
    }
  } catch (e) {
    print('몬스터 데이터를 불러오는 데 실패했습니다: $e');
    exit(1);
  }
  return monsters;
}


String getCharacterName() {//캐릭터 이름 입력받는 함수
  while (true) {
    print('캐릭터의 이름을 입력하세요:');
    String name = stdin.readLineSync() ?? '';
    if (name.isNotEmpty && RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
      return name;
    } else {
      print('올바른 이름을 입력하세요.');
    }
  }
}

void main() {
  String name = getCharacterName();
  Character character = loadCharacter(name); // 캐릭터 데이터 불러오기
  character.showStatus(); // 캐릭터 상태 출력
  List<Monster> monsters = loadMonsters();
  for (var monster in monsters) {
    monster.showStatus(); // 몬스터 데이터 불러와지는지 확인
  }
}