  import 'dart:io';
  import 'dart:math';

  class Game {//게임 진행 방식 정의
    Character character;
    List<Monster> monsters;
    int defeatedMonsters = 0;

    Game(this.character, this.monsters);

    void startGame() {//게임을 시작하고 종료하는 메서드
      while (character.health > 0 && monsters.isNotEmpty) {
        battle();
        if (character.health <= 0) {//캐릭터 체력 0되면 종료
          print("캐릭터가 쓰러졌습니다. 게임 종료.");
          saveResult(character, "패배");
          break;
        }
        if (monsters.isEmpty) {
          print("모든 몬스터를 물리쳤습니다. 승리!");
          saveResult(character, "승리");
          break;
        }
        print(" ");
        print("다음 몬스터와 싸우시겠습니까? (y/n)");
        String choice = stdin.readLineSync() ?? 'n';
        if (choice.toLowerCase() != 'y') {
          break;
        }
      }
    }

    void battle() {//전투 진행: 1이면 공격, 2이면 방어
      Monster monster = getRandomMonster();
      print("새로운 몬스터가 나타났습니다!");
      monster.showStatus(); // 새로운 몬스터의 정보를 출력

      while (monster.health > 0 && character.health > 0) {
        print(" ");
        print("${character.name}의 턴");
        print("행동을 선택하세요 (1: 공격, 2: 방어)");//행동 선택
        String choice = stdin.readLineSync() ?? '1';
        if (choice == '1') {//공격
          character.attackMonster(monster);
        } else if (choice == '2') {//방어
          int attackPower = monster.attackCharacter(character); 
          character.defend(attackPower);
        }
        if (monster.health > 0) {
          print(" ");
          print("${monster.name}의 턴");
          monster.attackCharacter(character);
        }
        character.showStatus();
        monster.showStatus();
      }
      if (monster.health <= 0) {
        defeatedMonsters++;
        print('${monster.name}을(를) 물리쳤습니다.');
        monsters.remove(monster);
      }
    }

    Monster getRandomMonster() {//몬스터 리스트에서 랜덤으로 몬스터 뽑기
      return monsters[Random().nextInt(monsters.length)];
    }
  }

  class Character { // 캐릭터 클래스: 이름, 체력, 공격력, 방어력
    String name; // 이름은 입력받을 것
    int health;
    int attack;
    int defense;

    Character(this.name, this.health, this.attack, this.defense);

    void attackMonster(Monster monster) { //몬스터 공격 메서드
      int damage = attack - monster.defense;
      if (damage > 0) {
        monster.health -= damage;
      }
      print('$name이(가) ${monster.name}에게 $damage 데미지를 입혔습니다.');
    }

    void defend(int monsterAttack) {//방어 메서드, 체력 회복
      health += monsterAttack;
      print('$name이(가) 방어 태세를 취하여 $monsterAttack만큼 체력을 얻었습니다.');
    }

    void showStatus() {//캐릭터 상태 메서드
      print('$name - 체력: $health, 공격력: $attack, 방어력: $defense');
    }
  }

  class Monster {
    String name;
    int health;
    int maxAttack;//몬스터의 공격력>캐릭터의 방어력
    int defense = 0;//방어력 0 고정

    Monster(this.name, this.health, this.maxAttack);

    int attackCharacter(Character character) {//캐릭터 공격 메서드
      int attackPower = max(character.defense, Random().nextInt(maxAttack));     
      // character.defense와 랜덤 공격력 중 큰 값을 공격력으로 설정
      int damage = attackPower - character.defense;//attackPower은 캐릭터 방어력보다 무조건 크거나 같으므로 데미지는 0이상
      character.health -= damage;
      print('$name이(가) ${character.name}에게 $damage 데미지를 입혔습니다.');
      return attackPower;//공격값 반환
    }

    void showStatus() {//몬스터 상태 메서드
      print('$name - 체력: $health, 공격력: $maxAttack');
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
  List<Monster> loadMonsters() {//몬스터 정보 읽어오는 함수
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

void saveResult(Character character, String result) {//결과 저장 함수
  print("결과를 저장하시겠습니까? (y/n)");
  String choice = stdin.readLineSync() ?? 'n';
  if (choice.toLowerCase() == 'y') {
    final file = File('result.txt');
    file.writeAsStringSync(
        '캐릭터 이름: ${character.name}\n남은 체력: ${character.health}\n게임 결과: $result');
  }
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
    print("게임을 시작합니다!");
    character.showStatus(); // 캐릭터 상태 출력
    List<Monster> monsters = loadMonsters();
    Game game = Game(character, monsters);//게임 시작
    game.startGame();
  }
