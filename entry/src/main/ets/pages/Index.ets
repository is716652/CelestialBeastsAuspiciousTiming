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
  @State dayStarResult: DayStarCalcResult | null = null;

  private starEmojiMap: Record<string, string> = {
    '角': '🐉', '亢': '🐲', '氐': '🦡', '房': '🐰', '心': '🦊', '尾': '🐯', '箵': '🐆',
    '斗': '獬', '牛': '🐂', '女': '蝙', '虚': '🐀', '危': '🕊️', '室': '🐖', '壁': '🦌',
    '奎': '🐺', '娄': '🐕', '胃': '雉', '昂': '🐓', '毕': '🐦', '觜': '🐒', '参': '🦍',
    '井': '🐕', '鬼': '🐏', '柳': '🦌', '星': '🐎', '张': '🦌', '翼': '🐍', '轸': '🐛'
  };

  private starToSymbolMap: Record<string, string> = {
    '角': '东方青龙', '亢': '东方青龙', '氐': '东方青龙', '房': '东方青龙', '心': '东方青龙', '尾': '东方青龙', '箕': '东方青龙',
    '斗': '北方玄武', '牛': '北方玄武', '女': '北方玄武', '虚': '北方玄武', '危': '北方玄武', '室': '北方玄武', '壁': '北方玄武',
    '奎': '西方白虎', '娄': '西方白虎', '胃': '西方白虎', '昴': '西方白虎', '毕': '西方白虎', '觜': '西方白虎', '参': '西方白虎',
    '井': '南方朱雀', '鬼': '南方朱雀', '柳': '南方朱雀', '星': '南方朱雀', '张': '南方朱雀', '翼': '南方朱雀', '轸': '南方朱雀'
  };

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
      this.dayStarResult = this.calculateDayStar(this.selectedYear, this.selectedMonth, this.selectedDay, starRules);
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
        if (this.hasLoaded && this.dayStarResult) {
          // ========== 顶部：神秘演禽天盘 (Celestial Disk) ==========
          Stack() {
            // 1. 沉浸式星空背景图
            Image($r('app.media.qinxing_celestial_bg'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
            
            // 2. 核心信息展示层
            Column() {
              // 日禽：[全称]
              Text('日禽 · ' + this.dayStarResult.fullName)
                .fontSize(36)
                .fontWeight(FontWeight.Bolder)
                .fontColor('#ffffff')
                .shadow({ radius: 20, color: '#000000', offsetX: 4, offsetY: 4 })
              
              // 术语归属 (东方青龙/北方玄武 等)
              Text(this.starToSymbolMap[this.dayStarResult.star] || '')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#d4af37') // 古典金，与星图质感匹配
                .margin({ top: 15 })
                .shadow({ radius: 10, color: '#000000', offsetX: 2, offsetY: 2 })

              // 选定日期
              Text(this.getDateString())
                .fontSize(14)
                .fontColor('#ffffff') // 纯白色文字
                .margin({ top: 40 })
                .padding({ left: 18, right: 18, top: 8, bottom: 8 })
                .backgroundColor('#00000088') // 深黑色半透明背景，确保对比度
                .borderRadius(20)
                .border({ width: 0.5, color: '#ffffff44' })
            }
            .width('100%')
          }
          .width('100%')
          .height(420)
          .clip(true)

          // ========== 功能导航区域 ==========
          Column() {
            Text('—— 演禽秘要 · 功法模块 ——')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ top: 20, bottom: 20 })

            Grid() {
              GridItem() {
                this.MenuCard('📍', '方位推演', '寻物占测', '#3d6b4f', 'pages/LostItemsSearch')
              }
              GridItem() {
                this.MenuCard('🧭', '演禽盘式', '三传四课', '#1a5276', 'pages/YanQinPanShi')
              }
              GridItem() {
                this.MenuCard('☁️', '演禽气象', '天时占雨', '#0284c7', 'pages/WeatherMeteorology')
              }
              GridItem() {
                this.MenuCard('🏗️', '演禽造葬', '动土择吉', '#b45309', 'pages/ConstructionBurial')
              }
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(15)
            .rowsGap(15)
            .padding({ left: 20, right: 20 })
            .width('100%')
            .height(240)

            // 底部次级模块
            Row() {
              this.SmallActionCard('案例库', 'pages/AdvancedStudyCases')
              this.SmallActionCard('知识图谱', 'pages/KnowledgeGraph')
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 20 })
            .margin({ bottom: 40 })
          }
          .width('100%')
          .backgroundColor('#f8f8f8') // 下方功能区回归浅色，对比出天盘的深邃
          .borderRadius({ topLeft: 30, topRight: 30 }) // 圆格过渡
          .margin({ top: -30 }) // 与天盘衔接

        } else {
          // 加载中
          Column() {
            LoadingProgress().width(40).height(40).color('#3d6b4f')
            Text('开启演禽秘境...').fontSize(14).fontColor('#666666').margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
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
  SmallActionCard(title: string, url: string) {
    Column() {
      // 根据标题条件渲染图标
      if (title === '知识图谱') {
        Image($r('app.media.knowledge_graph_icon'))
          .width(40)
          .height(40)
          .borderRadius(8)
          .margin({ bottom: 6 })
      } else if (title === '案例库') {
        Image($r('app.media.case_library_icon'))
          .width(40)
          .height(40)
          .borderRadius(8)
          .margin({ bottom: 6 })
      }

      Text(title)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#555555')
    }
    .layoutWeight(1)
    .height(80)
    .margin({ left: 4, right: 4 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .border({ width: 1, color: '#e0e0e0' })
    .onClick(() => {
      router.pushUrl({ url: url })
    })
  }

  @Builder
  MenuCard(icon: string, title: string, desc: string, color: string, url: string) {
    Column() {
      // 所有功能卡片均使用图片图标
      if (title === '演禽盘式') {
        Image($r('app.media.yanqin_pan_icon'))
          .width(50)
          .height(50)
          .borderRadius(25)
          .margin({ bottom: 6 })
      } else if (title === '演禽气象') {
        Image($r('app.media.weather_icon'))
          .width(50)
          .height(50)
          .borderRadius(25)
          .margin({ bottom: 6 })
      } else if (title === '演禽造葬') {
        Image($r('app.media.fengshui_icon'))
          .width(50)
          .height(50)
          .borderRadius(25)
          .margin({ bottom: 6 })
      } else if (title === '方位推演') {
        Image($r('app.media.lost_items_icon'))
          .width(50)
          .height(50)
          .borderRadius(25)
          .margin({ bottom: 6 })
      } else {
        Text(icon)
          .fontSize(28)
          .margin({ bottom: 6 })
      }
      
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
      Text(desc)
        .fontSize(10)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height(110) // 调高以适应图片
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#ffffff')
    .borderRadius(18)
    .shadow({ radius: 8, color: '#00000005', offsetX: 0, offsetY: 2 })
    .border({ width: 1, color: '#f0f0f0' })
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
