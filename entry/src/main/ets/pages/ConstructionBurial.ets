import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { loadBurialRulesConfig, calcBurialPrediction, BurialRulesConfig, BurialResult } from '../utils/Knowledge15x';
import { getQiYaoTypeFromStar, getQiYaoInfo, QiYaoInfo } from '../utils/QiYaoUtils';
import { evaluateDayQuality, DayQualityEvaluation } from '../utils/BaoYiZhuanUtils';
import { getStarEventEvaluation } from '../utils/StarEventRulesUtils';

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
  @State dayQiYaoInfo: QiYaoInfo | null = null;
  @State dayLevelInfo: DayQualityEvaluation | null = null;

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
      
      // 获取七曜信息
      const qiYaoType = getQiYaoTypeFromStar(dayStar);
      if (qiYaoType) {
        this.dayQiYaoInfo = getQiYaoInfo(qiYaoType);
      }
      
      // 评估宝义专日
      this.dayLevelInfo = evaluateDayQuality(info.day_gan, info.year_gan);
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

  private getBurialStarHint(): string {
    if (!this.currentDayStar) {
      return '';
    }
    const evalResult = getStarEventEvaluation(this.currentDayStar, '埋葬安葬');
    if (!evalResult) {
      return '';
    }
    let levelLabel: string = '';
    if (evalResult.level === 'greatGood') {
      levelLabel = '大吉';
    } else if (evalResult.level === 'good') {
      levelLabel = '可用';
    } else if (evalResult.level === 'neutral') {
      levelLabel = '平平';
    } else {
      levelLabel = '不宜';
    }
    return `${evalResult.name}（${levelLabel}）：${evalResult.reason}`;
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
            
            // ========== 七曜与宝义专日建议 ==========
            if (this.dayQiYaoInfo && this.dayLevelInfo) {
              this.QiYaoBaoYiZhuanCard()

              if (this.getBurialStarHint() !== '') {
                Column() {
                  Row() {
                    Text('📌')
                      .fontSize(12)
                      .margin({ right: 4 })
                    Text('二十八宿造葬用事提示')
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#92400e')
                  }
                  .margin({ bottom: 2 })

                  Text(this.getBurialStarHint())
                    .fontSize(11)
                    .fontColor('#92400e')
                    .width('100%')
                }
                .width('100%')
                .padding({ top: 6, bottom: 6, left: 8, right: 8 })
                .margin({ top: 8, left: 16, right: 16 })
                .backgroundColor('#fffbeb')
                .borderRadius(6)
              }
            }
            
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

  @Builder
  QiYaoBaoYiZhuanCard() {
    Column() {
      Text('── 本日七曜与宝义专日建议 ──')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })

      Row() {
        // 左侧：七曜总断
        Column() {
          Row() {
            Text('🌟')
              .fontSize(16)
              .margin({ right: 4 })
            Text(this.dayQiYaoInfo!.name)
              .fontSize(13)
              .fontColor(this.dayQiYaoInfo!.color)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ bottom: 8 })

          Text('性质：' + this.dayQiYaoInfo!.nature)
            .fontSize(11)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 6 })

          if (this.dayQiYaoInfo!.suitableEvents.filter(e => e !== '埋葬' && e !== '阴宅修造' && e !== '百事皆宜').length > 0) {
            Text('✅ ' + this.dayQiYaoInfo!.suitableEvents.filter(e => e !== '埋葬' && e !== '阴宅修造' && e !== '百事皆宜').slice(0, 3).join('、'))
              .fontSize(11)
              .fontColor('#4caf50')
              .width('100%')
              .margin({ bottom: 4 })
          }

          if (this.dayQiYaoInfo!.avoidEvents.filter(e => e !== '百事皆忌').length > 0) {
            Text('❌ ' + this.dayQiYaoInfo!.avoidEvents.filter(e => e !== '百事皆忌').slice(0, 3).join('、'))
              .fontSize(11)
              .fontColor('#f44336')
              .width('100%')
          }
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#f5f5f5')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)

        // 右侧：宝义专日
        Column() {
          Row() {
            Text(this.dayLevelInfo!.dayLevelInfo.emoji)
              .fontSize(16)
              .margin({ right: 4 })
            Text(this.dayLevelInfo!.dayLevelInfo.name)
              .fontSize(13)
              .fontColor(this.dayLevelInfo!.dayLevelInfo.color)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ bottom: 8 })

          Text(this.dayLevelInfo!.dayLevelInfo.description)
            .fontSize(11)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 6 })

          if (this.dayLevelInfo!.isChenFanJun) {
            Text('⚠️ 臣犯君大忌')
              .fontSize(11)
              .fontColor('#f44336')
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .padding(6)
              .backgroundColor('#ffebee')
              .borderRadius(6)
              .margin({ bottom: 6 })
          }

          Text('💡 ' + this.dayLevelInfo!.recommendation.slice(0, 30) + '...')
            .fontSize(10)
            .fontColor('#2196f3')
            .width('100%')
            .lineHeight(14)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#e3f2fd')
        .borderRadius(10)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
      }
      .width('100%')

      // 适配建议
      if (this.dayQiYaoInfo!.suitableEvents.includes('埋葬') || this.dayQiYaoInfo!.name === '月曜' || this.dayQiYaoInfo!.name === '火曜') {
        Text('✨ 当日七曜' + this.dayQiYaoInfo!.name + '，适宜造葬事宜！')
          .fontSize(12)
          .fontColor('#3d6b4f')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 10 })
          .padding(8)
          .backgroundColor('#d1fae5')
          .borderRadius(8)
      } else if (this.dayQiYaoInfo!.avoidEvents.includes('阴宅修造') || this.dayQiYaoInfo!.name === '水曜' || this.dayQiYaoInfo!.name === '土曜') {
        Text('⚠️ 当日七曜' + this.dayQiYaoInfo!.name + '，不宜造葬，请慎重选择！')
          .fontSize(12)
          .fontColor('#991b1b')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ top: 10 })
          .padding(8)
          .backgroundColor('#fee2e2')
          .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(14)
    .margin({ left: 16, right: 16, bottom: 16 })
  }
}
