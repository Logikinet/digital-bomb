import router from '@ohos.router';
import { RuleType } from '../model/GameTypes';

@Entry
@Component
struct BombBoundaryPage {
  @State selectedRule: RuleType = RuleType.NORMAL;
  @State playMode: string = 'AI';
  @State showRuleDialog: boolean = false;

  private startGame(): void {
    router.pushUrl({
      url: 'pages/GamePage',
      params: {
        ruleType: this.selectedRule,
        playMode: this.playMode
      }
    });
  }

  private getRuleText(): string {
    if (this.selectedRule === RuleType.NORMAL) {
      return '经典模式';
    }
    if (this.selectedRule === RuleType.DOUBLE_BOMB) {
      return '双炸弹模式';
    }
    if (this.selectedRule === RuleType.NEAR_DANGER) {
      return '连号危险模式';
    }
    if (this.selectedRule === RuleType.SECRET_CODE) {
      return '四位数字对猜';
    }
    return '经典模式';
  }

  private getModeText(): string {
    return this.playMode === 'AI' ? '人机对战' : '双人对战';
  }

  private getRuleDescription(): string {
    if (this.selectedRule === RuleType.NORMAL) {
      return '【经典模式】\n\n'
        + '1. 系统会在当前区间内生成一个炸弹数字。\n'
        + '2. 玩家轮流输入一个数字进行猜测。\n'
        + '3. 如果没猜中，区间会根据结果缩小。\n'
        + '4. 如果猜中炸弹，当前玩家扣除生命值。\n'
        + '5. 谁的生命值先归零，谁就失败。';
    }

    if (this.selectedRule === RuleType.DOUBLE_BOMB) {
      return '【双炸弹模式】\n\n'
        + '1. 系统会同时生成两个炸弹数字。\n'
        + '2. 玩家依旧轮流猜数字。\n'
        + '3. 只要命中任意一个炸弹数字，就会爆炸扣血。\n'
        + '4. 由于危险数字增加，玩法会更刺激。';
    }

    if (this.selectedRule === RuleType.NEAR_DANGER) {
      return '【连号危险模式】\n\n'
        + '1. 系统生成一个核心炸弹数字。\n'
        + '2. 除了炸弹本身，炸弹前后相邻数字也算危险。\n'
        + '3. 例如炸弹是 63，那么 62、63、64 都会触发爆炸。\n'
        + '4. 这个模式比经典模式更考验判断。';
    }

    if (this.selectedRule === RuleType.SECRET_CODE) {
      return '【四位数字对猜】\n\n'
        + '1. 双方先各自设置一个四位数字。\n'
        + '2. 然后双方轮流猜测对方设置的数字。\n'
        + '3. 每次猜完后，系统只提示“猜对了几个数字”。\n'
        + '4. 这里的“猜对”指数字和位置都正确。\n'
        + '5. 如果有人 4 位全部猜中，则该玩家直接获胜。\n'
        + '6. 在人机模式下，AI 会根据历史反馈逐步缩小候选范围。';
    }

    return '暂无规则说明';
  }

  build() {
    Stack() {
      Column({ space: 20 }) {
        Text('炸弹边界 MVP')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 30 })

        Text('当前已整合的玩法入口')
          .fontSize(16)
          .fontColor('#666666')

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
            .onClick(() => {
              this.playMode = 'AI';
            })

          Button('双人对战')
            .width('80%')
            .backgroundColor(this.playMode === 'PVP' ? '#22C55E' : '#DDE7F2')
            .onClick(() => {
              this.playMode = 'PVP';
            })
        }

        Column({ space: 8 }) {
          Text('当前规则：' + this.getRuleText())
            .fontSize(18)
            .fontColor('#333333')

          Text('当前模式：' + this.getModeText())
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
            .backgroundColor('#007DFF')
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
            Text(this.getRuleText() + ' - 规则介绍')
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
              .backgroundColor('#007DFF')
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