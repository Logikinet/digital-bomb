import router from '@ohos.router';

@Entry
@Component
struct Index {
  build() {
    Column({ space: 24 }) {
      Text('小游戏大厅')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })

      Text('后续你新增的所有游戏，都从这里进入')
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

        Button('敬请期待：下一个游戏')
          .width('85%')
          .height(56)
          .fontSize(20)
          .backgroundColor('#DDE7F2')
          .fontColor('#666666')
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