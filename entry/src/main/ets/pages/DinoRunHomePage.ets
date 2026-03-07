import router from '@ohos.router';

@Entry
@Component
struct DinoRunHomePage {
  @State showRuleDialog: boolean = false;

  private startGame(): void {
    router.pushUrl({
      url: 'pages/DinoRunPage'
    });
  }

  private getRuleDescription(): string {
    return '【恐龙跳跃 / Chrome Dino 玩法】\n\n'
      + '1. 恐龙会自动向前奔跑。\n'
      + '2. 点击屏幕或点击“跳跃”按钮可让恐龙跳起。\n'
      + '3. 躲开前方不断出现的仙人掌障碍。\n'
      + '4. 每成功越过一个障碍，分数增加。\n'
      + '5. 随着分数提高，游戏速度会逐渐加快。\n'
      + '6. 如果撞到障碍物，游戏结束。\n\n'
      + '这是一个基于 Chrome 经典小恐龙玩法制作的 2D 跑酷小游戏。';
  }

  build() {
    Stack() {
      Column({ space: 22 }) {
        Text('恐龙跳跃')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 30 })

        Text('经典 Chrome 小恐龙玩法')
          .fontSize(16)
          .fontColor('#666666')

        Image($r('app.media.dino'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)

        Text('准备迎接新的挑战！')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Row({ space: 16 }) {
          Button('查看规则')
            .width('25%')
            .height(50)
            .fontSize(18)
            .backgroundColor('#F59E0B')
            .onClick(() => {
              this.showRuleDialog = true;
            })

          Button('开始游戏')
            .width('25%')
            .height(50)
            .fontSize(20)
            .backgroundColor('#22C55E')
            .onClick(() => {
              this.startGame();
            })

          Button('返回大厅')
            .width('25%')
            .height(50)
            .fontSize(18)
            .backgroundColor('#DDE7F2')
            .fontColor('#333333')
            .onClick(() => {
              router.back();
            })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#F5F7FA')

      if (this.showRuleDialog) {
        Column() {
          Column({ space: 16 }) {
            Text('恐龙跳跃 - 规则介绍')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#222222')

            Scroll() {
              Text(this.getRuleDescription())
                .fontSize(17)
                .fontColor('#333333')
                .lineHeight(26)
                .width('100%')
            }
            .width('100%')
            .height(260)

            Button('我知道了')
              .width('60%')
              .height(46)
              .fontSize(18)
              .backgroundColor('#22C55E')
              .onClick(() => {
                this.showRuleDialog = false;
              })
          }
          .width('82%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
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