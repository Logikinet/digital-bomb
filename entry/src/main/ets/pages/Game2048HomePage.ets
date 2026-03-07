import router from '@ohos.router';

@Entry
@Component
struct Game2048HomePage {
  @State gameLevel: number = 0;
  @State gameTheme: number = 0;
  @State showRuleDialog: boolean = false;

  private getLevelText(): string {
    if (this.gameLevel === 0) {
      return '正常模式';
    }
    if (this.gameLevel === 1) {
      return '困难模式';
    }
    return '极速挑战';
  }

  private getThemeText(): string {
    if (this.gameTheme === 0) {
      return '经典数字';
    }
    if (this.gameTheme === 1) {
      return '古往今来';
    }
    if (this.gameTheme === 2) {
      return '进士及第';
    }
    return '百炼成钢';
  }

  private startGame(): void {
    router.pushUrl({
      url: 'pages/Game2048Page',
      params: {
        gameLevel: this.gameLevel,
        gameTheme: this.gameTheme
      }
    });
  }

  private getRuleDescription(): string {
    return '【2048 经典 4x4 玩法】\n\n'
      + '1. 在 4x4 棋盘中，通过上、下、左、右滑动移动所有方块。\n'
      + '2. 当两个相同数字的方块相撞时，它们会合并成一个更大的数字。\n'
      + '3. 合并顺序为：2、4、8、16、32、64……直到 2048。\n'
      + '4. 每次成功移动后，棋盘会随机生成一个新的数字方块（2 或 4）。\n'
      + '5. 不能再移动时，游戏结束。\n'
      + '6. 数字越大、得分越高，达到 2048 即可完成经典挑战。\n\n'
      + '【模式说明】\n'
      + '正常模式：标准 2048 体验。\n'
      + '困难模式：每次操作后可能生成更多新数字，难度更高。\n'
      + '极速挑战：带倒计时与背景音效，节奏更紧张。\n\n'
      + '【主题说明】\n'
      + '经典数字：标准数字显示。\n'
      + '古往今来：朝代主题。\n'
      + '进士及第：科举主题。\n'
      + '百炼成钢：军衔主题。';
  }

  build() {
    Stack() {
      Column({ space: 20 }) {
        Text('2048')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 30 })

        Text('经典 4x4 数字合并益智游戏')
          .fontSize(16)
          .fontColor('#666666')

        Text('选择模式')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 10 })

        Column({ space: 12 }) {
          Button('正常模式')
            .width('80%')
            .backgroundColor(this.gameLevel === 0 ? '#22C55E' : '#DDE7F2')
            .onClick(() => {
              this.gameLevel = 0;
            })

          Button('困难模式')
            .width('80%')
            .backgroundColor(this.gameLevel === 1 ? '#22C55E' : '#DDE7F2')
            .onClick(() => {
              this.gameLevel = 1;
            })

          Button('极速挑战')
            .width('80%')
            .backgroundColor(this.gameLevel === 2 ? '#22C55E' : '#DDE7F2')
            .onClick(() => {
              this.gameLevel = 2;
            })
        }

        Text('选择主题')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 10 })

        Column({ space: 12 }) {
          Button('经典数字')
            .width('80%')
            .backgroundColor(this.gameTheme === 0 ? '#007DFF' : '#DDE7F2')
            .onClick(() => {
              this.gameTheme = 0;
            })

          Button('古往今来')
            .width('80%')
            .backgroundColor(this.gameTheme === 1 ? '#007DFF' : '#DDE7F2')
            .onClick(() => {
              this.gameTheme = 1;
            })

          Button('进士及第')
            .width('80%')
            .backgroundColor(this.gameTheme === 2 ? '#007DFF' : '#DDE7F2')
            .onClick(() => {
              this.gameTheme = 2;
            })

          Button('百炼成钢')
            .width('80%')
            .backgroundColor(this.gameTheme === 3 ? '#007DFF' : '#DDE7F2')
            .onClick(() => {
              this.gameTheme = 3;
            })
        }

        Column({ space: 8 }) {
          Text('当前模式：' + this.getLevelText())
            .fontSize(18)
            .fontColor('#333333')

          Text('当前主题：' + this.getThemeText())
            .fontSize(18)
            .fontColor('#333333')
        }
        .margin({ top: 10 })

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
        .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#F5F7FA')

      if (this.showRuleDialog) {
        Column() {
          Column({ space: 16 }) {
            Text('2048 - 规则介绍')
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
            .height(300)

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