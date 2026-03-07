import router from '@ohos.router';
import prompt from '@system.prompt';
import { DinoObstacle, DinoRole, DinoGameStatus } from '../model/DinoRunTypes';
import { DinoRunHelper } from '../common/utils/DinoRunHelper';

@Entry
@Component
struct DinoRunPage {
  @State role: DinoRole = DinoRunHelper.resetRole();
  @State obstacle: DinoObstacle = DinoRunHelper.createObstacle(620);
  @State score: number = 0;
  @State bestScore: number = 0;
  @State speed: number = 7;
  @State gameStatus: number = DinoGameStatus.READY;
  @State bgX1: number = 0;
  @State bgX2: number = 454;
  @State frameTick: number = 0;
  @State showGuide: boolean = true;

  timerId: number = -1;

  aboutToAppear(): void {
    this.resetGame();
    this.startLoop();
  }

  aboutToDisappear(): void {
    this.stopLoop();
  }

  private resetGame(): void {
    this.role = DinoRunHelper.resetRole();
    this.obstacle = DinoRunHelper.createObstacle(620);
    this.score = 0;
    this.speed = 7;
    this.gameStatus = DinoGameStatus.READY;
    this.bgX1 = 0;
    this.bgX2 = 454;
    this.frameTick = 0;
    this.showGuide = true;
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
    if (this.gameStatus === DinoGameStatus.READY) {
      this.gameStatus = DinoGameStatus.RUNNING;
      this.showGuide = false;
    }
  }

  // 新操作逻辑：
  // 地面点击 = 起跳
  // 空中点击 = 快速下坠
  private operateJump(): void {
    if (this.gameStatus === DinoGameStatus.OVER) {
      return;
    }

    this.startRunningIfNeeded();

    if (!this.role.isJumping && this.role.y >= DinoRunHelper.GROUND_Y) {
      this.role = DinoRunHelper.jump(this.role);
    } else {
      this.role = DinoRunHelper.fastDrop(this.role);
    }
  }

  private updateFrame(): void {
    if (this.gameStatus !== DinoGameStatus.RUNNING) {
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

    this.obstacle = DinoRunHelper.updateObstacle(this.obstacle, this.speed);
    this.obstacle = DinoRunHelper.recycleObstacleIfNeeded(this.obstacle, 620);

    if (DinoRunHelper.isPassed(this.role, this.obstacle)) {
      this.obstacle = DinoRunHelper.markPassed(this.obstacle);
      this.score = this.score + 1;
      if (this.score > this.bestScore) {
        this.bestScore = this.score;
      }
    }

    if (DinoRunHelper.isCollision(this.role, this.obstacle)) {
      this.gameStatus = DinoGameStatus.OVER;
      prompt.showToast({
        message: '撞到仙人掌了，游戏结束'
      });
    }
  }

  private restart(): void {
    this.resetGame();
  }

  private getRoleImage(): ResourceStr {
    if (this.gameStatus === DinoGameStatus.OVER) {
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

  private getStatusText(): string {
    if (this.gameStatus === DinoGameStatus.READY) {
      return '待开始';
    }
    if (this.gameStatus === DinoGameStatus.RUNNING) {
      return '奔跑中';
    }
    return '游戏结束';
  }

  build() {
    Stack() {
      Column({ space: 12 }) {
        Text('恐龙跳跃')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text('分数')
              .fontSize(14)
              .fontColor('#888888')
            Text(this.score.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width(100)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)

          Column({ space: 4 }) {
            Text('最高分')
              .fontSize(14)
              .fontColor('#888888')
            Text(this.bestScore.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width(100)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)

          Column({ space: 4 }) {
            Text('速度')
              .fontSize(14)
              .fontColor('#888888')
            Text(this.speed.toString())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .width(100)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
        }

        Text('状态：' + this.getStatusText())
          .fontSize(16)
          .fontColor('#666666')

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

          Image($r('app.media.cactus'))
            .width(this.obstacle.width)
            .height(this.obstacle.height)
            .objectFit(ImageFit.Contain)
            .position({ x: this.obstacle.x, y: this.obstacle.y })

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