import router from '@ohos.router';
import prompt from '@system.prompt';
import { Game2048Helper } from '../common/utils/Game2048Helper';
import { SoundManger } from '../common/managers/SoundManger';
import { Game2048Level, Game2048Theme, Game2048Tile } from '../model/Game2048Types';

@Entry
@Component
struct Game2048Page {
  @State board: number[][] = [];
  @State tiles: Game2048Tile[][] = [];
  @State totalScore: number = 0;
  @State bestScore: number = 0;
  @State isGameOver: boolean = false;
  @State hasReached2048: boolean = false;
  @State muteOn: boolean = false;

  @State gameLevel: number = 0;
  @State gameTheme: number = 0;
  @State levelText: string = '正常模式';
  @State themeText: string = '经典数字';

  @State remainTimeMs: number = 180000;
  @State timerRunning: boolean = false;
  @State timerText: string = '03:00';
  timerId: number = -1;

  @State soundManger: SoundManger = new SoundManger();

  private touchStartX: number = 0;
  private touchStartY: number = 0;
  private touchEndX: number = 0;
  private touchEndY: number = 0;

  aboutToAppear(): void {
    let params = router.getParams() as Record<string, Object>;

    if (params && params['gameLevel'] !== undefined) {
      this.gameLevel = params['gameLevel'] as number;
    } else {
      this.gameLevel = Game2048Level.NORMAL;
    }

    if (params && params['gameTheme'] !== undefined) {
      this.gameTheme = params['gameTheme'] as number;
    } else {
      this.gameTheme = Game2048Theme.CLASSIC;
    }

    this.levelText = this.getLevelText(this.gameLevel);
    this.themeText = this.getThemeText(this.gameTheme);

    this.soundManger.createSoundPool();
    this.soundManger.loadAudios(['merge', 'no_change', 'restart', 'timer_bg', 'game_over', 'error']);

    this.restartGame();
  }

  aboutToDisappear(): void {
    this.stopTimer();
    this.soundManger.stopSoundAll();
  }

  private restartGame(): void {
    this.stopTimer();

    this.totalScore = 0;
    this.isGameOver = false;
    this.hasReached2048 = false;
    this.remainTimeMs = 180000;
    this.timerText = '03:00';
    this.timerRunning = false;

    this.board = Game2048Helper.createInitialBoard(this.gameLevel, 4, 4);
    this.tiles = Game2048Helper.buildTiles(this.board, this.gameTheme, 4, 4);
  }

  private rebuildTiles(): void {
    this.tiles = Game2048Helper.buildTiles(this.board, this.gameTheme, 4, 4);
  }

  private getLevelText(level: number): string {
    if (level === Game2048Level.NORMAL) {
      return '正常模式';
    }
    if (level === Game2048Level.HARD) {
      return '困难模式';
    }
    return '极速挑战';
  }

  private getThemeText(theme: number): string {
    if (theme === Game2048Theme.CLASSIC) {
      return '经典数字';
    }
    if (theme === Game2048Theme.DYNASTY) {
      return '古往今来';
    }
    if (theme === Game2048Theme.SCHOLAR) {
      return '进士及第';
    }
    return '百炼成钢';
  }

  private toggleMute(): void {
    this.muteOn = !this.muteOn;
    this.soundManger.isMute = this.muteOn;

    if (this.muteOn) {
      this.soundManger.stopSoundAll();
    } else {
      if (this.gameLevel === Game2048Level.SPEED && this.timerRunning && !this.isGameOver) {
        this.playBgSound();
      }
    }
  }

  private playBgSound(): void {
    this.soundManger.playSound('timer_bg');
  }

  private startTimer(): void {
    if (this.gameLevel !== Game2048Level.SPEED) {
      return;
    }

    if (this.timerRunning) {
      return;
    }

    this.timerRunning = true;
    if (!this.muteOn) {
      this.playBgSound();
    }

    this.timerId = setInterval((): void => {
      if (!this.timerRunning) {
        return;
      }

      this.remainTimeMs -= 100;

      if (this.remainTimeMs <= 0) {
        this.remainTimeMs = 0;
        this.updateTimerText();
        this.stopTimer();
        this.triggerGameOver('时间到，游戏结束！');
        return;
      }

      this.updateTimerText();
    }, 100) as number;
  }

  private stopTimer(): void {
    this.timerRunning = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.soundManger.stopSound('timer_bg');
  }

  private updateTimerText(): void {
    let totalMs: number = this.remainTimeMs;
    let totalSeconds: number = Math.floor(totalMs / 1000);
    let minutes: number = Math.floor(totalSeconds / 60);
    let seconds: number = totalSeconds % 60;

    let mm: string = minutes < 10 ? '0' + minutes.toString() : minutes.toString();
    let ss: string = seconds < 10 ? '0' + seconds.toString() : seconds.toString();
    this.timerText = mm + ':' + ss;
  }

  private applyMove(direction: string): void {
    if (this.isGameOver) {
      this.soundManger.playSound('error');
      prompt.showToast({ message: '游戏已结束，请重新开始' });
      return;
    }

    if (this.gameLevel === Game2048Level.SPEED && !this.timerRunning) {
      this.soundManger.playSound('error');
      prompt.showToast({ message: '极速挑战请先点击播放按钮开始倒计时' });
      return;
    }

    let moveResult = Game2048Helper.move(this.board, direction, this.gameLevel, 4, 4);

    if (!moveResult.changed) {
      this.soundManger.playSound('no_change');
      if (!Game2048Helper.canMove(this.board, 4, 4)) {
        this.triggerGameOver('已经无法继续移动，游戏结束！');
      }
      return;
    }

    this.board = moveResult.board;
    this.totalScore += moveResult.scoreGain;

    if (this.totalScore > this.bestScore) {
      this.bestScore = this.totalScore;
    }

    if (moveResult.scoreGain > 0) {
      this.soundManger.playSound('merge');
    }

    this.rebuildTiles();

    if (!this.hasReached2048 && Game2048Helper.hasTarget(this.board, 2048, 4, 4)) {
      this.hasReached2048 = true;
      prompt.showToast({ message: '恭喜，你已经达成 2048！' });
    }

    if (!Game2048Helper.canMove(this.board, 4, 4)) {
      this.triggerGameOver('已经无法继续移动，游戏结束！');
    }
  }

  private triggerGameOver(message: string): void {
    this.isGameOver = true;
    this.stopTimer();
    this.soundManger.playSound('game_over');
    prompt.showToast({ message: message });
  }

  private handleSwipe(): void {
    let swipeX: number = this.touchEndX - this.touchStartX;
    let swipeY: number = this.touchEndY - this.touchStartY;

    if (Math.abs(swipeX) < 10 && Math.abs(swipeY) < 10) {
      return;
    }

    let direction: string = '';

    if (Math.abs(swipeX) > Math.abs(swipeY)) {
      if (swipeX > 0) {
        direction = 'right';
      } else {
        direction = 'left';
      }
    } else {
      if (swipeY > 0) {
        direction = 'down';
      } else {
        direction = 'up';
      }
    }

    this.applyMove(direction);
    this.touchStartX = 0;
    this.touchStartY = 0;
    this.touchEndX = 0;
    this.touchEndY = 0;
  }

  @Builder
  tileBuilder(tile: Game2048Tile) {
    Text(tile.text)
      .fontSize(tile.fontSize)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .fontColor(tile.textColor)
      .backgroundColor(tile.bgColor)
      .width('100%')
      .height('100%')
      .borderRadius(8)
  }

  build() {
    Stack() {
      Column({ space: 12 }) {
        Text('2048')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })

        Text('模式：' + this.levelText + '    主题：' + this.themeText)
          .fontSize(16)
          .fontColor('#666666')

        Row({ space: 8 }) {
          Image($r('app.media.startIcon'))
            .width(52)
            .height(52)

          Column({ space: 4 }) {
            Text('分数')
              .fontSize(14)
              .fontColor('#EEE4DA')
            Text(this.totalScore.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(110)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#BBADA0')
          .borderRadius(8)

          Column({ space: 4 }) {
            Text('最高分')
              .fontSize(14)
              .fontColor('#EEE4DA')
            Text(this.bestScore.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(110)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#BBADA0')
          .borderRadius(8)
        }

        Row({ space: 20 }) {
          Image($r('app.media.restart'))
            .width(28)
            .height(28)
            .onClick(() => {
              this.soundManger.stopSound('timer_bg');
              this.soundManger.playSound('restart');
              this.restartGame();
            })

          Image(this.muteOn ? $r('app.media.mute') : $r('app.media.unmute'))
            .width(28)
            .height(28)
            .onClick(() => {
              this.toggleMute();
            })

          if (this.gameLevel === Game2048Level.SPEED) {
            Image(this.timerRunning ? $r('app.media.pause') : $r('app.media.play'))
              .width(28)
              .height(28)
              .onClick(() => {
                if (this.isGameOver) {
                  this.soundManger.playSound('error');
                  prompt.showToast({ message: '游戏已结束，请重新开始' });
                  return;
                }

                if (this.timerRunning) {
                  this.stopTimer();
                } else {
                  this.startTimer();
                }
              })

            Text(this.timerText)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
        }
        .margin({ top: 8, bottom: 8 })

        Grid() {
          ForEach(this.tiles, (row: Game2048Tile[]) => {
            ForEach(row, (tile: Game2048Tile) => {
              GridItem() {
                this.tileBuilder(tile)
              }
            })
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width('90%')
        .height(360)
        .padding(10)
        .backgroundColor('#BBADA0')
        .borderRadius(10)
        .onTouch((e) => {
          if (e.type === TouchType.Down && e.touches.length > 0) {
            this.touchStartX = e.touches[0].windowX;
            this.touchStartY = e.touches[0].windowY;
          } else if (e.type === TouchType.Move && e.changedTouches.length > 0) {
            this.touchEndX = e.changedTouches[0].windowX;
            this.touchEndY = e.changedTouches[0].windowY;
          } else if (e.type === TouchType.Up && e.changedTouches.length > 0) {
            this.touchEndX = e.changedTouches[0].windowX;
            this.touchEndY = e.changedTouches[0].windowY;
            this.handleSwipe();
          }
        })

        Text('玩法：向上、下、左、右滑动棋盘，合并相同数字，挑战 2048！')
          .fontSize(15)
          .fontColor('#666666')
          .width('90%')
          .textAlign(TextAlign.Center)

        Row({ space: 16 }) {
          Button('重新开始')
            .width('35%')
            .height(46)
            .backgroundColor('#22C55E')
            .onClick(() => {
              this.soundManger.playSound('restart');
              this.restartGame();
            })

          Button('返回')
            .width('35%')
            .height(46)
            .backgroundColor('#DDE7F2')
            .fontColor('#333333')
            .onClick(() => {
              this.stopTimer();
              router.back();
            })
        }
        .margin({ top: 10, bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FAF8EF')

      if (this.isGameOver) {
        Column({ space: 16 }) {
          Text('游戏结束')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#222222')

          Text('本局得分：' + this.totalScore.toString())
            .fontSize(20)
            .fontColor('#333333')

          Row({ space: 16 }) {
            Button('再来一局')
              .width('35%')
              .height(46)
              .backgroundColor('#22C55E')
              .onClick(() => {
                this.soundManger.playSound('restart');
                this.restartGame();
              })

            Button('返回大厅')
              .width('35%')
              .height(46)
              .backgroundColor('#DDE7F2')
              .fontColor('#333333')
              .onClick(() => {
                this.stopTimer();
                router.back();
              })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.45)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}