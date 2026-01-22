import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { getQiYaoTypeFromStar, getQiYaoInfo, QiYaoInfo, getAllEventTypes, getEventSuggestion, EventSuggestion } from '../utils/QiYaoUtils';
import { evaluateDayQuality, getDayLevelByGan, DayQualityEvaluation } from '../utils/BaoYiZhuanUtils';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';

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

interface YanqinStarRulesConfig {
  constellations_order: Array<string>;
  constellations_full: Record<string, ConstellationInfo>;
  year_star_rules: YearStarRules;
  month_star_rules: MonthStarRules;
  day_star_rules: DayStarRules;
}

interface AuspiciousDay {
  date: string;
  year: number;
  month: number;
  day: number;
  dayStar: string;
  dayStarFull: string;
  qiYaoInfo: QiYaoInfo;
  dayLevelInfo: DayQualityEvaluation;
  dayGan: string;
  dayZhi: string;
  score: number;
  reason: string;
}

@Entry
@Component
struct SmartDateSelector {
  private context = getContext(this) as common.Context;

  @State hasLoaded: boolean = false;
  @State isSearching: boolean = false;
  @State starRulesConfig: YanqinStarRulesConfig | null = null;

  // 用户选择
  @State selectedEventType: string = '嫁娶纳妾';
  @State searchDays: number = 30;

  // 搜索结果
  @State auspiciousDays: AuspiciousDay[] = [];
  @State hasSearched: boolean = false;

  private eventTypes: string[] = [];

  aboutToAppear(): void {
    this.eventTypes = getAllEventTypes();
    this.initData();
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
      console.error('Failed to load: ' + fileName);
      return null;
    }
  }

  // 计算日禽
  private calculateDayStar(year: number, month: number, day: number): string {
    if (!this.starRulesConfig) return '';
    
    const cfg = this.starRulesConfig;
    const constellations = cfg.constellations_order;
    const dayRules = cfg.day_star_rules;
    
    const baseDateStr = dayRules.base_date.date;
    const baseParts = baseDateStr.split('-');
    const baseYear = parseInt(baseParts[0]);
    const baseMonth = parseInt(baseParts[1]);
    const baseDay = parseInt(baseParts[2]);
    
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
    
    return constellations[dayStarIndex];
  }

  // 智能搜索吉日
  private async searchAuspiciousDays(): Promise<void> {
    if (!this.starRulesConfig || !this.selectedEventType) {
      return;
    }

    this.isSearching = true;
    this.auspiciousDays = [];

    const suggestion = getEventSuggestion(this.selectedEventType);
    if (!suggestion) {
      this.isSearching = false;
      return;
    }

    const today = new Date();
    const results: AuspiciousDay[] = [];

    // 搜索未来N天
    for (let i = 0; i < this.searchDays; i++) {
      const checkDate = new Date(today);
      checkDate.setDate(today.getDate() + i);

      const year = checkDate.getFullYear();
      const month = checkDate.getMonth() + 1;
      const day = checkDate.getDate();

      // 计算日禽
      const dayStar = this.calculateDayStar(year, month, day);
      const qiYaoType = getQiYaoTypeFromStar(dayStar);
      if (!qiYaoType) continue;

      const qiYaoInfo = getQiYaoInfo(qiYaoType);

      // 获取万年历信息
      const dayInfo = await CalendarManager.getInstance().getDayInfo(year, month, day);
      if (!dayInfo) continue;

      // 评估宝义专日
      const dayLevelInfo = evaluateDayQuality(dayInfo.day_gan, dayInfo.year_gan);

      // 评分逻辑
      let score = 50; // 基础分
      let reason = '';

      // 七曜适配（最高优先级）
      if (suggestion.preferredQiYao.includes(qiYaoType)) {
        score += 30;
        reason += `${qiYaoInfo.name}大吉；`;
      } else if (suggestion.forbiddenQiYao.includes(qiYaoType)) {
        score -= 40;
        reason += `${qiYaoInfo.name}大凶；`;
        continue; // 跳过凶日
      } else if (suggestion.alternativeQiYao.includes(qiYaoType)) {
        score += 15;
        reason += `${qiYaoInfo.name}次吉；`;
      }

      // 宝义专日加分
      if (dayLevelInfo.dayLevel === 'bao') {
        score += 25;
        reason += '宝日；';
      } else if (dayLevelInfo.dayLevel === 'yi') {
        score += 15;
        reason += '义日；';
      } else if (dayLevelInfo.dayLevel === 'zhuan') {
        score += 15;
        reason += '专日；';
      } else if (dayLevelInfo.dayLevel === 'fa') {
        score -= 30;
        reason += '伐日大凶；';
        continue; // 跳过伐日
      }

      // 臣犯君扣分
      if (dayLevelInfo.isChenFanJun) {
        score -= 35;
        reason += '臣犯君；';
        continue; // 跳过臣犯君
      }

      // 只保留70分以上的吉日
      if (score >= 70) {
        const dayStarInfo = this.starRulesConfig.constellations_full[dayStar];
        const auspDay: AuspiciousDay = {
          date: `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`,
          year,
          month,
          day,
          dayStar,
          dayStarFull: dayStarInfo.full_name,
          qiYaoInfo,
          dayLevelInfo,
          dayGan: dayInfo.day_gan,
          dayZhi: dayInfo.day_zhi,
          score,
          reason: reason.slice(0, -1) // 去掉最后的分号
        };
        results.push(auspDay);
      }
    }

    // 按分数降序排序
    results.sort((a, b) => b.score - a.score);

    this.auspiciousDays = results;
    this.hasSearched = true;
    this.isSearching = false;
  }

  build() {
    Scroll() {
      Column() {
        // 顶部导航
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#333333')
            .onClick(() => router.back())
          Text('智能择日助手')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
            .margin({ left: 12 })
          Blank()
          Text('📅')
            .fontSize(20)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        if (this.hasLoaded) {
          // 事体选择区
          Column() {
            Text('请选择事体类型')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 10 })

            Grid() {
              ForEach(this.eventTypes, (eventType: string) => {
                GridItem() {
                  Column() {
                    Text(eventType)
                      .fontSize(14)
                      .fontColor(this.selectedEventType === eventType ? '#ffffff' : '#333333')
                      .fontWeight(this.selectedEventType === eventType ? FontWeight.Bold : FontWeight.Normal)
                  }
                  .width('100%')
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.selectedEventType === eventType ? '#3d6b4f' : '#f5f5f5')
                  .borderRadius(8)
                  .onClick(() => {
                    this.selectedEventType = eventType;
                    this.hasSearched = false;
                  })
                }
              }, (eventType: string) => eventType)
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .width('100%')
            .margin({ bottom: 16 })

            // 搜索天数选择
            Row() {
              Text('搜索范围：')
                .fontSize(13)
                .fontColor('#666666')
              
              Radio({ value: '30', group: 'searchDays' })
                .checked(this.searchDays === 30)
                .onChange(() => { this.searchDays = 30 })
                .width(18)
                .height(18)
              Text('未来30天')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ left: 4, right: 12 })

              Radio({ value: '60', group: 'searchDays' })
                .checked(this.searchDays === 60)
                .onChange(() => { this.searchDays = 60 })
                .width(18)
                .height(18)
              Text('未来60天')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ left: 4 })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 搜索按钮
            Button(this.isSearching ? '正在搜索...' : '🔍 开始智能择日')
              .fontSize(15)
              .fontColor('#ffffff')
              .backgroundColor('#3d6b4f')
              .width('100%')
              .height(48)
              .enabled(!this.isSearching)
              .onClick(() => {
                this.searchAuspiciousDays();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, top: 16, bottom: 16 })

          // 搜索结果
          if (this.hasSearched) {
            if (this.auspiciousDays.length > 0) {
              Column() {
                Row() {
                  Text('🎯 推荐吉日')
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                  Blank()
                  Text(`共${this.auspiciousDays.length}天`)
                    .fontSize(12)
                    .fontColor('#888888')
                }
                .width('100%')
                .margin({ bottom: 12 })

                ForEach(this.auspiciousDays, (day: AuspiciousDay, index: number) => {
                  this.AuspiciousDayCard(day, index + 1)
                }, (day: AuspiciousDay) => day.date)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#ffffff')
              .borderRadius(14)
              .margin({ left: 16, right: 16, bottom: 16 })
            } else {
              Column() {
                Text('😔')
                  .fontSize(48)
                  .margin({ bottom: 8 })
                Text('未找到合适的吉日')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 4 })
                Text('建议扩大搜索范围或更换事体')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#ffffff')
              .borderRadius(14)
              .margin({ left: 16, right: 16, bottom: 16 })
            }
          }

        } else {
          Column() {
            LoadingProgress().width(40).height(40).color('#3d6b4f')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
          }
          .width('100%')
          .height(300)
          .justifyContent(FlexAlign.Center)
        }

        // 底部说明
        Column() {
          Text('💡 择日说明')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 8 })
          
          Text('• 七曜总断：根据事体匹配适配禽星')
            .fontSize(11)
            .fontColor('#888888')
            .width('100%')
            .margin({ bottom: 4 })
          
          Text('• 宝义专日：优选宝日、义日、专日')
            .fontSize(11)
            .fontColor('#888888')
            .width('100%')
            .margin({ bottom: 4 })
          
          Text('• 自动排除：伐日、臣犯君等凶日')
            .fontSize(11)
            .fontColor('#888888')
            .width('100%')
            .margin({ bottom: 4 })
          
          Text('• 综合评分：70分以上为推荐吉日')
            .fontSize(11)
            .fontColor('#888888')
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#f5f5f5')
        .borderRadius(14)
        .margin({ left: 16, right: 16, bottom: 20 })
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f8f8')
    .scrollBar(BarState.Off)
  }

  @Builder
  AuspiciousDayCard(day: AuspiciousDay, rank: number) {
    Column() {
      Row() {
        // 排名徽章
        Text(rank.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .width(28)
          .height(28)
          .textAlign(TextAlign.Center)
          .backgroundColor(rank === 1 ? '#ffd700' : rank === 2 ? '#c0c0c0' : rank === 3 ? '#cd7f32' : '#999999')
          .borderRadius(14)
          .margin({ right: 10 })

        Column() {
          Text(`${day.month}月${day.day}日`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text(`${day.dayGan}${day.dayZhi}日 · ${day.dayStarFull}`)
            .fontSize(11)
            .fontColor('#888888')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 评分
        Column() {
          Text(day.score.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(day.score >= 90 ? '#4caf50' : day.score >= 80 ? '#ff9800' : '#2196f3')
          Text('分')
            .fontSize(10)
            .fontColor('#888888')
        }
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 七曜与宝义专日
      Row() {
        Column() {
          Text(day.qiYaoInfo.name)
            .fontSize(12)
            .fontColor(day.qiYaoInfo.color)
            .fontWeight(FontWeight.Bold)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(day.qiYaoInfo.color + '20')
        .borderRadius(4)

        Column() {
          Text(day.dayLevelInfo.dayLevelInfo.emoji + ' ' + day.dayLevelInfo.dayLevelInfo.name)
            .fontSize(12)
            .fontColor(day.dayLevelInfo.dayLevelInfo.color)
            .fontWeight(FontWeight.Bold)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(day.dayLevelInfo.dayLevelInfo.color + '20')
        .borderRadius(4)
        .margin({ left: 6 })

        Blank()

        Text(day.reason)
          .fontSize(10)
          .fontColor('#666666')
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#fafafa')
    .borderRadius(10)
    .margin({ bottom: 10 })
    .border({ width: 1, color: rank <= 3 ? '#3d6b4f' : '#e0e0e0' })
  }
}
