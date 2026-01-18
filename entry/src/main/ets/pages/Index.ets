import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';

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
  four_symbols: FourSymbols;
  use_god_hints: UseGodHints;
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

interface FourSymbolGroup {
  name: string;
  color: string;
  stars: Array<string>;
}

interface FourSymbols {
  description: string;
  groups: Array<FourSymbolGroup>;
}

interface UseGodHints {
  description: string;
  hints: Record<string, string>;
}

interface RuleItem {
  text: string;
  category?: string;
}

interface RulesConfig {
  rules: Record<string, RuleItem>;
}

// ============== 四禽计算结果接口 ==============

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
  yuanName: string;
  jiangIndex: number;
}

@Entry
@Component
struct Index {
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
  @State selectedHourIndex: number = this.getCurrentHourIndex();
  @State selectedTabIndex: number = 0;  // 四象Tab索引
  @State selectedUseGodStar: string = '参';  // 选中的用神星宿

  // 四禽计算结果
  @State fourStars: FourStarsResult | null = null;

  // 排盘结果
  @State resultKey: string = '';
  @State resultSummary: string = '';
  @State resultDetail: string = '';
  @State resultBranch: string = '';
  @State showResult: boolean = false;

  // 选择器数据
  @State yearOptions: SelectOption[] = [];
  @State monthOptions: SelectOption[] = [];
  @State dayOptions: SelectOption[] = [];
  @State hourOptions: SelectOption[] = [];

  private getCurrentHourIndex(): number {
    const hour = new Date().getHours();
    if (hour >= 23 || hour < 1) return 0;
    if (hour >= 1 && hour < 3) return 1;
    if (hour >= 3 && hour < 5) return 2;
    if (hour >= 5 && hour < 7) return 3;
    if (hour >= 7 && hour < 9) return 4;
    if (hour >= 9 && hour < 11) return 5;
    if (hour >= 11 && hour < 13) return 6;
    if (hour >= 13 && hour < 15) return 7;
    if (hour >= 15 && hour < 17) return 8;
    if (hour >= 17 && hour < 19) return 9;
    if (hour >= 19 && hour < 21) return 10;
    return 11;
  }

  aboutToAppear(): void {
    this.initOptions();
    this.initData();
  }

  private initOptions(): void {
    // 年份选项
    const years: SelectOption[] = [];
    for (let y = 1900; y <= 2061; y++) {
      const opt: SelectOption = { value: `${y}年` };
      years.push(opt);
    }
    this.yearOptions = years;

    // 月份选项
    const months: SelectOption[] = [];
    for (let m = 1; m <= 12; m++) {
      const opt: SelectOption = { value: `${m}月` };
      months.push(opt);
    }
    this.monthOptions = months;

    // 日期选项
    this.updateDayOptions();

    // 时辰选项
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    const times = ['23-01', '01-03', '03-05', '05-07', '07-09', '09-11', '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'];
    const hours: SelectOption[] = [];
    for (let i = 0; i < 12; i++) {
      const opt: SelectOption = { value: `${branches[i]}时 (${times[i]}点)` };
      hours.push(opt);
    }
    this.hourOptions = hours;
  }

  private updateDayOptions(): void {
    const daysInMonth = new Date(this.selectedYear, this.selectedMonth, 0).getDate();
    const days: SelectOption[] = [];
    for (let d = 1; d <= daysInMonth; d++) {
      const opt: SelectOption = { value: `${d}日` };
      days.push(opt);
    }
    this.dayOptions = days;
    if (this.selectedDay > daysInMonth) {
      this.selectedDay = daysInMonth;
    }
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
      const str = buffer.from(value.buffer).toString();
      return ArkJSON.parse(str) as T;
    } catch (err) {
      console.error('Failed to load: ' + fileName + ', error: ' + JSON.stringify(err));
      return null;
    }
  }

  // ============== 四禽计算算法 ==============

  private calculateFourStars(): void {
    if (!this.starRulesConfig) return;

    const cfg = this.starRulesConfig;

    const yearResult = this.calculateYearStar(this.selectedYear, cfg);
    const monthResult = this.calculateMonthStar(this.selectedMonth, yearResult.element, cfg);
    const dayResult = this.calculateDayStar(this.selectedYear, this.selectedMonth, this.selectedDay, cfg);
    const hourResult = this.calculateHourStar(this.selectedHourIndex, dayResult.element, cfg);

    const result: FourStarsResult = {
      yearStar: yearResult.star,
      yearStarFull: yearResult.fullName,
      yearElement: yearResult.element,
      monthStar: monthResult.star,
      monthStarFull: monthResult.fullName,
      dayStar: dayResult.star,
      dayStarFull: dayResult.fullName,
      dayElement: dayResult.element,
      hourStar: hourResult.star,
      hourStarFull: hourResult.fullName,
      yuanName: dayResult.yuanName,
      jiangIndex: dayResult.jiangIndex
    };
    this.fourStars = result;
  }

  private calculateYearStar(year: number, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const baseYear = cfg.year_star_rules.base_year;
    const baseStar = cfg.year_star_rules.base_star;
    const baseIndex = constellations.indexOf(baseStar);

    const yearDiff = year - baseYear;
    const starIndex = ((yearDiff % 28) + 28 + baseIndex) % 28;
    const star = constellations[starIndex];
    const info = cfg.constellations_full[star];

    const result: StarCalcResult = {
      star: star,
      fullName: info.full_name,
      element: info.element
    };
    return result;
  }

  private calculateMonthStar(month: number, yearElement: string, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const startStar = cfg.month_star_rules.element_to_start_star[yearElement];
    const startIndex = constellations.indexOf(startStar);

    const monthIndex = (startIndex + (month - 1)) % 28;
    const star = constellations[monthIndex];
    const info = cfg.constellations_full[star];

    const result: StarCalcResult = {
      star: star,
      fullName: info.full_name,
      element: info.element
    };
    return result;
  }

  private calculateDayStar(year: number, month: number, day: number, cfg: YanqinStarRulesConfig): DayStarCalcResult {
    const constellations = cfg.constellations_order;
    const dayRules = cfg.day_star_rules;

    const baseDate = new Date(dayRules.base_date.date);
    const targetDate = new Date(year, month - 1, day);

    const diffTime = targetDate.getTime() - baseDate.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    const posInCycle = ((diffDays % 420) + 420) % 420;
    const yuanIndex = Math.floor(posInCycle / 60);
    const posInYuan = posInCycle % 60;
    const jiangIndex = Math.floor(posInYuan / 15);
    const dayInJiang = posInYuan % 15;

    const yuanNames = ['一元', '二元', '三元', '四元', '五元', '六元', '七元'];
    const yuanName = yuanNames[yuanIndex];
    const jiangStars = dayRules.four_generals[yuanName];
    const jiangStar = jiangStars[jiangIndex];

    const jiangStarIndex = constellations.indexOf(jiangStar);
    const dayStarIndex = (jiangStarIndex + dayInJiang) % 28;
    const star = constellations[dayStarIndex];
    const info = cfg.constellations_full[star];

    const result: DayStarCalcResult = {
      star: star,
      fullName: info.full_name,
      element: info.element,
      yuanName: yuanName,
      jiangIndex: jiangIndex + 1
    };
    return result;
  }

  private calculateHourStar(hourIndex: number, dayElement: string, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const startStar = cfg.hour_star_rules.element_to_start_star[dayElement];
    const startIndex = constellations.indexOf(startStar);

    const hourStarIndex = (startIndex + hourIndex) % 28;
    const star = constellations[hourStarIndex];
    const info = cfg.constellations_full[star];

    const result: StarCalcResult = {
      star: star,
      fullName: info.full_name,
      element: info.element
    };
    return result;
  }

  // ============== 排盘演算 ==============

  private doCalculate(): void {
    if (!this.fourStars || !this.lostItemsConfig || !this.rulesConfig || !this.starRulesConfig) {
      return;
    }

    const constellations = this.starRulesConfig.constellations_order;
    const branches = this.lostItemsConfig.branches_order;

    const dayStarIndex = constellations.indexOf(this.fourStars.dayStar);
    const hourIndex = this.selectedHourIndex;
    const useStarIndex = constellations.indexOf(this.selectedUseGodStar);

    if (dayStarIndex < 0 || useStarIndex < 0) {
      this.resultSummary = '数据配置不完整，无法演算。';
      this.resultDetail = '';
      this.showResult = true;
      return;
    }

    const deltaStars = (useStarIndex - dayStarIndex + 28) % 28;
    const resultBranchIndex = (hourIndex + deltaStars) % 12;
    this.resultBranch = branches[resultBranchIndex];

    const key = this.buildRuleKey(this.selectedUseGodStar, this.resultBranch);
    this.resultKey = key;

    const rule = this.rulesConfig.rules[key];

    this.resultSummary = `用神「${this.selectedUseGodStar}」宿 · 落「${this.resultBranch}」宫`;

    if (rule) {
      this.resultDetail = rule.text;
    } else {
      this.resultDetail = `当前组合（${key}）在案例库中暂无详细记载。`;
    }
    this.showResult = true;
  }

  private buildRuleKey(star: string, branch: string): string {
    const starNameMap: Record<string, string> = {
      '觜': '觜星', '奎': '奎宿', '虚': '虚宿', '女': '女宿',
      '星': '星宿', '牛': '牛宿', '房': '房宿', '鬼': '鬼宿',
      '室': '室宿', '参': '参宿', '昴': '昴宿', '娄': '娄宿', '柳': '柳宿'
    };
    const prefix = starNameMap[star] || `${star}星`;
    return `${prefix}在${branch}`;
  }

  private getDateString(): string {
    return `${this.selectedYear}年${this.selectedMonth}月${this.selectedDay}日`;
  }

  private getHourString(index: number): string {
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    const times = ['23-01', '01-03', '03-05', '05-07', '07-09', '09-11', '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'];
    return `${branches[index]}时 (${times[index]}点)`;
  }

  // ============== UI 构建 ==============

  build() {
    Scroll() {
      Column() {
        // 顶部标题
        Column() {
          Text('禽星演寻')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
          Text('基于七元甲子的传统演禽术研习工具')
            .fontSize(13)
            .fontColor('#666666')
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ top: 40, bottom: 20 })
        .alignItems(HorizontalAlign.Center)

        if (this.hasLoaded && this.starRulesConfig && this.lostItemsConfig) {
          // ========== 日期时辰选择区 ==========
          Column() {
            Text('选择日期时辰')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 12 })

            // 年月日选择行
            Row() {
              Select(this.yearOptions)
                .selected(this.selectedYear - 1900)
                .value(`${this.selectedYear}年`)
                .font({ size: 14 })
                .fontColor('#333333')
                .height(44)
                .layoutWeight(1)
                .backgroundColor('#f8f8f6')
                .borderRadius(8)
                .onSelect((index: number) => {
                  this.selectedYear = 1900 + index;
                  this.updateDayOptions();
                  this.calculateFourStars();
                  this.showResult = false;
                })

              Select(this.monthOptions)
                .selected(this.selectedMonth - 1)
                .value(`${this.selectedMonth}月`)
                .font({ size: 14 })
                .fontColor('#333333')
                .height(44)
                .layoutWeight(1)
                .backgroundColor('#f8f8f6')
                .borderRadius(8)
                .margin({ left: 8 })
                .onSelect((index: number) => {
                  this.selectedMonth = index + 1;
                  this.updateDayOptions();
                  this.calculateFourStars();
                  this.showResult = false;
                })

              Select(this.dayOptions)
                .selected(this.selectedDay - 1)
                .value(`${this.selectedDay}日`)
                .font({ size: 14 })
                .fontColor('#333333')
                .height(44)
                .layoutWeight(1)
                .backgroundColor('#f8f8f6')
                .borderRadius(8)
                .margin({ left: 8 })
                .onSelect((index: number) => {
                  this.selectedDay = index + 1;
                  this.calculateFourStars();
                  this.showResult = false;
                })
            }
            .width('100%')

            // 时辰选择
            Select(this.hourOptions)
              .selected(this.selectedHourIndex)
              .value(this.getHourString(this.selectedHourIndex))
              .font({ size: 14 })
              .fontColor('#333333')
              .width('100%')
              .height(44)
              .backgroundColor('#f8f8f6')
              .borderRadius(8)
              .margin({ top: 10 })
              .onSelect((index: number) => {
                this.selectedHourIndex = index;
                this.calculateFourStars();
                this.showResult = false;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })

          // ========== 四禽展示区 ==========
          if (this.fourStars) {
            Column() {
              Row() {
                Text('四禽推算')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                Blank()
                Text(`${this.fourStars.yuanName}·第${this.fourStars.jiangIndex}将`)
                  .fontSize(12)
                  .fontColor('#888888')
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 四禽网格
              Grid() {
                GridItem() {
                  Column() {
                    Text('年禽')
                      .fontSize(11)
                      .fontColor('#888888')
                    Text(this.fourStars.yearStarFull)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#2d5a3d')
                      .margin({ top: 4 })
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('#f5f9f6')
                  .borderRadius(10)
                }

                GridItem() {
                  Column() {
                    Text('月禽')
                      .fontSize(11)
                      .fontColor('#888888')
                    Text(this.fourStars.monthStarFull)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#2d5a3d')
                      .margin({ top: 4 })
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('#f5f9f6')
                  .borderRadius(10)
                }

                GridItem() {
                  Column() {
                    Text('日禽')
                      .fontSize(11)
                      .fontColor('#ffffff')
                    Text(this.fourStars.dayStarFull)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#ffffff')
                      .margin({ top: 4 })
                    Text(`属${this.fourStars.dayElement}`)
                      .fontSize(10)
                      .fontColor('#ffffffcc')
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('#3d6b4f')
                  .borderRadius(10)
                }

                GridItem() {
                  Column() {
                    Text('时禽')
                      .fontSize(11)
                      .fontColor('#888888')
                    Text(this.fourStars.hourStarFull)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#2d5a3d')
                      .margin({ top: 4 })
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor('#f5f9f6')
                  .borderRadius(10)
                }
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsTemplate('1fr')
              .columnsGap(8)
              .width('100%')
              .height(80)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(14)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

          // ========== 用神选择区（四象分组 + 网格） ==========
          Column() {
            Row() {
              Text('选择用神星宿')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              Text(this.starRulesConfig.constellations_full[this.selectedUseGodStar]?.full_name || '')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#3d6b4f')
            }
            .width('100%')
            .margin({ bottom: 10 })

            // 四象Tab
            Row() {
              ForEach(this.starRulesConfig.four_symbols.groups, (group: FourSymbolGroup, index: number) => {
                Text(group.name)
                  .fontSize(13)
                  .fontColor(this.selectedTabIndex === index ? '#ffffff' : '#666666')
                  .backgroundColor(this.selectedTabIndex === index ? group.color : '#f0f0f0')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: index < 3 ? 8 : 0 })
                  .onClick(() => {
                    this.selectedTabIndex = index;
                  })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: 12 })

            // 星宿网格（7个一组）
            Column() {
              Grid() {
                ForEach(this.starRulesConfig.four_symbols.groups[this.selectedTabIndex].stars,
                  (star: string, idx: number) => {
                    GridItem() {
                      Column() {
                        Text(this.starRulesConfig!.constellations_full[star]?.animal || '')
                          .fontSize(20)
                          .margin({ bottom: 2 })
                        Text(star)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.selectedUseGodStar === star ? '#ffffff' : '#333333')
                        Text(this.starRulesConfig!.constellations_full[star]?.element || '')
                          .fontSize(10)
                          .fontColor(this.selectedUseGodStar === star ? '#ffffffcc' : '#888888')
                          .margin({ top: 2 })
                      }
                      .width('100%')
                      .height('100%')
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor(this.selectedUseGodStar === star ?
                        this.starRulesConfig!.four_symbols.groups[this.selectedTabIndex].color : '#f8f8f6')
                      .borderRadius(10)
                      .onClick(() => {
                        this.selectedUseGodStar = star;
                        this.showResult = false;
                      })
                    }
                  })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
              .height(140)
            }
            .width('100%')

            // 用神参考提示
            Row() {
              Text('参考：')
                .fontSize(12)
                .fontColor('#888888')
              Text(this.starRulesConfig.use_god_hints.hints[this.selectedUseGodStar] || '')
                .fontSize(12)
                .fontColor('#666666')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 10 })
            .padding({ left: 8, right: 8, top: 8, bottom: 8 })
            .backgroundColor('#fafaf8')
            .borderRadius(8)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16 })

          // ========== 演算按钮 ==========
          Button('开始演算', { type: ButtonType.Capsule })
            .width('90%')
            .height(50)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#3d6b4f')
            .margin({ top: 24, bottom: 16 })
            .onClick(() => {
              this.doCalculate();
            })

          // ========== 结果展示区 ==========
          if (this.showResult && this.fourStars && this.lostItemsConfig) {
            Column() {
              Row() {
                Text('演算结果')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                Blank()
                Text(this.resultKey)
                  .fontSize(12)
                  .fontColor('#888888')
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 排盘信息
              Column() {
                Row() {
                  Text('日期')
                    .fontSize(13)
                    .fontColor('#666666')
                    .width(60)
                  Text(this.getDateString())
                    .fontSize(13)
                    .fontColor('#333333')
                }
                .width('100%')
                .margin({ bottom: 6 })

                Row() {
                  Text('日禽')
                    .fontSize(13)
                    .fontColor('#666666')
                    .width(60)
                  Text(`${this.fourStars.dayStarFull}（属${this.fourStars.dayElement}）`)
                    .fontSize(13)
                    .fontColor('#333333')
                }
                .width('100%')
                .margin({ bottom: 6 })

                Row() {
                  Text('时禽')
                    .fontSize(13)
                    .fontColor('#666666')
                    .width(60)
                  Text(this.fourStars.hourStarFull)
                    .fontSize(13)
                    .fontColor('#333333')
                }
                .width('100%')
                .margin({ bottom: 6 })

                Row() {
                  Text('用神')
                    .fontSize(13)
                    .fontColor('#666666')
                    .width(60)
                  Text(`${this.selectedUseGodStar}宿（${this.starRulesConfig!.constellations_full[this.selectedUseGodStar]?.full_name || ''}）→ 落${this.resultBranch}宫`)
                    .fontSize(13)
                    .fontColor('#2d5a3d')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#fafaf8')
              .borderRadius(10)
              .margin({ bottom: 12 })

              // 核心断语
              Column() {
                Text(this.resultSummary)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#2d5a3d')
                  .width('100%')

                Divider()
                  .color('#e8e8e8')
                  .margin({ top: 12, bottom: 12 })

                Text(this.resultDetail)
                  .fontSize(14)
                  .fontColor('#444444')
                  .lineHeight(22)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#f5f9f6')
              .borderRadius(12)

              // 免责声明
              Text('∗ 以上内容仅供传统文化研习参考，不构成任何现实指导。')
                .fontSize(11)
                .fontColor('#aaaaaa')
                .margin({ top: 16 })
                .textAlign(TextAlign.Center)
                .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 32 })
          }
        } else {
          // 加载中
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#888888')
            Text('正在加载配置...')
              .fontSize(14)
              .fontColor('#888888')
              .margin({ top: 12 })
          }
          .width('100%')
          .padding({ top: 60 })
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f1ed')
    .scrollBar(BarState.Off)
  }
}
