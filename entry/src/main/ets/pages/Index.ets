import router from '@ohos.router';
import { RuleType } from '../model/GameTypes';

@Entry
@Component
struct Index {
  @State selectedRule: RuleType = RuleType.NORMAL;

  private startGame(): void {
    router.pushUrl({
      url: 'pages/GamePage',
      params: {
        ruleType: this.selectedRule
      }
    });
  }

  build() {
    Column({ space: 20 }) {
      Text('炸弹边界 MVP')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })

      Text('HarmonyOS 5.0.0（12）/ API 12')
        .fontSize(16)
        .fontColor('#666666')

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
      }
      .margin({ top: 30 })

      Text('当前规则：' + this.selectedRule)
        .fontSize(18)
        .fontColor('#333333')
        .margin({ top: 20 })

      Button('开始游戏')
        .width('80%')
        .height(50)
        .fontSize(20)
        .margin({ top: 30 })
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