import router from '@ohos.router';
import prompt from '@system.prompt';

@Entry
@Component
struct Index {
  build() {
    Column({ space: 24 }) {
      Text('小游戏大厅')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })

      Text('当前已集成的游戏入口')
        .fontSize(16)
        .fontColor('#666666')

      Column({ space: 16 }) {
        Button('炸弹边界 MVP')
          .width('85%')
          .height(56)
          .fontSize(22)
          .backgroundColor('#007DFF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/BombBoundaryPage'
            });
          })

        Button('2048')
          .width('85%')
          .height(56)
          .fontSize(22)
          .backgroundColor('#22C55E')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Game2048HomePage'
            });
          })

        Button('恐龙跳跃')
          .width('85%')
          .height(56)
          .fontSize(22)
          .backgroundColor('#F59E0B')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DinoRunHomePage'
            });
          })

        Button('敬请期待：下一个游戏')
          .width('85%')
          .height(56)
          .fontSize(20)
          .backgroundColor('#DDE7F2')
          .fontColor('#666666')
          .onClick(() => {
            prompt.showToast({
              message: '功能开发中，敬请期待'
            });
          })
      }
      .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F7FA')
  }
}