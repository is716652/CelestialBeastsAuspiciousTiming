import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { LengthMetrics } from '@kit.ArkUI';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { calcTimeTrendFromCalendar, TimeRiskTag } from '../utils/Knowledge15x';
import { getQiYaoTypeFromStar, getQiYaoInfo, QiYaoInfo } from '../utils/QiYaoUtils';
import { evaluateDayQuality, DayQualityEvaluation } from '../utils/BaoYiZhuanUtils';

// ============== 接口定义 ==============

interface ConstellationInfo {
  full_name: string;
  element: string;
  animal: string;
}

interface YearStarRules {
  base_year: number;
  base_star: string;
}

interface MonthStarRules {
  element_to_start_star: Record<string, string>;
}

interface DayStarBaseDate {
  date: string;
  yuan: number;
  jiang: number;
  star: string;
}

interface SevenYuanHeads {
  list: Array<string>;
}

interface DayStarRules {
  cycle_days: number;
  yuan_days: number;
  jiang_days: number;
  seven_yuan_heads: SevenYuanHeads;
  four_generals: Record<string, Array<string>>;
  base_date: DayStarBaseDate;
}

interface HourStarRules {
  element_to_start_star: Record<string, string>;
}

interface HourTimeRange {
  start: string;
  end: string;
  index: number;
}

interface YanqinStarRulesConfig {
  constellations_order: Array<string>;
  constellations_full: Record<string, ConstellationInfo>;
  branches_order: Array<string>;
  year_star_rules: YearStarRules;
  month_star_rules: MonthStarRules;
  day_star_rules: DayStarRules;
  hour_star_rules: HourStarRules;
  hour_time_ranges: Record<string, HourTimeRange>;
}

interface LostItemUseGod {
  category: string;
  star: string;
  note: string;
}

interface LostItemsConfig {
  constellations_order: Array<string>;
  branches_order: Array<string>;
  use_gods: Array<LostItemUseGod>;
}

interface RuleItem {
  text: string;
  category?: string;
}

interface RulesConfig {
  rules: Record<string, RuleItem>;
  branch_meanings: Record<string, BranchMeaning>;
}

interface StarGroup {
  name: string;
  stars: string[];
}

interface BranchMeaning {
  direction: string;
  element: string;
  environment: string;
  time_hint: string;
  informant: string;
  general: string;
}

interface StarCalcResult {
  star: string;
  fullName: string;
  element: string;
}

interface DayStarCalcResult {
  star: string;
  fullName: string;
  element: string;
  yuanName: string;
  jiangIndex: number;
  jiangStar: string;
}

interface FourStarsResult {
  yearStar: string;
  yearStarFull: string;
  yearElement: string;
  monthStar: string;
  monthStarFull: string;
  dayStar: string;
  dayStarFull: string;
  dayElement: string;
  hourStar: string;
  hourStarFull: string;
  hourElement: string;
  yuanName: string;
  jiangIndex: number;
  jiangStar: string;
}

@Entry
@Component
struct LostItemsSearch {
  private context = getContext(this) as common.Context;

  // 配置数据
  @State hasLoaded: boolean = false;
  @State starRulesConfig: YanqinStarRulesConfig | null = null;
  @State lostItemsConfig: LostItemsConfig | null = null;
  @State rulesConfig: RulesConfig | null = null;

  // 用户选择
  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State selectedHourIndex: number = 0;
  @State useGodMode: number = 0;  // 0=传统分类, 1=自定义用神
  @State selectedCategoryIndex: number = 0;  // 传统分类索引
  @State selectedUseGodStar: string = '参';  // 自定义用神星宿
  @State isShowUseGodSheet: boolean = false;

  private starEmojiMap: Record<string, string> = {
    '角': '🐉', '亢': '🐲', '氐': '🦡', '房': '🐰', '心': '🦊', '尾': '🐯', '箵': ' leopards',
    '斗': '獬', '牛': '🐂', '女': '🦇', '虚': '🐀', '危': '🕊️', '室': '🐖', '壁': '🦌',
    '奎': '🐺', '娄': '🐕', '胃': '雉', '昂': '🐓', '毕': '🐦', '觜': '🐒', '参': '🦍',
    '井': '🐕', '鬼': '🐏', '柳': '🦌', '星': '🐎', '张': '🦌', '翼': '🐍', '轸': '🐛'
  };

  private starGroups: StarGroup[] = [];

  // 四禽计算结果
  @State fourStars: FourStarsResult | null = null;
  @State dayInfo: CalendarDayInfo | null = null;
  @State timeTrendTags: TimeRiskTag[] = [];
  @State dayQiYaoInfo: QiYaoInfo | null = null;
  @State dayLevelInfo: DayQualityEvaluation | null = null;

  // 排盘结果
  @State resultKey: string = '';
  @State resultSummary: string = '';
  @State resultDetail: string = '';
  @State resultBranch: string = '';
  @State showResult: boolean = false;

  // 用神说明映射 (28宿扩展)
  private starExtendedMeanings: Record<string, string> = {
    '角': '长条物（绳电缆）、文书、龙形饰品',
    '亢': '贵重金属、古董、印章、高处之物',
    '氐': '皮毛衣物、化妆品、地下埋藏物',
    '房': '小型白色物、电子设备（传统：驴骡）',
    '心': '隐秘之物（U盘日记）、女性用品',
    '尾': '大型猛兽（猫科）、武器、红色物品',
    '箕': '敏捷动物（猫犬）、流动之物（酒油）',
    '斗': '法律文书、公正之物、独角饰品',
    '牛': '重型机械、农具、大型牲口（传统：牛）',
    '女': '夜间丢失物、黑色轻巧物（传统：女子）',
    '虚': '细小零件、藏于角落之物（传统：小儿）',
    '危': '飞行器（无人机风筝）、高处悬挂物',
    '室': '厨房用品、油腻之物（传统：猪）',
    '壁': '奇形怪状之物、破损物、墙边界处',
    '奎': '野性之物、群居动物（传统：妇人）',
    '娄': '忠诚之物（钥匙门禁卡）（传统：狗）',
    '胃': '彩色衣物、羽毛制品、粮食仓库',
    '昴': '鸣叫之物（闹钟铃铛）（传统：鸡）',
    '毕': '黑色物品、夜间活动之物',
    '觜': '灵巧之物（工具玩具）、攀爬相关（传统：男子）',
    '参': '水中之物、灵活贵重品（传统：金银）',
    '井': '深井下水道、法律相关、北方水边',
    '鬼': '祭祀用品、白色柔软物（传统：羊）',
    '柳': '林间小物、快速逃逸之物（传统：衣物）',
    '星': '交通工具（车）、快速移动品（传统：马）',
    '张': '温顺动物（兔）、山林草丛中失物',
    '翼': '长条软物（围巾数据线）、隐蔽缠绕',
    '轸': '细长柔软物（胶带）、低洼潮湿处'
  };

  // 选择器数据
  @State yearOptions: SelectOption[] = [];
  @State monthOptions: SelectOption[] = [];
  @State dayOptions: SelectOption[] = [];
  @State hourOptions: SelectOption[] = [];

  aboutToAppear(): void {
    // 初始化分类数据
    this.starGroups = [
      { name: '东方青龙', stars: ['角', '亢', '氐', '房', '心', '尾', '箵'] },
      { name: '北方玄武', stars: ['斗', '牛', '女', '虚', '危', '室', '壁'] },
      { name: '西方白虎', stars: ['奎', '娄', '胃', '昂', '毕', '觜', '参'] },
      { name: '南方朱雀', stars: ['井', '鬼', '柳', '星', '张', '翼', '轸'] }
    ];

    const params = router.getParams() as Record<string, number>;
    if (params) {
      this.selectedYear = params.year || this.selectedYear;
      this.selectedMonth = params.month || this.selectedMonth;
      this.selectedDay = params.day || this.selectedDay;
      this.selectedHourIndex = params.hourIndex || 0;
    }
    this.initOptions();
    CalendarManager.getInstance().init(this.context);
    this.initData();
  }

  private initOptions(): void {
    for (let y = 1900; y <= 2061; y++) this.yearOptions.push({ value: `${y}年` });
    for (let m = 1; m <= 12; m++) this.monthOptions.push({ value: `${m}月` });
    this.updateDayOptions();
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    const times = ['23-01', '01-03', '03-05', '05-07', '07-09', '09-11', '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'];
    for (let i = 0; i < 12; i++) this.hourOptions.push({ value: `${branches[i]}时 (${times[i]}点)` });
  }

  private updateDayOptions(): void {
    const daysInMonth = new Date(this.selectedYear, this.selectedMonth, 0).getDate();
    this.dayOptions = [];
    for (let d = 1; d <= daysInMonth; d++) this.dayOptions.push({ value: `${d}日` });
    if (this.selectedDay > daysInMonth) this.selectedDay = daysInMonth;
  }

  private async initData(): Promise<void> {
    const starRules = await this.loadJsonFromRaw<YanqinStarRulesConfig>('yanqin_star_rules.json');
    const lostItems = await this.loadJsonFromRaw<LostItemsConfig>('lost_items_config.json');
    const rules = await this.loadJsonFromRaw<RulesConfig>('lost_items_rules.json');

    if (starRules && lostItems && rules) {
      this.starRulesConfig = starRules;
      this.lostItemsConfig = lostItems;
      this.rulesConfig = rules;
      this.hasLoaded = true;
      this.calculateFourStars();
    }
  }

  private async loadJsonFromRaw<T>(fileName: string): Promise<T | null> {
    try {
      const value = await this.context.resourceManager.getRawFileContent(fileName);
      return ArkJSON.parse(buffer.from(value.buffer).toString()) as T;
    } catch (err) {
      return null;
    }
  }

  private async calculateFourStars(): Promise<void> {
    if (!this.starRulesConfig) return;
    const cfg = this.starRulesConfig;
    const yearResult = this.calculateYearStar(this.selectedYear, cfg);
    const monthResult = this.calculateMonthStar(this.selectedMonth, yearResult.element, cfg);
    const dayResult = this.calculateDayStar(this.selectedYear, this.selectedMonth, this.selectedDay, cfg);
    const hourResult = this.calculateHourStar(this.selectedHourIndex, dayResult.element, cfg);

    this.fourStars = {
      yearStar: yearResult.star, yearStarFull: yearResult.fullName, yearElement: yearResult.element,
      monthStar: monthResult.star, monthStarFull: monthResult.fullName,
      dayStar: dayResult.star, dayStarFull: dayResult.fullName, dayElement: dayResult.element,
      hourStar: hourResult.star, hourStarFull: hourResult.fullName, hourElement: hourResult.element,
      yuanName: dayResult.yuanName, jiangIndex: dayResult.jiangIndex, jiangStar: dayResult.jiangStar
    };

    const info = await CalendarManager.getInstance().getDayInfo(this.selectedYear, this.selectedMonth, this.selectedDay);
    this.dayInfo = info;
    if (info) {
      const trend = await calcTimeTrendFromCalendar(info, this.context);
      this.timeTrendTags = trend.tags;
      
      // 获取七曜信息
      const qiYaoType = getQiYaoTypeFromStar(dayResult.star);
      if (qiYaoType) {
        this.dayQiYaoInfo = getQiYaoInfo(qiYaoType);
      }
      
      // 评估宝义专日
      this.dayLevelInfo = evaluateDayQuality(info.day_gan, info.year_gan);
    }
  }

  private calculateYearStar(year: number, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const baseIndex = constellations.indexOf(cfg.year_star_rules.base_star);
    const starIndex = (((year - cfg.year_star_rules.base_year) % 28) + 28 + baseIndex) % 28;
    const info = cfg.constellations_full[constellations[starIndex]];
    return { star: constellations[starIndex], fullName: info.full_name, element: info.element };
  }

  private calculateMonthStar(month: number, yearElement: string, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const startIndex = constellations.indexOf(cfg.month_star_rules.element_to_start_star[yearElement]);
    const star = constellations[(startIndex + (month - 1)) % 28];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
  }

  private calculateDayStar(year: number, month: number, day: number, cfg: YanqinStarRulesConfig): DayStarCalcResult {
    const constellations = cfg.constellations_order;
    const baseParts = cfg.day_star_rules.base_date.date.split('-');
    const baseDate = new Date(parseInt(baseParts[0]), parseInt(baseParts[1]) - 1, parseInt(baseParts[2]));
    const diffDays = Math.floor((new Date(year, month - 1, day).getTime() - baseDate.getTime()) / 86400000);
    const posInCycle = ((diffDays % 420) + 420) % 420;
    const yuanName = ['一元', '二元', '三元', '四元', '五元', '六元', '七元'][Math.floor(posInCycle / 60)];
    const jiangIndex = Math.floor((posInCycle % 60) / 15);
    const jiangStar = cfg.day_star_rules.four_generals[yuanName][jiangIndex];
    const star = constellations[(constellations.indexOf(jiangStar) + (posInCycle % 15)) % 28];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element, yuanName, jiangIndex: jiangIndex + 1, jiangStar };
  }

  private calculateHourStar(hourIndex: number, dayElement: string, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const startIndex = constellations.indexOf(cfg.hour_star_rules.element_to_start_star[dayElement]);
    const star = constellations[(startIndex + hourIndex) % 28];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
  }

  private doCalculate(): void {
    if (!this.fourStars || !this.lostItemsConfig || !this.rulesConfig || !this.starRulesConfig) return;
    const constellations = this.starRulesConfig.constellations_order;
    const branches = this.lostItemsConfig.branches_order;
    let useGodStar = this.useGodMode === 0 ? this.lostItemsConfig.use_gods[this.selectedCategoryIndex].star : this.selectedUseGodStar;
    const deltaStars = (constellations.indexOf(useGodStar) - constellations.indexOf(this.fourStars.dayStar) + 28) % 28;
    this.resultBranch = branches[(this.selectedHourIndex + deltaStars) % 12];
    const starNameMap: Record<string, string> = { '觜': '觜星', '奎': '奎宿', '虚': '虚宿', '女': '女宿', '星': '星宿', '牛': '牛宿', '房': '房宿', '鬼': '鬼宿', '室': '室宿', '参': '参宿', '昴': '昴宿', '娄': '娄宿', '柳': '柳宿' };
    this.resultKey = `${starNameMap[useGodStar] || `${useGodStar}星`}在${this.resultBranch}`;
    const rule = this.rulesConfig.rules[this.resultKey];
    this.resultSummary = this.useGodMode === 0 ? `寻${this.lostItemsConfig.use_gods[this.selectedCategoryIndex].category} · 用神「${useGodStar}」宿 · 落「${this.resultBranch}」宫` : `用神「${this.starRulesConfig.constellations_full[useGodStar]?.full_name || useGodStar}」 · 落「${this.resultBranch}」宫`;
    if (rule) this.resultDetail = rule.text;
    else {
      const bm = this.rulesConfig.branch_meanings[this.resultBranch];
      this.resultDetail = bm ? `【通用推导】
方位：${bm.direction}
五行：${bm.element}
环境：${bm.environment}
报信：${bm.informant}
时间：${bm.time_hint}

分析：${bm.general}` : '暂无记载。';
    }
    this.showResult = true;
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.app_icon')) // 假设有图标，否则用文字
          .width(24).height(24).margin({ right: 10 })
          .onClick(() => router.back())
        Text('📍 方位推演')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#1a1a1a')
        Blank()
        Text('关闭').fontSize(16).fontColor('#666666').onClick(() => router.back())
      }
      .width('100%').padding({ left: 16, right: 16, top: 40, bottom: 16 })
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          // 时间选择
          Column() {
            Text('📅 选定时间').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 12 }).fontColor('#333333')
            Row() {
              Select(this.yearOptions).selected(this.selectedYear - 1900).value(`${this.selectedYear}年`).layoutWeight(1).onSelect(v => {
                this.selectedYear = 1900 + v;
                this.updateDayOptions();
                this.calculateFourStars();
              })
              Select(this.monthOptions).selected(this.selectedMonth - 1).value(`${this.selectedMonth}月`).layoutWeight(1).margin({ left: 8 }).onSelect(v => {
                this.selectedMonth = v + 1;
                this.updateDayOptions();
                this.calculateFourStars();
              })
              Select(this.dayOptions).selected(this.selectedDay - 1).value(`${this.selectedDay}日`).layoutWeight(1).margin({ left: 8 }).onSelect(v => {
                this.selectedDay = v + 1;
                this.calculateFourStars();
              })
            }
            Select(this.hourOptions).selected(this.selectedHourIndex).value(this.hourOptions[this.selectedHourIndex]?.value).width('100%').margin({ top: 10 }).onSelect(v => {
              this.selectedHourIndex = v;
              this.calculateFourStars();
            })
          }
          .padding(16).backgroundColor('#ffffff').borderRadius(12).margin({ left: 16, right: 16, top: 16, bottom: 8 })

          // 用神选择 (核心补充)
          Column() {
            Text('🔍 选择用神').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 12 }).fontColor('#333333')
            
            Row() {
              Button('传统十三类')
                .fontSize(14)
                .type(ButtonType.Normal)
                .layoutWeight(1)
                .height(36)
                .borderRadius({ topLeft: 8, bottomLeft: 8 })
                .backgroundColor(this.useGodMode === 0 ? '#3d6b4f' : '#f0f0f0')
                .fontColor(this.useGodMode === 0 ? '#ffffff' : '#666666')
                .onClick(() => this.useGodMode = 0)
              
              Button('二十八宿自定义')
                .fontSize(14)
                .type(ButtonType.Normal)
                .layoutWeight(1)
                .height(36)
                .borderRadius({ topRight: 8, bottomRight: 8 })
                .backgroundColor(this.useGodMode === 1 ? '#3d6b4f' : '#f0f0f0')
                .fontColor(this.useGodMode === 1 ? '#ffffff' : '#666666')
                .onClick(() => this.useGodMode = 1)
            }
            .width('100%')
            .margin({ bottom: 12 })

            if (this.useGodMode === 0 && this.lostItemsConfig) {
              // 传统分类选择
              Column() {
                Text('选择失物类别：').fontSize(13).fontColor('#666666').margin({ bottom: 8 }).width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.lostItemsConfig.use_gods, (item: LostItemUseGod, index: number) => {
                    Text(item.category)
                      .fontSize(13)
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .margin({ right: 8, bottom: 8 })
                      .backgroundColor(this.selectedCategoryIndex === index ? '#e8f4fc' : '#f5f5f5')
                      .fontColor(this.selectedCategoryIndex === index ? '#1a5276' : '#333333')
                      .borderRadius(16)
                      .border({ width: 1, color: this.selectedCategoryIndex === index ? '#1a5276' : '#e0e0e0' })
                      .onClick(() => this.selectedCategoryIndex = index)
                  })
                }
                Text(`对应传统用神：${this.lostItemsConfig.use_gods[this.selectedCategoryIndex].star}宿 (${this.lostItemsConfig.use_gods[this.selectedCategoryIndex].note})`)
                  .fontSize(12).fontColor('#1a5276').margin({ top: 10 }).width('100%').fontStyle(FontStyle.Italic)
              }
            } else if (this.starRulesConfig) {
              // 二十八宿自定义选择
              Column() {
                Text('点击图标选择对应星宿：').fontSize(13).fontColor('#666666').margin({ bottom: 8 }).width('100%')
                
                Row() {
                  Text(this.starEmojiMap[this.selectedUseGodStar] || '✨')
                    .fontSize(24)
                    .margin({ right: 10 })
                  
                  Column() {
                    Text(`${this.selectedUseGodStar}宿`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#d32f2f')
                    Text(this.starRulesConfig.constellations_full[this.selectedUseGodStar]?.full_name || '')
                      .fontSize(11)
                      .fontColor('#999999')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text('切换 〉')
                    .fontSize(14)
                    .fontColor('#1a5276')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#f5f5f5')
                .borderRadius(12)
                .onClick(() => {
                  this.isShowUseGodSheet = true;
                })
                .bindSheet(this.isShowUseGodSheet, this.UseGodPicker(), {
                  height: SheetSize.MEDIUM,
                  title: { title: "选择自定义用神", subtitle: "28星宿分类速选" },
                  onDisappear: () => { this.isShowUseGodSheet = false }
                })
                
                Text(`类象特征：${this.starExtendedMeanings[this.selectedUseGodStar] || '暂无说明'}`)
                  .fontSize(12).fontColor('#3d6b4f').margin({ top: 10 }).width('100%').lineHeight(16)
              }
            }
          }
          .padding(16).backgroundColor('#ffffff').borderRadius(12).margin({ left: 16, right: 16, bottom: 16 })

          // ========== 七曜与宝义专日标签 ==========
          if (this.dayQiYaoInfo && this.dayLevelInfo) {
            this.TimeTrendTagsCard()
          }

          // 演算按钮
          Button('执行方位推演')
            .width('90%').height(48).backgroundColor('#3d6b4f').margin({ bottom: 16, top: 8 })
            .onClick(() => this.doCalculate())

          if (this.showResult) {
            Column() {
              Text('推演结果').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1a1a1a').margin({ bottom: 12 }).width('100%')
              Text(this.resultSummary).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#3d6b4f').margin({ bottom: 10 }).width('100%')
              
              Divider().margin({ bottom: 12 })
              
              Text(this.resultDetail).fontSize(14).fontColor('#333333').lineHeight(22).width('100%')
              
              Column() {
                Text('【研习建议】').fontSize(13).fontWeight(FontWeight.Bold).margin({ bottom: 4 }).width('100%')
                Text('此方位结合“锁泊”环境判断失物状态。若落宫为“刀砧”主受损，“山林”主高处。可用神与盘式结合方为正法。')
                  .fontSize(12).fontColor('#666666').lineHeight(18)
              }.margin({ top: 16 }).padding(10).backgroundColor('#f0f0f0').borderRadius(8)
            }
            .padding(20).backgroundColor('#ffffff').borderRadius(16).margin({ left: 16, right: 16, bottom: 40 }).border({ width: 1, color: '#e0e0e0' })
          }
        }
      }
    }
    .width('100%').height('100%').backgroundColor('#f8f8f8')
  }

  @Builder
  TimeTrendTagsCard() {
    Column() {
      Text('── 本日时间能量评估 ──')
        .fontSize(13)
        .fontColor('#666666')
        .margin({ bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        // 七曜标签
        Row() {
          Text('🌟')
            .fontSize(14)
            .margin({ right: 4 })
          Text(this.dayQiYaoInfo!.name)
            .fontSize(12)
            .fontColor(this.dayQiYaoInfo!.color)
            .fontWeight(FontWeight.Bold)
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(this.dayQiYaoInfo!.color + '20')
        .borderRadius(14)
        .margin({ right: 8, bottom: 8 })
        .border({ width: 1, color: this.dayQiYaoInfo!.color })

        // 宝义专日标签
        Row() {
          Text(this.dayLevelInfo!.dayLevelInfo.emoji)
            .fontSize(14)
            .margin({ right: 4 })
          Text(this.dayLevelInfo!.dayLevelInfo.name)
            .fontSize(12)
            .fontColor(this.dayLevelInfo!.dayLevelInfo.color)
            .fontWeight(FontWeight.Bold)
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(this.dayLevelInfo!.dayLevelInfo.color + '20')
        .borderRadius(14)
        .margin({ right: 8, bottom: 8 })
        .border({ width: 1, color: this.dayLevelInfo!.dayLevelInfo.color })

        // 臣犯君警告
        if (this.dayLevelInfo!.isChenFanJun) {
          Row() {
            Text('⚠️')
              .fontSize(14)
              .margin({ right: 4 })
            Text('臣犯君大忌')
              .fontSize(12)
              .fontColor('#f44336')
              .fontWeight(FontWeight.Bold)
          }
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#ffebee')
          .borderRadius(14)
          .margin({ right: 8, bottom: 8 })
          .border({ width: 1, color: '#f44336' })
        }

        // 15.x时间趋势标签
        ForEach(this.timeTrendTags, (tag: TimeRiskTag) => {
          Row() {
            Text('⚠️')
              .fontSize(14)
              .margin({ right: 4 })
            Text(tag.label)
              .fontSize(12)
              .fontColor('#666666')
          }
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#f5f5f5')
          .borderRadius(14)
          .margin({ right: 8, bottom: 8 })
          .border({ width: 1, color: '#e0e0e0' })
        }, (tag: TimeRiskTag) => tag.id)
      }
      .width('100%')

      // 简要说明
      if (this.dayLevelInfo!.recommendation) {
        Text('💡 ' + this.dayLevelInfo!.recommendation)
          .fontSize(11)
          .fontColor('#2196f3')
          .width('100%')
          .margin({ top: 10 })
          .lineHeight(16)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  UseGodPicker() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.starGroups, (group: StarGroup) => {
            Column() {
              Text(group.name)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#666666')
                .width('100%')
                .margin({ top: 16, bottom: 8, left: 16 })

              Grid() {
                ForEach(group.stars, (star: string) => {
                  GridItem() {
                    Column() {
                      Text(this.starEmojiMap[star] || '✨')
                        .fontSize(24)
                      Text(star)
                        .fontSize(12)
                        .fontColor(this.selectedUseGodStar === star ? '#ffffff' : '#333333')
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .padding({ top: 10, bottom: 10 })
                    .backgroundColor(this.selectedUseGodStar === star ? '#d32f2f' : '#ffffff')
                    .borderRadius(12)
                    .border({ width: 1, color: this.selectedUseGodStar === star ? '#d32f2f' : '#eeeeee' })
                    .onClick(() => {
                      this.selectedUseGodStar = star;
                      this.isShowUseGodSheet = false;
                    })
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .padding({ left: 16, right: 16 })
              .height(160)
            }
          })
          
          Row().height(40).width('100%')
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f7f7f7')
  }
}
