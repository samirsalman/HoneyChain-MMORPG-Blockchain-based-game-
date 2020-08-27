const { Contract } = require('fabric-contract-api');

class FabHoney extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const gameObjects = [
            {
        color: "purple",
        owner: "admin",
        power: 200,
        level: 2,
        id: 0,
      },
      {
        color: "red",
        owner: "admin",
        power: 154,
        level: 1,
        id: 1,
      },
      {
        color: "green",
        owner: "admin",
        power: 400,
        level: 1,
        id: 2,
      },
      {
        color: "yellow",
        owner: "admin",
        power: 400,
        level: 3,
        id: 3,
      },
      {
        color: "pink",
        owner: "admin",
        power: 210,
        level: 2,
        id: 4,
      },
      {
        color: "blue",
        owner: "admin",
        power: 80,
        level: 2,
        id: 5,
      },
      {
        color: "gold",
        owner: "admin",
        power: 1000,
        level: 3,
        id: 6,
      },
        ];

        for (let i = 0; i < gameObjects.length; i++) {
            gameObjects[i].docType = 'honey';
            await ctx.stub.putState('HONEY' + i, Buffer.from(JSON.stringify(gameObjects[i])));
            console.info('Added <--> ', gameObjects[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryHoney(ctx, honeyNumber) {
        const honeyAsBytes = await ctx.stub.getState(honeyNumber); // get the car from chaincode state
        if (!honeyAsBytes || honeyAsBytes.length === 0) {
            throw new Error(`${honeyNumber} does not exist`);
        }
        console.log(honeyAsBytes.toString());
        return honeyAsBytes.toString();
    }

    async createHoney(ctx, honeyNumber, color, owner, power, level, id) {
        console.info('============= START : Create Honey ===========');

        const honey = {
            color,
            docType: 'honey',
            owner,
            power,
            level,
	    id,
        };

        await ctx.stub.putState(honeyNumber, Buffer.from(JSON.stringify(honey)));
        console.info('============= END : Create Honey ===========');
    }

    async queryHoneys(ctx) {
        const startKey = 'HONEY0';
        const endKey = 'HONEY999';
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: key, Record: record });
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

    async changeHoneyOwner(ctx, honeyNumber, newOwner) {
        console.info('============= START : changeOwner ===========');

        const honeyAsBytes = await ctx.stub.getState(honeyNumber); // get the car from chaincode state
        if (!honeyAsBytes || honeyAsBytes.length === 0) {
            throw new Error(`${honeyNumber} does not exist`);
        }
        const honey = JSON.parse(honeyAsBytes.toString());
        honey.owner = newOwner;

        await ctx.stub.putState(honeyNumber, Buffer.from(JSON.stringify(honey)));
        console.info('============= END : changeHoneyOwner ===========');
    }

}

module.exports = FabHoney;