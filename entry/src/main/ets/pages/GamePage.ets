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
  @State playMode: string = 'AI';

  // 四位数字对猜模式
  @State secretCode1: string = '';
  @State secretCode2: string = '';
  @State secretStep: number = 0;
  // 0: 玩家1设置 / 玩家设置
  // 1: 玩家2设置
  // 2: 正式猜数字

  // AI 增强
  @State aiCandidates: Array<string> = [];
  @State aiGuessHistory: Array<string> = [];
  @State aiFeedbackHistory: Array<number> = [];

  aboutToAppear(): void {
    let rule: RuleType = RuleType.NORMAL;
    let params = router.getParams() as Record<string, Object>;

    if (params && params['ruleType'] !== undefined) {
      let ruleValue: string = params['ruleType'] as string;
      if (ruleValue === 'DOUBLE_BOMB') {
        rule = RuleType.DOUBLE_BOMB;
      } else if (ruleValue === 'NEAR_DANGER') {
        rule = RuleType.NEAR_DANGER;
      } else if (ruleValue === 'SECRET_CODE') {
        rule = RuleType.SECRET_CODE;
      } else {
        rule = RuleType.NORMAL;
      }
    }

    if (params && params['playMode'] !== undefined) {
      this.playMode = params['playMode'] as string;
    } else {
      this.playMode = 'AI';
    }

    this.snapshot = RuleEngine.buildGame(rule);
    this.players = this.createPlayers();
    this.currentPlayerIndex = 0;
    this.inputValue = '';
    this.gameOver = false;
    this.winnerText = '';

    this.secretCode1 = '';
    this.secretCode2 = '';
    this.secretStep = 0;

    this.aiCandidates = [];
    this.aiGuessHistory = [];
    this.aiFeedbackHistory = [];

    if (rule === RuleType.SECRET_CODE) {
      if (this.playMode === 'AI') {
        this.gameLog = '四位数字对猜模式开始，请先输入你的四位数字';
      } else {
        this.gameLog = '四位数字对猜模式开始，请玩家1先输入一个四位数字';
      }
    } else {
      this.gameLog = '已开始，规则：' + rule + '，模式：' + (this.playMode === 'AI' ? '人机对战' : '双人对战');
    }
  }

  private createPlayers(): Array<Player> {
    let list: Array<Player> = [];

    let first: Player = new Player();
    first.id = 1;
    first.name = this.playMode === 'AI' ? '玩家' : '玩家1';
    first.hp = 3;
    first.type = PlayerType.HUMAN;
    first.scannerCount = 1;

    let second: Player = new Player();
    second.id = 2;
    second.name = this.playMode === 'AI' ? 'AI' : '玩家2';
    second.hp = 3;
    second.type = this.playMode === 'AI' ? PlayerType.AI : PlayerType.HUMAN;
    second.scannerCount = 1;

    list.push(first);
    list.push(second);

    return list;
  }

  private getCurrentPlayer(): Player {
    return this.players[this.currentPlayerIndex];
  }

  private switchTurn(): void {
    this.currentPlayerIndex = (this.currentPlayerIndex + 1) % this.players.length;
    this.inputValue = '';

    if (!this.gameOver) {
      let current: Player = this.getCurrentPlayer();
      if (current.type === PlayerType.AI) {
        setTimeout(() => {
          this.doAiTurn();
        }, 600);
      } else {
        if (this.playMode === 'PVP' && this.snapshot.ruleType !== RuleType.SECRET_CODE) {
          this.gameLog = this.gameLog + '。现在轮到' + current.name;
        }
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

  private countCorrectDigits(guess: string, target: string): number {
    let count: number = 0;
    let i: number = 0;
    while (i < 4) {
      if (guess.charAt(i) === target.charAt(i)) {
        count++;
      }
      i++;
    }
    return count;
  }

  private generateAiSecretCode(): string {
    let value: number = Math.floor(Math.random() * 10000);
    let code: string = value.toString();
    while (code.length < 4) {
      code = '0' + code;
    }
    return code;
  }

  private initAiCandidates(): void {
    this.aiCandidates = [];
    let i: number = 0;
    while (i <= 9999) {
      let code: string = i.toString();
      while (code.length < 4) {
        code = '0' + code;
      }
      this.aiCandidates.push(code);
      i++;
    }
  }

  private filterAiCandidates(lastGuess: string, feedback: number): void {
    let newCandidates: Array<string> = [];
    let i: number = 0;

    while (i < this.aiCandidates.length) {
      let candidate: string = this.aiCandidates[i];
      let score: number = this.countCorrectDigits(lastGuess, candidate);
      if (score === feedback) {
        newCandidates.push(candidate);
      }
      i++;
    }

    this.aiCandidates = newCandidates;
  }

  private getNextAiSecretGuess(): string {
    if (this.aiCandidates.length === 0) {
      return '0000';
    }

    let i: number = 0;
    while (i < this.aiCandidates.length) {
      let candidate: string = this.aiCandidates[i];
      if (this.aiGuessHistory.indexOf(candidate) === -1) {
        return candidate;
      }
      i++;
    }

    return this.aiCandidates[0];
  }

  private doAiSecretCodeTurn(): void {
    if (this.gameOver) {
      return;
    }

    let aiGuess: string = this.getNextAiSecretGuess();
    let target: string = this.secretCode1;
    let correctCount: number = this.countCorrectDigits(aiGuess, target);

    this.aiGuessHistory.push(aiGuess);
    this.aiFeedbackHistory.push(correctCount);

    this.gameLog = 'AI 猜测 ' + aiGuess + '，猜对了 ' + correctCount + ' 个数字';

    if (correctCount === 4) {
      this.gameOver = true;
      this.winnerText = 'AI 猜中了全部数字，获胜！';
      return;
    }

    this.filterAiCandidates(aiGuess, correctCount);
    this.currentPlayerIndex = 0;
    this.gameLog = this.gameLog + '。现在轮到玩家';
  }

  private submitSecretCodeMode(): void {
    if (this.inputValue.length !== 4 || isNaN(Number(this.inputValue))) {
      this.gameLog = '请输入合法的四位数字';
      return;
    }

    // 四位数字对猜：人机模式
    if (this.playMode === 'AI') {
      if (this.secretStep === 0) {
        this.secretCode1 = this.inputValue;
        this.inputValue = '';
        this.secretCode2 = this.generateAiSecretCode();
        this.secretStep = 2;
        this.currentPlayerIndex = 0;
        this.initAiCandidates();
        this.aiGuessHistory = [];
        this.aiFeedbackHistory = [];
        this.gameLog = '你的四位数字设置完成，AI 也已完成设置。现在轮到你先猜';
        return;
      }

      if (this.secretStep === 2) {
        if (this.currentPlayerIndex === 0) {
          let targetAi: string = this.secretCode2;
          let correctCountAi: number = this.countCorrectDigits(this.inputValue, targetAi);

          if (correctCountAi === 4) {
            this.gameOver = true;
            this.winnerText = '玩家猜中了全部数字，获胜！';
            return;
          }

          this.gameLog = '玩家猜测 ' + this.inputValue + '，猜对了 ' + correctCountAi + ' 个数字';
          this.inputValue = '';
          this.currentPlayerIndex = 1;

          setTimeout(() => {
            this.doAiSecretCodeTurn();
          }, 600);
          return;
        }
      }

      return;
    }

    // 四位数字对猜：双人模式
    if (this.secretStep === 0) {
      this.secretCode1 = this.inputValue;
      this.inputValue = '';
      this.secretStep = 1;
      this.gameLog = '玩家1设置完成，请玩家2输入一个四位数字';
      return;
    }

    if (this.secretStep === 1) {
      this.secretCode2 = this.inputValue;
      this.inputValue = '';
      this.secretStep = 2;
      this.currentPlayerIndex = 0;
      this.gameLog = '双方设置完成。现在轮到玩家1开始猜测';
      return;
    }

    if (this.secretStep === 2) {
      let currentPlayer: Player = this.players[this.currentPlayerIndex];
      let target: string = '';

      if (this.currentPlayerIndex === 0) {
        target = this.secretCode2;
      } else {
        target = this.secretCode1;
      }

      let correctCount: number = this.countCorrectDigits(this.inputValue, target);

      if (correctCount === 4) {
        this.gameOver = true;
        this.winnerText = currentPlayer.name + ' 猜中了全部数字，获胜！';
        return;
      }

      this.gameLog = currentPlayer.name + ' 猜测 ' + this.inputValue + '，猜对了 ' + correctCount + ' 个数字';
      this.inputValue = '';
      this.currentPlayerIndex = (this.currentPlayerIndex + 1) % 2;
      this.gameLog = this.gameLog + '。现在轮到' + this.players[this.currentPlayerIndex].name;
    }
  }

  private restartGame(): void {
    this.players = this.createPlayers();
    this.currentPlayerIndex = 0;
    this.gameOver = false;
    this.winnerText = '';
    this.inputValue = '';
    this.snapshot = RuleEngine.buildGame(this.snapshot.ruleType);

    this.secretCode1 = '';
    this.secretCode2 = '';
    this.secretStep = 0;

    this.aiCandidates = [];
    this.aiGuessHistory = [];
    this.aiFeedbackHistory = [];

    if (this.snapshot.ruleType === RuleType.SECRET_CODE) {
      if (this.playMode === 'AI') {
        this.gameLog = '重新开始，请先输入你的四位数字';
      } else {
        this.gameLog = '重新开始，请玩家1先输入一个四位数字';
      }
    } else {
      this.gameLog = '重新开始，模式：' + (this.playMode === 'AI' ? '人机对战' : '双人对战');
    }
  }

  private getSecretPlaceholder(): string {
    if (this.playMode === 'AI') {
      if (this.secretStep === 0) {
        return '请输入你的四位数字';
      }
      return '请输入你猜测的四位数字';
    }

    if (this.secretStep === 0) {
      return '请玩家1输入四位数字';
    }
    if (this.secretStep === 1) {
      return '请玩家2输入四位数字';
    }
    return '请输入你猜测的四位数字';
  }

  private getSecretTitle(): string {
    if (this.playMode === 'AI') {
      if (this.secretStep === 0) {
        return '当前阶段：设置你的密码';
      }
      return '当前回合：' + (this.currentPlayerIndex === 0 ? '玩家' : 'AI');
    }

    if (this.secretStep === 0) {
      return '当前阶段：玩家1设置密码';
    }
    if (this.secretStep === 1) {
      return '当前阶段：玩家2设置密码';
    }
    return '当前回合：' + (this.players.length > 0 ? this.players[this.currentPlayerIndex].name : '玩家1');
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

      Text('模式：' + (this.playMode === 'AI' ? '人机对战' : '双人对战'))
        .fontSize(18)
        .fontColor('#666666')

      Row({ space: 10 }) {
        HpCard({
          name: this.players.length > 0 ? this.players[0].name : '玩家1',
          hp: this.players.length > 0 ? this.players[0].hp : 3,
          isCurrent: this.currentPlayerIndex === 0
        })

        HpCard({
          name: this.players.length > 1 ? this.players[1].name : '玩家2',
          hp: this.players.length > 1 ? this.players[1].hp : 3,
          isCurrent: this.currentPlayerIndex === 1
        })
      }
      .width('92%')
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.snapshot.ruleType === RuleType.SECRET_CODE) {
        Column({ space: 8 }) {
          Text(this.getSecretTitle())
            .fontSize(20)
            .fontWeight(FontWeight.Medium)

          Text('玩法：双方先各自设置一个四位数字，再轮流猜对方的数字')
            .fontSize(14)
            .fontColor('#666666')
            .width('90%')

          if (this.playMode === 'AI' && this.secretStep === 2) {
            Text('AI 候选剩余：' + this.aiCandidates.length)
              .fontSize(14)
              .fontColor('#888888')
          }
        }
      } else {
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

        Text('当前回合：' + (this.players.length > 0 ? this.players[this.currentPlayerIndex].name : '玩家1'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
      }

      if (!this.gameOver) {
        Column({ space: 12 }) {
          TextInput({
            text: this.inputValue,
            placeholder: this.snapshot.ruleType === RuleType.SECRET_CODE ? this.getSecretPlaceholder() : '请输入一个数字'
          })
            .type(InputType.Number)
            .width('80%')
            .onChange((value: string) => {
              this.inputValue = value;
            })

          if (this.snapshot.ruleType === RuleType.SECRET_CODE) {
            Button('确认')
              .onClick(() => {
                this.submitSecretCodeMode();
              })
          } else {
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