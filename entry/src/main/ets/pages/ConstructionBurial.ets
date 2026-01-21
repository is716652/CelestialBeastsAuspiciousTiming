import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { loadBurialRulesConfig, calcBurialPrediction, BurialRulesConfig, BurialResult } from '../utils/Knowledge15x';

interface ConstellationInfo {
  full_name: string;
  element: string;
}

interface DayStarBaseDate {
  date: string;
}

interface DayStarRules {
  base_date: DayStarBaseDate;
  four_generals: Record<string, Array<string>>;
}

interface YanqinStarRulesConfig {
  constellations_order: Array<string>;
  constellations_full: Record<string, ConstellationInfo>;
  day_star_rules: DayStarRules;
}

@Entry
@Component
struct ConstructionBurial {
  private context = getContext(this) as common.Context;

  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State dayInfo: CalendarDayInfo | null = null;
  @State burialResult: BurialResult | null = null;
  @State starRulesConfig: YanqinStarRulesConfig | null = null;
  @State burialRulesConfig: BurialRulesConfig | null = null;
  @State currentDayStar: string = '';

  @State yearOptions: SelectOption[] = [];
  @State monthOptions: SelectOption[] = [];
  @State dayOptions: SelectOption[] = [];

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>;
    if (params) {
      this.selectedYear = params.year || this.selectedYear;
      this.selectedMonth = params.month || this.selectedMonth;
      this.selectedDay = params.day || this.selectedDay;
    }
    this.initOptions();
    CalendarManager.getInstance().init(this.context);
    this.checkRules();
  }

  private initOptions(): void {
    for (let y = 1900; y <= 2061; y++) this.yearOptions.push({ value: `${y}年` });
    for (let m = 1; m <= 12; m++) this.monthOptions.push({ value: `${m}月` });
    this.updateDayOptions();
  }

  private updateDayOptions(): void {
    const daysInMonth = new Date(this.selectedYear, this.selectedMonth, 0).getDate();
    this.dayOptions = [];
    for (let d = 1; d <= daysInMonth; d++) this.dayOptions.push({ value: `${d}日` });
    if (this.selectedDay > daysInMonth) this.selectedDay = daysInMonth;
  }

  private async checkRules(): Promise<void> {
    if (!this.starRulesConfig) {
      try {
        const value = await this.context.resourceManager.getRawFileContent('yanqin_star_rules.json');
        this.starRulesConfig = ArkJSON.parse(buffer.from(value.buffer).toString()) as YanqinStarRulesConfig;
      } catch (err) {}
    }
    
    if (!this.burialRulesConfig) {
      this.burialRulesConfig = await loadBurialRulesConfig(this.context);
    }

    const info = await CalendarManager.getInstance().getDayInfo(this.selectedYear, this.selectedMonth, this.selectedDay);
    this.dayInfo = info;
    
    if (info && this.starRulesConfig && this.burialRulesConfig) {
      const dayStar = this.calculateDayStar(this.selectedYear, this.selectedMonth, this.selectedDay);
      this.currentDayStar = dayStar;
      this.burialResult = calcBurialPrediction(info, dayStar, this.burialRulesConfig);
    }
  }

  private calculateDayStar(year: number, month: number, day: number): string {
    const cfg = this.starRulesConfig!;
    const constellations = cfg.constellations_order;
    const baseParts = cfg.day_star_rules.base_date.date.split('-');
    const baseDate = new Date(parseInt(baseParts[0]), parseInt(baseParts[1]) - 1, parseInt(baseParts[2]));
    const diffDays = Math.floor((new Date(year, month - 1, day).getTime() - baseDate.getTime()) / 86400000);
    const posInCycle = ((diffDays % 420) + 420) % 420;
    const yuanName = ['一元', '二元', '三元', '四元', '五元', '六元', '七元'][Math.floor(posInCycle / 60)];
    const jiangIndex = Math.floor((posInCycle % 60) / 15);
    const jiangStar = cfg.day_star_rules.four_generals[yuanName][jiangIndex];
    return constellations[(constellations.indexOf(jiangStar) + (posInCycle % 15)) % 28];
  }

  build() {
    Column() {
      Row() {
        Text('🏗️ 演禽造葬').fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text('返回').fontSize(14).fontColor('#666666').onClick(() => router.back())
      }
      .width('100%').padding({ left: 16, right: 16, top: 40, bottom: 16 }).backgroundColor('#ffffff')

      Scroll() {
        Column() {
          Column() {
            Text('查看特定日期造葬避忌').fontSize(14).margin({ bottom: 10 }).fontColor('#666666')
            Row() {
              Select(this.yearOptions).selected(this.selectedYear - 1900).value(`${this.selectedYear}年`).layoutWeight(1).onSelect(v => {
                this.selectedYear = 1900 + v;
                this.updateDayOptions();
                this.checkRules();
              })
              Select(this.monthOptions).selected(this.selectedMonth - 1).value(`${this.selectedMonth}月`).layoutWeight(1).margin({ left: 8 }).onSelect(v => {
                this.selectedMonth = v + 1;
                this.updateDayOptions();
                this.checkRules();
              })
              Select(this.dayOptions).selected(this.selectedDay - 1).value(`${this.selectedDay}日`).layoutWeight(1).margin({ left: 8 }).onSelect(v => {
                this.selectedDay = v + 1;
                this.checkRules();
              })
            }
          }
          .padding(16).backgroundColor('#ffffff').borderRadius(12).margin(16)

          if (this.burialResult) {
            Column() {
              Row() {
                Text(`当前值日宿：${this.currentDayStar}宿`).fontSize(18).fontWeight(FontWeight.Bold)
                Blank()
                Text(this.burialResult.alias).fontSize(14).fontColor('#ffffff').backgroundColor('#3d6b4f').padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(4)
              }.width('100%').margin({ bottom: 12 })
              
              Text(`分类：${this.burialResult.groupName}（${this.burialResult.alias}）`).fontSize(14).fontColor('#666666').margin({ bottom: 8 })
              Text(this.burialResult.generalNote).fontSize(14).fontColor('#444444').fontStyle(FontStyle.Italic).margin({ bottom: 16 })
              
              Divider().margin({ bottom: 16 })
              
              Text('择日研习建议').fontSize(16).fontWeight(FontWeight.Bold).margin({ bottom: 8 })
              Text(this.burialResult.suggestions).fontSize(15).lineHeight(22).fontColor(this.burialResult.dayLuckyStatus === 'unlucky' ? '#991b1b' : '#3d6b4f')
              
              if (this.burialResult.isDengYuan) {
                Text('✨ 星宿登垣：当前星宿力量最强，吉凶应验迅速。').fontSize(13).fontColor('#854d0e').margin({ top: 12 })
              }
            }
            .padding(20).backgroundColor('#fff7ed').borderRadius(16).margin({ left: 16, right: 16, bottom: 16 }).border({ width: 1, color: '#fed7aa' })
            
            Column() {
              Text('【研习要点说明】').fontSize(14).fontWeight(FontWeight.Bold).margin({ bottom: 8 })
              Text('1. 登垣：禽星值其本宫之日，能量最旺。\n2. 纳音禁忌：择日需避开日干支纳音克星宿五行。\n3. 伏断：特定的星日组合，主气机不接，重大工程避之。').fontSize(13).lineHeight(20).fontColor('#666666')
            }
            .width('92%').padding(16).backgroundColor('#f3f4f6').borderRadius(12).margin({ bottom: 30 })
          }
        }
      }
    }
    .width('100%').height('100%').backgroundColor('#f8f8f8')
  }
}
