import router from '@ohos.router';
import { RuleType } from '../model/GameTypes';

@Entry
@Component
struct Index {
  @State selectedRule: RuleType = RuleType.NORMAL;
  @State playMode: string = 'AI';

  private startGame(): void {
    let realPlayMode: string = this.playMode;

    if (this.selectedRule === RuleType.SECRET_CODE) {
      realPlayMode = 'PVP';
    }

    router.pushUrl({
      url: 'pages/GamePage',
      params: {
        ruleType: this.selectedRule,
        playMode: realPlayMode
      }
    });
  }

  build() {
    Column({ space: 20 }) {
      Text('炸弹边界 MVP')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30 })


      Text('选择规则')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10 })

      Column({ space: 12 }) {
        Button('经典模式')
          .width('80%')
          .backgroundColor(this.selectedRule === RuleType.NORMAL ? '#007DFF' : '#DDE7F2')
          .onClick(() => {
            this.selectedRule = RuleType.NORMAL;
          })

        Button('双炸弹模式')
          .width('80%')
          .backgroundColor(this.selectedRule === RuleType.DOUBLE_BOMB ? '#007DFF' : '#DDE7F2')
          .onClick(() => {
            this.selectedRule = RuleType.DOUBLE_BOMB;
          })

        Button('连号危险模式')
          .width('80%')
          .backgroundColor(this.selectedRule === RuleType.NEAR_DANGER ? '#007DFF' : '#DDE7F2')
          .onClick(() => {
            this.selectedRule = RuleType.NEAR_DANGER;
          })

        Button('四位数字对猜')
          .width('80%')
          .backgroundColor(this.selectedRule === RuleType.SECRET_CODE ? '#007DFF' : '#DDE7F2')
          .onClick(() => {
            this.selectedRule = RuleType.SECRET_CODE;
            this.playMode = 'PVP';
          })
      }

      Text('选择对战模式')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10 })

      Column({ space: 12 }) {
        Button('人机对战')
          .width('80%')
          .backgroundColor(this.playMode === 'AI' ? '#22C55E' : '#DDE7F2')
          .enabled(this.selectedRule !== RuleType.SECRET_CODE)
          .opacity(this.selectedRule === RuleType.SECRET_CODE ? 0.5 : 1)
          .onClick(() => {
            if (this.selectedRule !== RuleType.SECRET_CODE) {
              this.playMode = 'AI';
            }
          })

        Button('双人对战')
          .width('80%')
          .backgroundColor(this.playMode === 'PVP' ? '#22C55E' : '#DDE7F2')
          .onClick(() => {
            this.playMode = 'PVP';
          })
      }



      Text('当前模式：' + (this.playMode === 'AI' ? '人机对战' : '双人对战'))
        .fontSize(18)
        .fontColor('#333333')

      if (this.selectedRule === RuleType.SECRET_CODE) {
        Text('四位数字对猜模式仅支持双人对战')
          .fontSize(14)
          .fontColor('#E84026')
      }

      Button('开始游戏')
        .width('80%')
        .height(50)
        .fontSize(20)
        .margin({ top: 20 })
        .onClick(() => {
          this.startGame();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}