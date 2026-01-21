import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { CalendarManager } from '../utils/CalendarManager';

// ============== 接口定义 ==============

interface ConstellationInfo {
  full_name: string;
  element: string;
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
}

interface DayStarRules {
  base_date: DayStarBaseDate;
  four_generals: Record<string, Array<string>>;
}

interface HourStarRules {
  element_to_start_star: Record<string, string>;
}

interface YanqinStarRulesConfig {
  constellations_order: Array<string>;
  constellations_full: Record<string, ConstellationInfo>;
  year_star_rules: YearStarRules;
  month_star_rules: MonthStarRules;
  day_star_rules: DayStarRules;
  hour_star_rules: HourStarRules;
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

@Entry
@Component
struct Index {
  private context = getContext(this) as common.Context;

  @State hasLoaded: boolean = false;
  @State starRulesConfig: YanqinStarRulesConfig | null = null;

  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State selectedHourIndex: number = this.getCurrentHourIndex();

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
    CalendarManager.getInstance().init(this.context);
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
    if (starRules) {
      this.starRulesConfig = starRules;
      this.hasLoaded = true;
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

  private calculateDayStar(year: number, month: number, day: number, cfg: YanqinStarRulesConfig): DayStarCalcResult {
    const constellations = cfg.constellations_order;
    const dayRules = cfg.day_star_rules;

    // 解析基准日期字符串 "1984-02-02"
    const baseDateStr = dayRules.base_date.date;
    const baseParts = baseDateStr.split('-');
    const baseYear = parseInt(baseParts[0]);
    const baseMonth = parseInt(baseParts[1]);
    const baseDay = parseInt(baseParts[2]);
    
    // 统一使用本地时间创建 Date 对象，避免时区问题
    const baseDate = new Date(baseYear, baseMonth - 1, baseDay);
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
      jiangIndex: jiangIndex + 1,
      jiangStar: jiangStar  // 返回四将符头
    };
    return result;
  }

  private getDateString(): string {
    return `${this.selectedYear}年${this.selectedMonth}月${this.selectedDay}日`;
  }

  // ============== UI 构建 ==============

  build() {
    Scroll() {
      Column() {
        // 顶部标题
        Column() {
          Text('禽星演寻')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
          Text('传统演禽术 · 数字化研习平台')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 60, bottom: 30 })
        .alignItems(HorizontalAlign.Center)

        if (this.hasLoaded) {
          // ========== 日期快速预览/选择 ==========
          Column() {
            Row() {
              Text('📅 当前选定')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              Text(this.getDateString())
                .fontSize(14)
                .fontColor('#3d6b4f')
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#ffffff')
            .borderRadius(14)
            .margin({ bottom: 20 })
            .border({ width: 1, color: '#e0e0e0' })
          }
          .padding({ left: 16, right: 16 })

          // ========== 核心功能入口 (2列网格) ==========
          Grid() {
            GridItem() {
              this.MenuCard('📍', '方位推演', '走失寻物·取象', '#3d6b4f', '#f5f9f6', 'pages/LostItemsSearch')
            }
            GridItem() {
              this.MenuCard('📅', '演禽盘式', '三传四课·排盘', '#1a5276', '#e8f4fc', 'pages/YanQinPanShi')
            }
            GridItem() {
              this.MenuCard('🌌', '演禽气象', '天时预测·晴雨', '#0369a1', '#f0f9ff', 'pages/WeatherMeteorology')
            }
            GridItem() {
              this.MenuCard('🏗️', '演禽造葬', '施工动土·避忌', '#7c2d12', '#fff7ed', 'pages/ConstructionBurial')
            }
            GridItem() {
              this.MenuCard('📚', '知识点与案例库', '高阶规则·案例', '#4c1d95', '#f5f3ff', 'pages/AdvancedStudyCases')
            }
            GridItem() {
              this.MenuCard('📝', '学习文档', '分级学习路径', '#1f2937', '#f3f4f6', 'pages/AdvancedStudyCases')
            }
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .padding({ left: 16, right: 16, bottom: 30 })
          .width('100%')
          .height(420)
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

        // 底部版本信息
        Text('Version 1.2.0 · 传统文化数字化')
          .fontSize(10)
          .fontColor('#cccccc')
          .margin({ bottom: 20 })
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f2f1ed')
    .scrollBar(BarState.Off)
  }

  @Builder
  MenuCard(icon: string, title: string, desc: string, color: string, bgColor: string, url: string) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 8 })
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(desc)
        .fontSize(10)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(130)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bgColor)
    .borderRadius(16)
    .border({ width: 1, color: color, style: BorderStyle.Solid })
    .onClick(() => {
      router.pushUrl({
        url: url,
        params: {
          year: this.selectedYear,
          month: this.selectedMonth,
          day: this.selectedDay,
          hourIndex: this.selectedHourIndex
        }
      });
    })
  }
}
