class Player {
  constructor(name, x, y, direction, type, force, money, honey, level) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.direction = direction;
    this.type = type;
    this.force = force;
    this.money = money;
    this.honey = honey;
    this.level = level;
  }
}

module.exports = Player;
