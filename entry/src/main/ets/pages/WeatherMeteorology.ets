import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { calcWeatherPrediction, WeatherResult } from '../utils/Knowledge15x';

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
struct WeatherMeteorology {
  private context = getContext(this) as common.Context;

  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State dayInfo: CalendarDayInfo | null = null;
  @State weatherResult: WeatherResult | null = null;
  @State starRulesConfig: YanqinStarRulesConfig | null = null;

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
    this.loadData();
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

  private async loadData(): Promise<void> {
    try {
      const value = await this.context.resourceManager.getRawFileContent('yanqin_star_rules.json');
      this.starRulesConfig = ArkJSON.parse(buffer.from(value.buffer).toString()) as YanqinStarRulesConfig;
      this.calculateWeather();
    } catch (err) {}
  }

  private async calculateWeather(): Promise<void> {
    if (!this.starRulesConfig) return;
    const info = await CalendarManager.getInstance().getDayInfo(this.selectedYear, this.selectedMonth, this.selectedDay);
    this.dayInfo = info;
    if (info) {
      // 计算日宿五行
      const dayStar = this.calculateDayStar(this.selectedYear, this.selectedMonth, this.selectedDay);
      const starElement = this.starRulesConfig.constellations_full[dayStar]?.element || '土';
      this.weatherResult = calcWeatherPrediction(info, starElement);
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
        Text('🌌 演禽气象').fontSize(20).fontWeight(FontWeight.Bold)
        Blank()
        Text('返回').onClick(() => router.back())
      }
      .width('100%').padding({ left: 16, right: 16, top: 40, bottom: 16 }).backgroundColor('#ffffff')

      Scroll() {
        Column() {
          Column() {
            Text('查看特定日期天时').fontSize(14).margin({ bottom: 10 })
            Row() {
              Select(this.yearOptions).selected(this.selectedYear-1900).value(`${this.selectedYear}年`).layoutWeight(1).onSelect(v=>{this.selectedYear=1900+v;this.updateDayOptions();this.calculateWeather();})
              Select(this.monthOptions).selected(this.selectedMonth-1).value(`${this.selectedMonth}月`).layoutWeight(1).margin({left:8}).onSelect(v=>{this.selectedMonth=v+1;this.updateDayOptions();this.calculateWeather();})
              Select(this.dayOptions).selected(this.selectedDay-1).value(`${this.selectedDay}日`).layoutWeight(1).margin({left:8}).onSelect(v=>{this.selectedDay=v+1;this.calculateWeather();})
            }
          }
          .padding(16).backgroundColor('#ffffff').borderRadius(12).margin(16)

          if (this.weatherResult) {
            Column() {
              Row() {
                Text(this.weatherResult.label).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#0369a1')
                Text(' (预判)').fontSize(14).fontColor('#666666')
              }.margin({ bottom: 16 })
              Text(this.weatherResult.description).fontSize(16).lineHeight(24).fontColor('#333333')
            }
            .padding(24).backgroundColor('#f0f9ff').borderRadius(16).margin(16).border({ width: 1, color: '#bae6fd' })
          }
        }
      }
    }
    .width('100%').height('100%').backgroundColor('#f8f8f8')
  }
}
