import router from '@ohos.router';
import prompt from '@system.prompt';
import { DinoObstacle, DinoRole, DinoGameStatus } from '../model/DinoRunTypes';
import { DinoRunHelper } from '../common/utils/DinoRunHelper';

class WordQuestion {
  word: string = '';
  meaning: string = '';
}

@Entry
@Component
struct DinoRunPage {
  @State role: DinoRole = DinoRunHelper.resetRole();

  @State obstacle1: DinoObstacle = this.createCactusObstacle(680);
  @State obstacle2: DinoObstacle = this.createBirdObstacle(980, 'low');
  @State useComboPair: boolean = false;

  @State score: number = 0;
  @State bestScore: number = 0;
  @State speed: number = 8;
  @State gameStatus: number = DinoGameStatus.READY;
  @State bgX1: number = 0;
  @State bgX2: number = 454;
  @State frameTick: number = 0;
  @State showGuide: boolean = true;

  @State showQuizDialog: boolean = false;
  @State quizMeaning: string = '';
  @State quizAnswer: string = '';
  @State quizInput: string = '';
  @State quizReward: number = 0;
  @State hasTriggeredQuiz: boolean = false;
  @State quizWrongCount: number = 0;
  @State showQuizFailDialog: boolean = false;
  @State quizFailText: string = '';

  timerId: number = -1;

  private wordBank: Array<WordQuestion> = [
    { word: 'ability', meaning: '能力' },
    { word: 'achieve', meaning: '实现' },
    { word: 'ancient', meaning: '古老的' },
    { word: 'average', meaning: '平均的' },
    { word: 'benefit', meaning: '益处' },
    { word: 'careful', meaning: '仔细的' },
    { word: 'choice', meaning: '选择' },
    { word: 'college', meaning: '大学' },
    { word: 'compare', meaning: '比较' },
    { word: 'culture', meaning: '文化' },
    { word: 'danger', meaning: '危险' },
    { word: 'effort', meaning: '努力' },
    { word: 'future', meaning: '未来' },
    { word: 'honest', meaning: '诚实的' },
    { word: 'memory', meaning: '记忆' },
    { word: 'method', meaning: '方法' },
    { word: 'nature', meaning: '自然' },
    { word: 'patient', meaning: '耐心的' },
    { word: 'prefer', meaning: '更喜欢' },
    { word: 'protect', meaning: '保护' },
    { word: 'reduce', meaning: '减少' },
    { word: 'remain', meaning: '保持' },
    { word: 'respect', meaning: '尊重' },
    { word: 'result', meaning: '结果' },
    { word: 'society', meaning: '社会' },
    { word: 'success', meaning: '成功' },
    { word: 'support', meaning: '支持' },
    { word: 'travel', meaning: '旅行' },
    { word: 'value', meaning: '价值' },
    { word: 'wonder', meaning: '想知道' }
  ];

  aboutToAppear(): void {
    this.resetGame();
    this.startLoop();
  }

  aboutToDisappear(): void {
    this.stopLoop();
  }

  private createCactusObstacle(x: number): DinoObstacle {
    let obstacle: DinoObstacle = new DinoObstacle();
    let cactusMode: number = Math.floor(Math.random() * 3);
    obstacle.type = 'cactus';
    obstacle.x = x;
    obstacle.passed = false;

    if (cactusMode === 0) {
      obstacle.width = 46;
      obstacle.height = 92;
    } else if (cactusMode === 1) {
      obstacle.width = 58;
      obstacle.height = 108;
    } else {
      obstacle.width = 72;
      obstacle.height = 92;
    }

    obstacle.y = DinoRunHelper.GROUND_Y + (100 - obstacle.height);
    return obstacle;
  }

  private createBirdObstacle(x: number, mode: string): DinoObstacle {
    let obstacle: DinoObstacle = new DinoObstacle();
    obstacle.type = 'bird';
    obstacle.x = x;
    obstacle.width = 72;
    obstacle.height = 52;
    obstacle.passed = false;

    if (mode === 'high') {
      obstacle.y = 235;
    } else if (mode === 'mid') {
      obstacle.y = 270;
    } else {
      obstacle.y = 318;
    }

    return obstacle;
  }

  private createSingleObstacle(x: number, score: number): DinoObstacle {
    let randomValue: number = Math.floor(Math.random() * 100);

    if (score >= 8 && randomValue < 40) {
      let birdHeightMode: number = Math.floor(Math.random() * 3);
      if (birdHeightMode === 0) {
        return this.createBirdObstacle(x, 'low');
      } else if (birdHeightMode === 1) {
        return this.createBirdObstacle(x, 'mid');
      } else {
        return this.createBirdObstacle(x, 'high');
      }
    }

    return this.createCactusObstacle(x);
  }

  private resetGame(): void {
    this.role = DinoRunHelper.resetRole();

    this.useComboPair = false;
    this.obstacle1 = this.createCactusObstacle(680);
    this.obstacle2 = this.createBirdObstacle(980, 'low');

    this.score = 0;
    this.speed = 8;
    this.gameStatus = DinoGameStatus.READY;
    this.bgX1 = 0;
    this.bgX2 = 454;
    this.frameTick = 0;
    this.showGuide = true;

    this.showQuizDialog = false;
    this.quizMeaning = '';
    this.quizAnswer = '';
    this.quizInput = '';
    this.quizReward = 0;
    this.hasTriggeredQuiz = false;
    this.quizWrongCount = 0;
    this.showQuizFailDialog = false;
    this.quizFailText = '';
  }

  private resetRunKeepSpeed(): void {
    this.role = DinoRunHelper.resetRole();

    this.useComboPair = false;
    this.obstacle1 = this.createCactusObstacle(680);
    this.obstacle2 = this.createBirdObstacle(980, 'low');

    this.score = 0;
    this.gameStatus = DinoGameStatus.READY;
    this.bgX1 = 0;
    this.bgX2 = 454;
    this.frameTick = 0;
    this.showGuide = false;

    this.showQuizDialog = false;
    this.quizMeaning = '';
    this.quizAnswer = '';
    this.quizInput = '';
    this.quizReward = 0;
    this.hasTriggeredQuiz = false;
    this.quizWrongCount = 0;
    this.showQuizFailDialog = false;
    this.quizFailText = '';
  }

  private startLoop(): void {
    this.stopLoop();
    this.timerId = setInterval((): void => {
      this.updateFrame();
    }, 40) as number;
  }

  private stopLoop(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private startRunningIfNeeded(): void {
    const currentStatus: number = this.gameStatus;
    if (currentStatus === DinoGameStatus.READY) {
      this.gameStatus = DinoGameStatus.RUNNING;
      this.showGuide = false;
    }
  }

  private operateJump(): void {
    if (this.showQuizDialog || this.showQuizFailDialog) {
      return;
    }

    const currentStatus: number = this.gameStatus;
    if (currentStatus === DinoGameStatus.OVER) {
      return;
    }

    this.startRunningIfNeeded();

    if (!this.role.isJumping && this.role.y >= DinoRunHelper.GROUND_Y) {
      this.role = DinoRunHelper.jump(this.role);
    } else {
      this.role = DinoRunHelper.fastDrop(this.role);
    }
  }

  private getRandomQuestion(): WordQuestion {
    let index: number = Math.floor(Math.random() * this.wordBank.length);
    return this.wordBank[index];
  }

  private tryTriggerQuiz(): void {
    if (this.hasTriggeredQuiz) {
      return;
    }

    if (this.score < 10) {
      return;
    }

    let randomValue: number = Math.floor(Math.random() * 100);
    if (randomValue < 38) {
      let question: WordQuestion = this.getRandomQuestion();
      this.quizMeaning = question.meaning;
      this.quizAnswer = question.word;
      this.quizInput = '';
      this.quizReward = 2 + Math.floor(Math.random() * 5);
      this.quizWrongCount = 0;
      this.showQuizDialog = true;
      this.hasTriggeredQuiz = true;
    }
  }

  private submitQuiz(): void {
    let answer: string = this.quizInput.trim().toLowerCase();
    let target: string = this.quizAnswer.trim().toLowerCase();

    if (answer.length === 0) {
      prompt.showToast({
        message: '请输入英文单词'
      });
      return;
    }

    if (answer === target) {
      this.score = this.score + this.quizReward;
      if (this.score > this.bestScore) {
        this.bestScore = this.score;
      }
      this.showQuizDialog = false;
      prompt.showToast({
        message: '回答正确，奖励 ' + this.quizReward.toString() + ' 分'
      });
      return;
    }

    this.quizWrongCount = this.quizWrongCount + 1;

    if (this.quizWrongCount >= 3) {
      this.showQuizDialog = false;
      this.quizFailText = '三次都答不对，正确答案是：' + this.quizAnswer + '。回起点重新跑吧。';
      this.showQuizFailDialog = true;
      return;
    }

    prompt.showToast({
      message: '回答错误，再试一次'
    });
  }

  private buildNextObstacleSet(fromX: number): void {
    let randomValue: number = Math.floor(Math.random() * 100);

    if (this.score >= 8 && randomValue < 45) {
      this.useComboPair = true;

      this.obstacle1 = this.createCactusObstacle(fromX);

      let gapAfterCactus: number = 95 + Math.floor(Math.random() * 35);
      this.obstacle2 = this.createBirdObstacle(fromX + gapAfterCactus, 'high');
      return;
    }

    this.useComboPair = false;
    this.obstacle1 = this.createSingleObstacle(fromX, this.score);
    this.obstacle2 = this.createBirdObstacle(fromX + 1000, 'low');
    this.obstacle2.passed = true;
  }

  private updateSingleObstacle(obstacle: DinoObstacle): DinoObstacle {
    let next: DinoObstacle = new DinoObstacle();
    next.x = obstacle.x - this.speed;
    next.y = obstacle.y;
    next.width = obstacle.width;
    next.height = obstacle.height;
    next.passed = obstacle.passed;
    next.type = obstacle.type;
    return next;
  }

  private checkPassAndCollision(obstacle: DinoObstacle): DinoObstacle {
    let next: DinoObstacle = new DinoObstacle();
    next.x = obstacle.x;
    next.y = obstacle.y;
    next.width = obstacle.width;
    next.height = obstacle.height;
    next.passed = obstacle.passed;
    next.type = obstacle.type;

    if (DinoRunHelper.isPassed(this.role, next)) {
      next.passed = true;
      this.score = this.score + 1;
      if (this.score > this.bestScore) {
        this.bestScore = this.score;
      }
      this.tryTriggerQuiz();
    }

    if (DinoRunHelper.isCollision(this.role, next)) {
      this.gameStatus = DinoGameStatus.OVER;
      prompt.showToast({
        message: '撞到障碍物了，游戏结束'
      });
    }

    return next;
  }

  private updateFrame(): void {
    if (this.showQuizDialog || this.showQuizFailDialog) {
      return;
    }

    const currentStatus: number = this.gameStatus;
    if (currentStatus !== DinoGameStatus.RUNNING) {
      return;
    }

    this.frameTick = this.frameTick + 1;
    this.speed = DinoRunHelper.nextSpeed(this.score);

    this.role = DinoRunHelper.updateRole(this.role);
    this.role = DinoRunHelper.updateRunFrame(this.role, this.frameTick);

    this.bgX1 = this.bgX1 - this.speed;
    this.bgX2 = this.bgX2 - this.speed;

    if (this.bgX1 <= -454) {
      this.bgX1 = this.bgX2 + 454;
    }
    if (this.bgX2 <= -454) {
      this.bgX2 = this.bgX1 + 454;
    }

    this.obstacle1 = this.updateSingleObstacle(this.obstacle1);
    if (this.useComboPair) {
      this.obstacle2 = this.updateSingleObstacle(this.obstacle2);
    }

    this.obstacle1 = this.checkPassAndCollision(this.obstacle1);

    if (this.useComboPair) {
      const statusAfterFirst: number = this.gameStatus;
      if (statusAfterFirst !== DinoGameStatus.OVER) {
        this.obstacle2 = this.checkPassAndCollision(this.obstacle2);
      }
    }

    if (this.useComboPair) {
      if (this.obstacle1.x + this.obstacle1.width < 0 && this.obstacle2.x + this.obstacle2.width < 0) {
        this.buildNextObstacleSet(680);
      }
    } else {
      if (this.obstacle1.x + this.obstacle1.width < 0) {
        this.buildNextObstacleSet(680);
      }
    }
  }

  private restart(): void {
    this.resetGame();
  }

  private acceptQuizFailPunish(): void {
    this.showQuizFailDialog = false;
    this.resetRunKeepSpeed();
  }

  private getRoleImage(): ResourceStr {
    const currentStatus: number = this.gameStatus;

    if (currentStatus === DinoGameStatus.OVER) {
      return $r('app.media.dino');
    }

    if (this.role.isJumping) {
      return $r('app.media.dino');
    }

    if (this.role.frameIndex === 0) {
      return $r('app.media.a');
    }

    return $r('app.media.b');
  }

  private getObstacleImage(obstacle: DinoObstacle): ResourceStr {
    if (obstacle.type === 'bird') {
      return $r('app.media.bird');
    }
    return $r('app.media.cactus');
  }

  private getStatusText(): string {
    const currentStatus: number = this.gameStatus;

    if (currentStatus === DinoGameStatus.READY) {
      return '待开始';
    }
    if (currentStatus === DinoGameStatus.RUNNING) {
      return '奔跑中';
    }
    return '游戏结束';
  }

  private getDangerText(): string {
    if (this.useComboPair) {
      return '当前障碍：组合连招';
    }
    if (this.obstacle1.type === 'bird') {
      return '当前障碍：飞鸟';
    }
    return '当前障碍：仙人掌';
  }

  build() {
    Stack() {
      Column({ space: 12 }) {
        Text('恐龙跳跃')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Row({ space: 12 }) {
          Column({ space: 2 }) {
            Text('当前分数')
              .fontSize(12)
              .fontColor('#9C8F84')
            Text(this.score.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3A312B')
          }
          .width(96)
          .height(60)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#FFF7ED')
          .borderRadius(12)

          Column({ space: 2 }) {
            Text('最高分')
              .fontSize(12)
              .fontColor('#9C8F84')
            Text(this.bestScore.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3A312B')
          }
          .width(96)
          .height(60)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#ECFCCB')
          .borderRadius(12)

          Column({ space: 2 }) {
            Text('当前速度')
              .fontSize(12)
              .fontColor('#9C8F84')
            Text(this.speed.toFixed(1))
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#3A312B')
          }
          .width(96)
          .height(60)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#DBEAFE')
          .borderRadius(12)
        }

        Text('状态：' + this.getStatusText())
          .fontSize(16)
          .fontColor('#666666')

        Text(this.getDangerText())
          .fontSize(15)
          .fontColor('#888888')

        Stack() {
          Image($r('app.media.bg'))
            .width(454)
            .height(120)
            .objectFit(ImageFit.Fill)
            .position({ x: this.bgX1, y: 276 })

          Image($r('app.media.bg'))
            .width(454)
            .height(120)
            .objectFit(ImageFit.Fill)
            .position({ x: this.bgX2, y: 276 })

          Divider()
            .vertical(false)
            .strokeWidth(2)
            .color('#666666')
            .width(454)
            .position({ x: 0, y: 396 })

          Image(this.getRoleImage())
            .width(this.role.width)
            .height(this.role.height)
            .objectFit(ImageFit.Contain)
            .position({ x: this.role.x, y: this.role.y })

          Image(this.getObstacleImage(this.obstacle1))
            .width(this.obstacle1.width)
            .height(this.obstacle1.height)
            .objectFit(ImageFit.Contain)
            .position({ x: this.obstacle1.x, y: this.obstacle1.y })

          if (this.useComboPair) {
            Image(this.getObstacleImage(this.obstacle2))
              .width(this.obstacle2.width)
              .height(this.obstacle2.height)
              .objectFit(ImageFit.Contain)
              .position({ x: this.obstacle2.x, y: this.obstacle2.y })
          }

          if (this.showGuide) {
            Column({ space: 10 }) {
              Text('第一次点击：跳跃')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text('空中再次点击：快速下坠')
                .fontSize(15)
                .fontColor('#666666')

              Text('点击游戏区域即可开始')
                .fontSize(15)
                .fontColor('#666666')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('rgba(255,255,255,0.35)')
          }
        }
        .width(454)
        .height(420)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
        .onClick(() => {
          this.operateJump();
        })

        Text('地面点击起跳，空中点击可快速下坠')
          .fontSize(15)
          .fontColor('#666666')
          .width('90%')
          .textAlign(TextAlign.Center)

        Row({ space: 16 }) {
          Button('跳跃 / 下坠')
            .width('30%')
            .height(46)
            .backgroundColor('#22C55E')
            .onClick(() => {
              this.operateJump();
            })

          Button('重新开始')
            .width('25%')
            .height(46)
            .backgroundColor('#007DFF')
            .onClick(() => {
              this.restart();
            })

          Button('返回')
            .width('20%')
            .height(46)
            .backgroundColor('#DDE7F2')
            .fontColor('#333333')
            .onClick(() => {
              router.back();
            })
        }
        .margin({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#F5F7FA')

      if (this.showQuizDialog) {
        Column() {
          Column({ space: 14 }) {
            Text('...')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#222222')

            Text('请写出下面中文对应的英文单词')
              .fontSize(16)
              .fontColor('#666666')

            Text('中文：' + this.quizMeaning)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            TextInput({
              text: this.quizInput,
              placeholder: '请输入英文单词'
            })
              .width('80%')
              .onChange((value: string) => {
                this.quizInput = value;
              })

            Button('提交答案')
              .width('35%')
              .height(44)
              .backgroundColor('#22C55E')
              .onClick(() => {
                this.submitQuiz();
              })
          }
          .width('82%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.35)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      if (this.showQuizFailDialog) {
        Column() {
          Column({ space: 14 }) {
            Text('翻车了')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#222222')

            Text(this.quizFailText)
              .fontSize(17)
              .fontColor('#333333')
              .width('85%')
              .textAlign(TextAlign.Center)

            Text('分数清零，但速度保持不变。')
              .fontSize(15)
              .fontColor('#D97706')

            Button('重新起跑')
              .width('35%')
              .height(44)
              .backgroundColor('#007DFF')
              .onClick(() => {
                this.acceptQuizFailPunish();
              })
          }
          .width('82%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.35)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      if (this.gameStatus === DinoGameStatus.OVER) {
        Column({ space: 14 }) {
          Image($r('app.media.gameover'))
            .width(180)
            .height(60)
            .objectFit(ImageFit.Contain)

          Text('本局得分：' + this.score.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Row({ space: 16 }) {
            Button('再来一局')
              .width('35%')
              .height(46)
              .backgroundColor('#22C55E')
              .onClick(() => {
                this.restart();
              })

            Button('返回大厅')
              .width('35%')
              .height(46)
              .backgroundColor('#DDE7F2')
              .fontColor('#333333')
              .onClick(() => {
                router.back();
              })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.35)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}