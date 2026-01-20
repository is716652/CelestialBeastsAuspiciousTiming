// 高级研习 · 知识点&案例库（官司场景 · 十三退趋势研习示例）
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

interface StudyGuideItem {
  title: string;
  summary: string;
  detail: string;
  bgColor: string;
  titleColor: string;
  tableHeaders?: string[];
  tableRows?: string[][];
}

const STUDY_GUIDE_ITEMS: StudyGuideItem[] = [
  {
    title: '禽星入庙与分布 · 空间权重',
    summary: '每一宿对应的“本位/旺地”，入庙则吉庆，失位则力减。',
    detail: '【研习要点】\n禽星入庙（司权）是判断力量强弱的基石。龙归辰海、虎啸寅山、鸡鸣酉户，皆主大事成就。',
    tableHeaders: ['地支', '代表星宿', '格局名', '吉象'],
    tableRows: [
      ['辰', '角、亢', '龙归大海', '贵显升迁'],
      ['寅', '尾、箕', '虎啸山林', '威权武职'],
      ['酉', '胃、昴', '鸡鸣五更', '光明解厄'],
      ['子', '心、虚、危', '鼠穴深藏', '智谋寻物'],
      ['亥', '女、室、壁', '蝠栖幽洞', '夜行得利']
    ],
    bgColor: '#f0fdf4',
    titleColor: '#166534'
  },
  {
    title: '禽星合局 · 三合与六合',
    summary: '基于禽形与习性的类象组合，主同类相助与功能互补。',
    detail: '【研习要点】\n禽星三合重在五行同气，力量倍增；六合重在禽形相配，主解围化困。',
    tableHeaders: ['类型', '组合', '五行', '象义'],
    tableRows: [
      ['三合(木)', '角斗井奎', '木', '仁德文书'],
      ['三合(金)', '亢牛娄鬼', '金', '钱财诉讼'],
      ['六合', '牛+马', '—', '牛马同耕'],
      ['六合', '鸡+兔', '—', '鸡兔守舍'],
      ['六合', '虎+猴', '—', '虎猴争山']
    ],
    bgColor: '#f0fdf4',
    titleColor: '#166534'
  },
  {
    title: '八曜强禽 · 主导变量',
    summary: '最具主动性与影响力的八类禽星，主导事态吉凶走向。',
    detail: '【研习要点】\n井犴破军、虎豹威震、蛟龙起浪。强禽得地得时则吉不可挡，失位则凶性难测。',
    tableHeaders: ['星宿', '禽形', '核心特性', '吉象'],
    tableRows: [
      ['井木犴', '犴', '万兽之王', '破敌贵人'],
      ['尾火虎', '虎', '百兽之长', '武职官司'],
      ['角木蛟', '蛟', '变化莫测', '升迁成就'],
      ['昴日鸡', '鸡', '鸣晓破暗', '解厄驱邪']
    ],
    bgColor: '#fdf2f2',
    titleColor: '#991b1b'
  },
  {
    title: '禽星旺衰 · 四季与昼夜',
    summary: '时间维度上的能量状态，分为五行当令与飞伏动静。',
    detail: '【研习要点】\n当令则旺，被克则死。日禽昼飞夜伏，夜禽夜飞昼伏。同气相求事始成。',
    tableHeaders: ['维度', '状态', '规则', '影响'],
    tableRows: [
      ['四季', '旺', '五行当令', '事易成'],
      ['四季', '死', '五行受克', '事难成'],
      ['昼夜', '飞', '性时相合', '动而显'],
      ['昼夜', '伏', '性时相异', '静而藏']
    ],
    bgColor: '#fefce8',
    titleColor: '#854d0e'
  },
  {
    title: '贵人宿体系 · 转机识别',
    summary: '带来师长提携、官非得理、暗中相助的吉利信号。',
    detail: '【研习要点】\n区分文贵（奎）、武贵（井）、驿马（星）、智谋（虚）等类型。入庙得时方显贵。',
    tableHeaders: ['贵人', '代表宿', '特征', '应验条件'],
    tableRows: [
      ['文贵', '奎木狼', '师长提携', '春月/戌宫'],
      ['武贵', '井木犴', '权威破敌', '土月/未宫'],
      ['智谋', '虚日鼠', '暗中相助', '冬月/子宫'],
      ['驿马', '星日马', '远行升迁', '夏月/午宫']
    ],
    bgColor: '#eff6ff',
    titleColor: '#1e40af'
  },
  {
    title: '十三退气法 · 动态追踪',
    summary: '用于寻人寻物、追踪贼盗去向的动态轨迹判断法。',
    detail: '【研习要点】\n定事体结构、定空间环境、定动态趋势。逆数十三寻踪迹，进退之间定吉凶。',
    tableHeaders: ['状态', '吉凶', '含义', '应用'],
    tableRows: [
      ['进中进', '大吉', '事速成', '寻人易'],
      ['进中退', '先成后败', '初有希望', '终无果'],
      ['退中进', '先难后易', '初无踪迹', '后可得'],
      ['退中退', '大凶', '事终不成', '永消失']
    ],
    bgColor: '#f5f3ff',
    titleColor: '#5b21b6'
  },
  {
    title: '四季魁星与鹤神 · 功名避忌',
    summary: '文运吉位与绝对禁忌方位的空间博弈。',
    detail: '【研习要点】\n魁星照临三方地（寅卯辰等），主科第登榜；鹤神方掘地三尺必有祸殃。',
    tableHeaders: ['季节', '魁星方', '鹤神忌方(按月)', '原理'],
    tableRows: [
      ['春', '东(寅卯辰)', '正子二丑三寅', '动态禁忌'],
      ['夏', '南(巳午未)', '四卯五辰六巳', '动态禁忌'],
      ['秋', '西(申酉戌)', '七午八未九申', '动态禁忌'],
      ['冬', '北(亥子丑)', '十酉十一戌十二亥', '动态禁忌']
    ],
    bgColor: '#fffbeb',
    titleColor: '#92400e'
  },
  {
    title: '十恶大败日 · 日级风险',
    summary: '禄位逢空的十个特定日柱，主根基虚浮。',
    detail: '【研习要点】\n禄为俸禄、根基。禄空则如树无根、仓无粮。在择日中忌开业、签约、出兵。',
    tableHeaders: ['序号', '日柱', '禄位', '性质'],
    tableRows: [
      ['1-2', '甲辰、乙巳', '寅、卯', '禄空'],
      ['3-4', '丙申、丁亥', '巳、午', '禄虚'],
      ['5-6', '戊戌、己丑', '巳、午', '禄空'],
      ['7-8', '庚辰、辛巳', '申、酉', '禄空'],
      ['9-10', '壬申、癸亥', '亥、子', '禄空']
    ],
    bgColor: '#fffbeb',
    titleColor: '#b45309'
  },
  {
    title: '天地荒芜 · 十二月月忌日',
    summary: '每月一个特定的地支日，主气机不接，万物荒芜。',
    detail: '【研习要点】\n该日能量崩坏，百事不宜。择日应绝对避开嫁娶、动土、出行。',
    tableHeaders: ['月份', '忌日地支', '生肖'],
    tableRows: [
      ['正、五、九', '巳、申、亥', '蛇、猴、猪'],
      ['二、六、十', '酉、子、寅', '鸡、鼠、虎'],
      ['三、七、冬', '丑、卯、戌', '牛、兔、狗'],
      ['四、八、腊', '辰、未、午', '龙、羊、马']
    ],
    bgColor: '#fef2f2',
    titleColor: '#b91c1c'
  },
  {
    title: '六恶大煞与华盖方 · 避凶趋吉',
    summary: '值日禽星的绝对禁忌与保平安的吉方指引。',
    detail: '【研习要点】\n六恶日出军定不回兵；华盖方远行、出阵可保太平。',
    tableHeaders: ['类型', '对应宿', '建议', '方位'],
    tableRows: [
      ['六恶(出兵)', '氐房奎壁斗牛', '忌出征', '—'],
      ['六恶(起造)', '箕尾牛女虚危', '忌动土', '—'],
      ['华盖(吉)', '角亢氐房', '保平安', '卯坤壬'],
      ['华盖(吉)', '心尾轸箕', '保平安', '西方']
    ],
    bgColor: '#fef2f2',
    titleColor: '#7c2d12'
  },
  {
    title: '无头星与七日凶星 · 象残时凶',
    summary: '时间序列型凶日与空间宫位型破损象。',
    detail: '【研习要点】\n七日凶星忌事起节点；无头星落入刀砧宫主事无善终、物残缺。',
    tableHeaders: ['维度', '星宿', '宫位', '凶象'],
    tableRows: [
      ['时间(第5日)', '鬼金羊', '当日值禽', '丧事被宰'],
      ['空间(无头)', '房尾危觜柳翼', '申、酉(刀砧)', '头部受伤'],
      ['空间(残缺)', '时/翻禽', '申、酉', '事难周全']
    ],
    bgColor: '#fffbeb',
    titleColor: '#7c2d12'
  },
  {
    title: '刑害刀砧汤火 · 深度断象',
    summary: '每颗星宿特定的死地、害方与刑宫。',
    detail: '【研习要点】\n每禽有其死地、害方。虎落汤镬则威尽，蚓耕南亩反被埋。',
    tableHeaders: ['禽星', '忌地支', '凶象', '名称'],
    tableRows: [
      ['尾火虎', '巳、午', '血光败阵', '汤火'],
      ['轸/角', '酉', '蛟龙被斩', '刀砧'],
      ['星/张', '寅', '马鹿被困', '山林'],
      ['危月燕', '巳', '蛇侵燕巢', '克害']
    ],
    bgColor: '#fff7ed',
    titleColor: '#7c2d12'
  },
  {
    title: '空亡体系 · 虚象识别',
    summary: '识别能量断绝、事体虚妄、百谋难成的信号。',
    detail: '【研习要点】\n吉神空亡则无力，凶神空亡反为吉。六甲空亡（寡亡煞）主孤寡分离。',
    tableHeaders: ['类型', '判断依据', '性质', '主要用途'],
    tableRows: [
      ['旬中空亡', '地支无干', '通用', '吉凶双面'],
      ['截路空亡', '日干+时支', '专忌', '出行受阻'],
      ['六甲空亡', '旬首+禽宿', '极凶', '孤寡寡亡']
    ],
    bgColor: '#eff6ff',
    titleColor: '#7c2d12'
  },
  {
    title: '六甲进退神 · 节奏模型',
    summary: '研习气机“进、退、伏、空亡”的15日循环。',
    detail: '【研习要点】\n五日一进好求财，五日一退好治病。知进退者久，遇空则止。',
    tableHeaders: ['阶段', '性质', '吉凶', '建议'],
    tableRows: [
      ['1, 7, 10', '进中进', '大吉', '求财远行'],
      ['2', '进中退', '不利', '事有反复'],
      ['3, 6, 12', '天空亡', '大凶', '百事忌用'],
      ['4, 5, 11', '退中退', '平', '静守治病']
    ],
    bgColor: '#eff6ff',
    titleColor: '#1d4ed8'
  },
  {
    title: '将军箭与将星 · 风险契机',
    summary: '突发风险方位与以弱胜强的战神位。',
    detail: '【研习要点】\n将军箭主突发灾祸，造葬忌犯；将星为贵人战神，三岁儿童胜十人。',
    tableHeaders: ['体系', '对应条件', '性质', '吉凶'],
    tableRows: [
      ['将军箭', '日干对应箭支', '突发', '大凶'],
      ['将星时', '日支三合+时辰', '战神', '大吉']
    ],
    bgColor: '#eef2ff',
    titleColor: '#1d4ed8'
  }
];

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
  @State dialogTableHeaders: string[] = [];
  @State dialogTableRows: string[][] = [];

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
    this.dialogTableHeaders = [];
    this.dialogTableRows = [];
    this.showDialog = true;
  }

  private openStudyGuideDialog(item: StudyGuideItem): void {
    this.dialogLabel = item.title;
    this.dialogSafeText = item.summary;
    this.dialogRawText = item.detail;
    this.dialogTableHeaders = item.tableHeaders || [];
    this.dialogTableRows = item.tableRows || [];
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
            Text('高级研习 · 知识点&案例库')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .width('100%')

            Text('本页展示「官司/争议」场景下的演禽研习案例，整合高阶知识点，仅供学习参考。')
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
          Text('说明：本页面为「高级研习 · 知识点&案例库」，正式演算时请使用真实配置与排盘结果，不依赖本页模拟数据。')
            .fontSize(11)
            .fontColor('#888888')
            .width('100%')
            .margin({ top: 24, bottom: 12 })

          // 活断规则 · 研习导览
          Column() {
            Text('活断规则 · 研习导览')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#374151')
              .width('100%')
              .margin({ bottom: 6 })
          
            Text('以下内容摘自高阶规则文档，点击卡片可查看研习要点。')
              .fontSize(10)
              .fontColor('#9ca3af')
              .width('100%')
              .margin({ bottom: 6 })
          
            ForEach(STUDY_GUIDE_ITEMS, (item: StudyGuideItem) => {
              Column() {
                Text(item.title)
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(item.titleColor)
                  .textAlign(TextAlign.Start)
                  .width('100%')
                Text(item.summary)
                  .fontSize(10)
                  .fontColor('#4b5563')
                  .lineHeight(14)
                  .margin({ top: 2 })
                  .textAlign(TextAlign.Start)
                  .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ top: 6, bottom: 6, left: 8, right: 8 })
              .backgroundColor(item.bgColor)
              .borderRadius(8)
              .margin({ bottom: 4 })
              .onClick(() => {
                this.openStudyGuideDialog(item);
              })
            })
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
            Text(`研习分析 · ${this.dialogLabel}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            Text('以下内容基于传统演禽理论整理，仅作研习参考，不构成现实决策依据。')
              .fontSize(11)
              .fontColor('#aaaaaa')
              .margin({ bottom: 10 })

            Text(this.dialogSafeText)
              .fontSize(13)
              .fontColor('#444444')
              .margin({ bottom: 12 })

            if (this.dialogTableHeaders.length > 0) {
              Column() {
                // 表头
                Row() {
                  ForEach(this.dialogTableHeaders, (header: string) => {
                    Text(header)
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#666666')
                      .flexGrow(1)
                      .textAlign(TextAlign.Center)
                  })
                }
                .width('100%')
                .padding(4)
                .backgroundColor('#f0f0f0')

                // 表体
                ForEach(this.dialogTableRows, (row: string[]) => {
                  Row() {
                    ForEach(row, (cell: string) => {
                      Text(cell)
                        .fontSize(10)
                        .fontColor('#333333')
                        .flexGrow(1)
                        .textAlign(TextAlign.Center)
                        .padding({ top: 4, bottom: 4 })
                    })
                  }
                  .width('100%')
                  .border({ width: { bottom: 0.5 }, color: '#eeeeee' })
                })
              }
              .width('100%')
              .border({ width: 0.5, color: '#dddddd' })
              .margin({ bottom: 12 })
            }

            Text('详细研习参考：')
              .fontSize(11)
              .fontColor('#888888')
              .margin({ bottom: 4 })

            Scroll() {
              Text(this.dialogRawText)
                .fontSize(12)
                .fontColor('#555555')
                .lineHeight(18)
            }
            .height(140)

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
