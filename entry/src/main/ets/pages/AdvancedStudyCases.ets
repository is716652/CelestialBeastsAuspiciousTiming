// 高级研习 · 案例库 示例页面（官司场景 · 十三退趋势研习示例）
// 本页面使用模拟数据，仅用于术数文化研习与交互参考，不参与正式演算逻辑。

interface LawsuitStateConfig {
  label: string;       // 状态名称：进中进 / 进中退 / 退中进 / 退中退
  safeSummary: string; // 安全总结，用于正式 UI 展示
  rawText: string;     // 传统风格原文，仅在研习弹窗中展示
}

interface LawsuitRulesMap {
  jin_jin: LawsuitStateConfig;
  jin_tui: LawsuitStateConfig;
  tui_jin: LawsuitStateConfig;
  tui_tui: LawsuitStateConfig;
}

const MOCK_LAWSUIT_RULES: LawsuitRulesMap = {
  jin_jin: {
    label: '进中进',
    safeSummary: '官司类问题若见「进中进」，多用于形容争议持续发酵、往来频繁，程序推进较快，双方立场都比较主动，需要投入较多精力应对过程本身。',
    rawText: '问词讼，进中进者，讼端连绵，往来有期，多见言辞交锋不歇，程式急而未止。'
  },
  jin_tui: {
    label: '进中退',
    safeSummary: '官司类问题若见「进中退」，可理解为前期比较多事、动作频密，后面总体有向收束或调解方向发展的倾向，但过程里仍可能有反复，需要注意文书与程序上的细节。',
    rawText: '问词讼，进中退者，初则事多而纷扰，继乃稍就调停，或以和息，或以判决了局，然间有反覆，不可轻心。'
  },
  tui_jin: {
    label: '退中进',
    safeSummary: '官司类问题若见「退中进」，多表示一开始相对低调或不在明面，但后续容易重新被提起或升级，有从内部矛盾转为公开争议的趋势，需要提前做好资料与预案准备。',
    rawText: '问词讼，退中进者，始则不彰，事在暗中相持，及后渐露端倪，或旧案复提，或小争渐广。'
  },
  tui_tui: {
    label: '退中退',
    safeSummary: '官司类问题若见「退中退」，整体可以理解为争议逐步降温或被视为边缘事项，多在时日推移中淡出主要议程，适合通过程序性安排与时间拉长来化解压力。',
    rawText: '问词讼，退中退者，多主情势渐寡，或因久拖而淡，或因事移他途，不复成大争端。'
  }
};

@Entry
@Component
struct AdvancedStudyCases {
  @State selectedStateKey: string = 'jin_jin';
  @State showDialog: boolean = false;
  @State dialogLabel: string = '';
  @State dialogSafeText: string = '';
  @State dialogRawText: string = '';

  private openDialog(): void {
    let cfg: LawsuitStateConfig | null = null;
    if (this.selectedStateKey === 'jin_jin') {
      cfg = MOCK_LAWSUIT_RULES.jin_jin;
    } else if (this.selectedStateKey === 'jin_tui') {
      cfg = MOCK_LAWSUIT_RULES.jin_tui;
    } else if (this.selectedStateKey === 'tui_jin') {
      cfg = MOCK_LAWSUIT_RULES.tui_jin;
    } else if (this.selectedStateKey === 'tui_tui') {
      cfg = MOCK_LAWSUIT_RULES.tui_tui;
    }
    if (!cfg) {
      return;
    }
    this.dialogLabel = cfg.label;
    this.dialogSafeText = cfg.safeSummary;
    this.dialogRawText = cfg.rawText;
    this.showDialog = true;
  }

  private closeDialog(): void {
    this.showDialog = false;
  }

  // ============== 简易可视化小盘组件 ==============

  @Builder
  ThreePassItemMini(label: string, star: string, bgColor: string) {
    Column() {
      Text(label)
        .fontSize(9)
        .fontColor('#888888')
      Column() {
        Text(star)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(bgColor)
      .borderRadius(18)
      .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SuoBoPalaceMini(branch: string, env: string, star: string = '') {
    Column() {
      Row() {
        Text(branch)
          .fontSize(10)
          .fontColor('#ffffff')
          .fontWeight(FontWeight.Bold)
        Text(env)
          .fontSize(9)
          .fontColor('#ffffffcc')
          .margin({ left: 2 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1a5276')
      .padding({ top: 2, bottom: 2 })

      if (star) {
        Text(star)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#c62828')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height(44)
    .backgroundColor('#ffffff')
    .border({ width: 0.5, color: '#dddddd' })
  }

  build() {
    Stack() {
      // 主体内容
      Scroll() {
        Column() {
          // 标题与说明
          Column() {
            Text('高级研习 · 案例库 示例')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .width('100%')

            Text('本页展示「官司/争议」场景下的演禽研习案例，使用模拟数据，仅供学习参考。')
              .fontSize(12)
              .fontColor('#666666')
              .width('100%')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 24, bottom: 12 })

          // 示例案件：可视化盘式 + 分析思路
          Column() {
            Row() {
              Text('示例案件：合同纠纷（演示盘）')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Blank()
              Text('2024年四月初八 · 午时')
                .fontSize(11)
                .fontColor('#666666')
            }
            .width('100%')
            .margin({ bottom: 12 })

            Row() {
              // 左侧：三传小图
              Column() {
                Text('【三传概览】')
                  .fontSize(10)
                  .fontColor('#555555')
                  .margin({ bottom: 8 })
                Row() {
                  this.ThreePassItemMini('初传', '心', '#8b4513')
                  Text('→').fontSize(12).fontColor('#cccccc').margin({ left: 4, right: 4, top: 12 })
                  this.ThreePassItemMini('中传', '星', '#2d5a3d')
                  Text('→').fontSize(12).fontColor('#cccccc').margin({ left: 4, right: 4, top: 12 })
                  this.ThreePassItemMini('末传', '奎', '#1a5276')
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              // 右侧：锁泊小图 (简化版，仅显示关键宫位)
              Column() {
                Text('【关键落宫】')
                  .fontSize(10)
                  .fontColor('#555555')
                  .margin({ bottom: 8 })
                Grid() {
                  GridItem() { this.SuoBoPalaceMini('申', '刀', '星') } // 龙落砧板
                  GridItem() { this.SuoBoPalaceMini('寅', '山', '奎') } // 文星登高
                  GridItem() { this.SuoBoPalaceMini('巳', '汤') }
                  GridItem() { this.SuoBoPalaceMini('亥', '江') }
                }
                .columnsTemplate('1fr 1fr')
                .rowsTemplate('1fr 1fr')
                .columnsGap(2)
                .rowsGap(2)
                .width(100)
                .height(90)
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .margin({ bottom: 12 })

            Divider().color('#eeeeee').margin({ bottom: 10 })

            Text('分析思路：')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 4 })
            Text('该案例中，时禽星宿落申宫（受制），天禽奎宿落寅宫（登高）。分析时先通过上述结构理解案件背景，再通过「十三退」观察事态走向。')
              .fontSize(11)
              .fontColor('#666666')
              .lineHeight(16)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .border({ width: 1, color: '#e0e0e0' })
          .margin({ bottom: 16 })

          // 状态选择说明
          Text('在以上示例案件的前提下，选择一个十三退状态，打开研习窗口查看对应的趋势说明：')
            .fontSize(13)
            .fontColor('#444444')
            .width('100%')
            .margin({ bottom: 12 })

          // 状态选择按钮
          Column() {
            Row() {
              Button('进中进')
                .fontSize(13)
                .type(ButtonType.Normal)
                .width('48%')
                .height(36)
                .borderRadius(18)
                .backgroundColor(this.selectedStateKey === 'jin_jin' ? '#3d6b4f' : '#f4f4f4')
                .fontColor(this.selectedStateKey === 'jin_jin' ? '#ffffff' : '#333333')
                .onClick(() => {
                  this.selectedStateKey = 'jin_jin';
                })

              Button('进中退')
                .fontSize(13)
                .type(ButtonType.Normal)
                .width('48%')
                .height(36)
                .borderRadius(18)
                .backgroundColor(this.selectedStateKey === 'jin_tui' ? '#3d6b4f' : '#f4f4f4')
                .fontColor(this.selectedStateKey === 'jin_tui' ? '#ffffff' : '#333333')
                .margin({ left: 8 })
                .onClick(() => {
                  this.selectedStateKey = 'jin_tui';
                })
            }
            .margin({ bottom: 8 })

            Row() {
              Button('退中进')
                .fontSize(13)
                .type(ButtonType.Normal)
                .width('48%')
                .height(36)
                .borderRadius(18)
                .backgroundColor(this.selectedStateKey === 'tui_jin' ? '#3d6b4f' : '#f4f4f4')
                .fontColor(this.selectedStateKey === 'tui_jin' ? '#ffffff' : '#333333')
                .onClick(() => {
                  this.selectedStateKey = 'tui_jin';
                })

              Button('退中退')
                .fontSize(13)
                .type(ButtonType.Normal)
                .width('48%')
                .height(36)
                .borderRadius(18)
                .backgroundColor(this.selectedStateKey === 'tui_tui' ? '#3d6b4f' : '#f4f4f4')
                .fontColor(this.selectedStateKey === 'tui_tui' ? '#ffffff' : '#333333')
                .margin({ left: 8 })
                .onClick(() => {
                  this.selectedStateKey = 'tui_tui';
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 20 })

          // 打开研习弹窗按钮
          Button('查看十三退趋势（官司研习示例）')
            .fontSize(13)
            .type(ButtonType.Normal)
            .width('100%')
            .height(44)
            .backgroundColor('#3d6b4f')
            .fontColor('#ffffff')
            .borderRadius(22)
            .onClick(() => this.openDialog())

          // 底部说明
          Text('说明：本页面为「高级研习 · 案例库 示例」，正式演算时请使用真实配置与排盘结果，不依赖本页模拟数据。')
            .fontSize(11)
            .fontColor('#888888')
            .width('100%')
            .margin({ top: 24, bottom: 32 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')

      // 简易弹出式研习窗口（覆盖在页面上方）
      if (this.showDialog) {
        Column() {
          Column() {
            Text(`官司 · 十三退趋势研习（${this.dialogLabel}）`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            Text('以下内容基于传统十三退气法思路整理，仅作官司/争议处理过程的研习参考，不构成法律意见或现实决策依据。')
              .fontSize(11)
              .fontColor('#aaaaaa')
              .margin({ bottom: 10 })

            Text(this.dialogSafeText)
              .fontSize(13)
              .fontColor('#444444')
              .margin({ bottom: 12 })

            Text('传统说明（原文风格，仅做对照阅读）：')
              .fontSize(11)
              .fontColor('#888888')
              .margin({ bottom: 4 })

            Scroll() {
              Text(this.dialogRawText)
                .fontSize(12)
                .fontColor('#555555')
            }
            .height(90)

            Button('仅作研习参考，知道了')
              .fontSize(12)
              .width('100%')
              .height(36)
              .margin({ top: 14 })
              .onClick(() => this.closeDialog())
          }
          .width('82%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(14)

          // 点击遮罩空白处也可以关闭
          // 这里只留一个小提示文本，避免误触引起困惑
          Text('点击按钮关闭研习窗口')
            .fontSize(10)
            .fontColor('#cccccc')
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#00000066')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f1ed')
  }
}
