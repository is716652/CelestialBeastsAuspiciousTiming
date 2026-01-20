// 高级研习 · 案例库 示例页面（官司场景 · 十三退趋势研习示例）
// 本页面使用模拟数据，仅用于术数文化研习与交互参考，不参与正式演算逻辑。

import { MiniQinDisk, MiniPalaceData, MiniThreePassData } from '../components/MiniQinDisk';

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

            // 使用组件化的微缩盘
            MiniQinDisk({
              threePass: {
                chu: '心', chuColor: '#8b4513',
                zhong: '星', zhongColor: '#2d5a3d',
                mo: '奎', moColor: '#1a5276'
              },
              palaces: [
                { branch: '申', env: '刀', star: '星' },
                { branch: '寅', env: '山', star: '奎' },
                { branch: '巳', env: '汤' },
                { branch: '亥', env: '江' }
              ]
            })
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
            .margin({ top: 24, bottom: 12 })

          // 15.x 活断规则 · 研习导览（知识库入口）
          Column() {
            Text('活断规则 · 研习导览（15.x 摘要）')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#374151')
              .width('100%')
              .margin({ bottom: 6 })

            Text('以下内容摘自 15.10 ~ 15.18 等规则文档，仅作为学习阅读入口，不参与本页计算。')
              .fontSize(10)
              .fontColor('#9ca3af')
              .width('100%')
              .margin({ bottom: 6 })

            Column() {
              Text('15.10 十恶大败日 · 日级风险提示')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#b45309')
              Text('讲述六十甲子中一组传统高风险日，多用于研习“何谓大败”与如何合理安排进退节奏。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#fffbeb')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.11 日游鹤神方位 · 动态禁忌方')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#b91c1c')
              Text('通过月建推算“鹤神”所到之方，传统上多用于研习“某月哪一方不宜反复惊扰”。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#fef2f2')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.12 天地荒芜 · 十二月月忌日')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#b91c1c')
              Text('每月有一支被视为“天地荒芜日”，研习时可用来理解“月中不宜大动干戈”的节奏感。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#fef2f2')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.13 华盖方 / 六恶禽日 / 大煞六凶日')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#7c2d12')
              Text('综合讲解“保平安的华盖方”与部分极凶日禽组合，适合通过案例理解“避大凶、趋大吉”的思路。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#fef2f2')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.14 七日凶星诀 / 七元无头星')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#7c2d12')
              Text('前者按“事起之日”研究后续七日中相对不利的节点，后者则通过盘面宫位研究“残缺无头”的象。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#fffbeb')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.15 灭没煞 / 百祸禽 / 刑害刀砧汤火 / 暗金伏断 / 伏断时')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#7c2d12')
              Text('集合多套高阶凶煞体系，重点在于理解“何时、何星、何宫位时应格局失衡”，适合分表逐条研读。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#fff7ed')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.16 禽中大空亡 / 旬中空亡 / 截路空亡 / 六甲空亡')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#7c2d12')
              Text('系统整理空亡在演禽与择日中的不同层级用法，核心在于理解“虚妄之象”以及何时宜止不宜行。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#eff6ff')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.17 六甲进退神')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1d4ed8')
              Text('通过十五日一小周天的模型，研习“进、退、伏、空亡”的时间节奏，是构建时间趋势标签的重要理论依据。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#eff6ff')
            .borderRadius(8)
            .margin({ bottom: 4 })

            Column() {
              Text('15.18 李广将军箭 / 罗天大退日 / 大罗天大进日 / 进神退神时 / 时中将星')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1d4ed8')
              Text('综合讲解“将军箭”与罗天大进退日及进退神时、时中将星，多用于研习如何择日择时与识别高能量节点。')
                .fontSize(10)
                .fontColor('#4b5563')
                .lineHeight(14)
                .margin({ top: 2 })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6, left: 8, right: 8 })
            .backgroundColor('#eef2ff')
            .borderRadius(8)
            .margin({ bottom: 20 })
          }
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
