const Datastore = require("nedb-promises");
let datastore = Datastore.create("./db.db");
let ranking = Datastore.create("./ranking.db");
let players = Datastore.create("./players.db");
const Player = require("../../models/player");

class DatabaseInstance {
  constructor() {
    if (!DatabaseInstance.instance) {
      DatabaseInstance.instance = this;
    }

    return DatabaseInstance.instance;
  }

  async createUser(user) {
    try {
      var email = user.email.toLocaleLowerCase();

      let res = await datastore.insert(user);
      var player = new Player(user.email, 0, 0, null, 0, 0, 0, 0, 1);
      await players.insert(player);
      return 1;
    } catch (error) {
      return 0;
    }
  }

  async getUser(email, password) {
    try {
      let res = await datastore.find({
        email: email.toLocaleLowerCase(),
        password: password,
      });

      if (res.length > 0) {
        let player = await players.find({
          name: email.toLocaleLowerCase(),
        });
        return player[0];
      } else {
        return null;
      }
    } catch (error) {
      return 0;
    }
  }

  async getUserWoPw(email) {
    let res = await datastore.find({
      email: email.toLocaleLowerCase(),
    });

    if (res.length > 0) {
      let player = await players.find({
        name: email.toLocaleLowerCase(),
      });
      return player[0];
    } else {
      return null;
    }

    return res[0];
  }

  async isEmailGood(email) {
    let res = await datastore
      .find({
        email: email.toLocaleLowerCase(),
      })
      .catch((error) => {
        console.error(error);
        return null;
      });
    console.log("Response from db isGoodEmail", res, res.length);
    if (res.length > 0) {
      return false;
    } else return true;
  }
}
const instance = new DatabaseInstance();
Object.freeze(instance);

module.exports = instance;
