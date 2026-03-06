import router from '@ohos.router';
import { Player, PlayerType, RuleType, GameSnapshot } from '../model/GameTypes';
import { RuleEngine } from '../model/RuleEngine';

@Component
struct HpCard {
  @Prop name: string;
  @Prop hp: number;
  @Prop isCurrent: boolean;

  build() {
    Column({ space: 8 }) {
      Text(this.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isCurrent ? '#007DFF' : '#333333')

      Text('HP: ' + this.hp)
        .fontSize(16)
        .fontColor(this.hp <= 1 ? '#E84026' : '#333333')
    }
    .padding(12)
    .width('45%')
    .backgroundColor(this.isCurrent ? '#EAF3FF' : '#FFFFFF')
    .borderRadius(12)
  }
}

@Entry
@Component
struct GamePage {
  @State snapshot: GameSnapshot = RuleEngine.buildGame(RuleType.NORMAL);
  @State players: Array<Player> = [];
  @State currentPlayerIndex: number = 0;
  @State inputValue: string = '';
  @State gameLog: string = '游戏开始';
  @State gameOver: boolean = false;
  @State winnerText: string = '';

  aboutToAppear(): void {
    let rule: RuleType = RuleType.NORMAL;
    let params = router.getParams() as Record<string, Object>;

    if (params && params['ruleType'] !== undefined) {
      let ruleValue: string = params['ruleType'] as string;
      if (ruleValue === 'DOUBLE_BOMB') {
        rule = RuleType.DOUBLE_BOMB;
      } else if (ruleValue === 'NEAR_DANGER') {
        rule = RuleType.NEAR_DANGER;
      } else {
        rule = RuleType.NORMAL;
      }
    }

    this.snapshot = RuleEngine.buildGame(rule);
    this.players = this.createPlayers();
    this.currentPlayerIndex = 0;
    this.inputValue = '';
    this.gameLog = '已开始，规则：' + rule;
    this.gameOver = false;
    this.winnerText = '';
  }

  private createPlayers(): Array<Player> {
    let list: Array<Player> = [];

    let human: Player = new Player();
    human.id = 1;
    human.name = '玩家';
    human.hp = 3;
    human.type = PlayerType.HUMAN;
    human.scannerCount = 1;

    let ai: Player = new Player();
    ai.id = 2;
    ai.name = 'AI';
    ai.hp = 3;
    ai.type = PlayerType.AI;
    ai.scannerCount = 1;

    list.push(human);
    list.push(ai);

    return list;
  }

  private getCurrentPlayer(): Player {
    return this.players[this.currentPlayerIndex];
  }

  private switchTurn(): void {
    this.currentPlayerIndex = (this.currentPlayerIndex + 1) % this.players.length;

    if (!this.gameOver) {
      let current: Player = this.getCurrentPlayer();
      if (current.type === PlayerType.AI) {
        setTimeout(() => {
          this.doAiTurn();
        }, 600);
      }
    }
  }

  private doAiTurn(): void {
    if (this.gameOver) {
      return;
    }

    let guess: number = RuleEngine.aiGuess(this.snapshot);
    this.handleGuess(guess);
  }

  private handleGuess(guess: number): void {
    if (this.gameOver) {
      return;
    }

    if (guess <= this.snapshot.min || guess >= this.snapshot.max) {
      this.gameLog = '输入无效，请输入 ' + this.snapshot.min + ' 与 ' + this.snapshot.max + ' 之间的数字';
      return;
    }

    let result = RuleEngine.evaluateGuess(guess, this.snapshot);
    let player: Player = this.players[this.currentPlayerIndex];

    if (result.exploded) {
      player.hp = player.hp - 1;
      this.gameLog = player.name + ' 猜了 ' + guess + '，' + result.message;

      if (player.hp <= 0) {
        this.gameOver = true;
        let winnerIndex: number = (this.currentPlayerIndex + 1) % this.players.length;
        let winner: Player = this.players[winnerIndex];
        this.winnerText = winner.name + ' 获胜';
        return;
      }

      this.snapshot = RuleEngine.buildGame(this.snapshot.ruleType);
      this.gameLog = this.gameLog + '。本轮重置新炸弹。';
      this.switchTurn();
      return;
    }

    this.snapshot.min = result.newMin;
    this.snapshot.max = result.newMax;

    this.gameLog = player.name + ' 猜了 ' + guess + '，' + result.message;
    this.switchTurn();
  }

  private submitGuess(): void {
    let guess: number = Number(this.inputValue);
    if (isNaN(guess)) {
      this.gameLog = '请输入有效数字';
      return;
    }

    this.handleGuess(guess);
    this.inputValue = '';
  }

  private useScanner(): void {
    if (this.gameOver) {
      return;
    }

    let player: Player = this.getCurrentPlayer();
    if (player.scannerCount <= 0) {
      this.gameLog = player.name + ' 没有扫描器了';
      return;
    }

    player.scannerCount = player.scannerCount - 1;
    let hint = RuleEngine.scanHint(this.snapshot);
    this.gameLog = player.name + ' 使用扫描器：' + hint.text;
  }

  private restartGame(): void {
    this.players = this.createPlayers();
    this.currentPlayerIndex = 0;
    this.gameOver = false;
    this.winnerText = '';
    this.inputValue = '';
    this.snapshot = RuleEngine.buildGame(this.snapshot.ruleType);
    this.gameLog = '重新开始';
  }

  build() {
    Column({ space: 16 }) {
      Text('炸弹边界')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('规则：' + this.snapshot.ruleType)
        .fontSize(18)
        .fontColor('#666666')

      Row({ space: 10 }) {
        HpCard({
          name: this.players.length > 0 ? this.players[0].name : '玩家',
          hp: this.players.length > 0 ? this.players[0].hp : 3,
          isCurrent: this.currentPlayerIndex === 0
        })

        HpCard({
          name: this.players.length > 1 ? this.players[1].name : 'AI',
          hp: this.players.length > 1 ? this.players[1].hp : 3,
          isCurrent: this.currentPlayerIndex === 1
        })
      }
      .width('92%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 8 }) {
        Text('当前安全区间')
          .fontSize(18)
          .fontColor('#666666')

        Text(this.snapshot.min + '  ~  ' + this.snapshot.max)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#007DFF')
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)

      Text('当前回合：' + (this.players.length > 0 ? this.players[this.currentPlayerIndex].name : '玩家'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      if (!this.gameOver) {
        Column({ space: 12 }) {
          TextInput({ text: this.inputValue, placeholder: '请输入一个数字' })
            .type(InputType.Number)
            .width('80%')
            .onChange((value: string) => {
              this.inputValue = value;
            })

          Row({ space: 12 }) {
            Button('确认猜测')
              .onClick(() => {
                if (this.players.length > 0 && this.getCurrentPlayer().type === PlayerType.HUMAN) {
                  this.submitGuess();
                }
              })

            Button('扫描器(' + (this.players.length > 0 ? this.getCurrentPlayer().scannerCount : 0) + ')')
              .onClick(() => {
                if (this.players.length > 0 && this.getCurrentPlayer().type === PlayerType.HUMAN) {
                  this.useScanner();
                }
              })
          }
        }
      }

      Column({ space: 8 }) {
        Text('日志')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Text(this.gameLog)
          .fontSize(16)
          .fontColor('#333333')
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)

      if (this.gameOver) {
        Column({ space: 12 }) {
          Text(this.winnerText)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E84026')

          Button('重新开始')
            .onClick(() => {
              this.restartGame();
            })

          Button('返回首页')
            .onClick(() => {
              router.back();
            })
        }
        .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}