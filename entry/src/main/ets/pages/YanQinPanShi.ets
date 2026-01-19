import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';

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

interface HuoYaoRules {
  element_to_flip_star: Record<string, string>;
  start_branch: string;
}

interface QinClassification {
  天禽: Array<string>;
  地禽: Array<string>;
  水禽: Array<string>;
  家禽: Array<string>;
}

interface WuShiConfig {
  list: Array<string>;
}

interface TunDanConfig {
  food_map: Record<string, Array<string>>;
  wu_shi: WuShiConfig;
  animal_to_star: Record<string, string>;
}

interface RiYeQinConfig {
  日禽: Array<string>;
  夜禽: Array<string>;
  日夜通用: Array<string>;
}

interface YanqinStarRulesConfig {
  constellations_order: Array<string>;
  constellations_full: Record<string, ConstellationInfo>;
  branches_order: Array<string>;
  year_star_rules: YearStarRules;
  month_star_rules: MonthStarRules;
  day_star_rules: DayStarRules;
  hour_star_rules: HourStarRules;
  huo_yao_rules: HuoYaoRules;
  qin_classification: QinClassification;
  tun_dan: TunDanConfig;
  ri_ye_qin: RiYeQinConfig;
}

interface BranchEnvironment {
  inner: string;
  outer: string;
  element: string;
  direction: string;
}

interface SuoBoGe {
  name: string;
  text: string;
  result: string;
}

interface SuoBoRulesConfig {
  branch_environments: Record<string, BranchEnvironment>;
  suo_bo_ge: Record<string, SuoBoGe>;
}

interface StarCalcResult {
  star: string;
  fullName: string;
  element: string;
}

interface DayStarCalcResult extends StarCalcResult {
  yuanName: string;
  jiangIndex: number;
  jiangStar: string;
}

// 五禽排盘结果
interface WuQinResult {
  diQin: StarCalcResult;      // 地禽/时禽(我)
  tianQin: StarCalcResult;    // 天禽/翻禽(他)
  huoYao: StarCalcResult;     // 活曜/变禽
  yearStar: StarCalcResult;   // 年禽
  monthStar: StarCalcResult;  // 月禽
  dayStar: StarCalcResult;    // 日禽
}

// 锁泊格局结果
interface SuoBoResult {
  star: string;
  branch: string;
  environment: string;
  geName: string;
  geText: string;
  geResult: string;
}

// 页面参数
interface PageParams {
  year: number;
  month: number;
  day: number;
  hourIndex: number;
}

// 飞伏结果
interface FeifuResultSimple {
  status: string;
  desc: string;
}

@Entry
@Component
struct YanQinPanShi {
  private context = getContext(this) as common.Context;

  @State hasLoaded: boolean = false;
  @State starRulesConfig: YanqinStarRulesConfig | null = null;
  @State suoBoConfig: SuoBoRulesConfig | null = null;

  // 页面参数
  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State selectedHourIndex: number = 6;

  // 计算结果
  @State wuQinResult: WuQinResult | null = null;
  @State yuanName: string = '';
  @State jiangIndex: number = 0;
  @State jiangStar: string = '';

  // 锁泊结果
  @State diQinSuoBo: SuoBoResult | null = null;
  @State tianQinSuoBo: SuoBoResult | null = null;
  @State huoYaoSuoBo: SuoBoResult | null = null;

  // 吞啖结果
  @State tunDanDesc1: string = '';  // 地禽vs天禽
  @State tunDanDesc2: string = '';  // 天禽vs地禽

  // 飞伏状态
  @State feifuStatus: string = '';
  @State feifuDesc: string = '';

  // 三禽分类
  @State diQinType: string = '';
  @State tianQinType: string = '';

  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as PageParams;
    if (params) {
      this.selectedYear = params.year || this.selectedYear;
      this.selectedMonth = params.month || this.selectedMonth;
      this.selectedDay = params.day || this.selectedDay;
      this.selectedHourIndex = params.hourIndex ?? this.selectedHourIndex;
    }
    this.initData();
  }

  private async initData(): Promise<void> {
    const starRules = await this.loadJsonFromRaw<YanqinStarRulesConfig>('yanqin_star_rules.json');
    const suoBo = await this.loadJsonFromRaw<SuoBoRulesConfig>('suo_bo_rules.json');

    if (starRules) {
      this.starRulesConfig = starRules;
      this.suoBoConfig = suoBo;
      this.hasLoaded = true;
      this.calculateAll();
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

  private calculateAll(): void {
    if (!this.starRulesConfig) return;
    const cfg = this.starRulesConfig;

    // 1. 计算四禽
    const yearResult = this.calculateYearStar(this.selectedYear, cfg);
    const monthResult = this.calculateMonthStar(this.selectedMonth, yearResult.element, cfg);
    const dayResult = this.calculateDayStar(this.selectedYear, this.selectedMonth, this.selectedDay, cfg);
    const hourResult = this.calculateHourStar(this.selectedHourIndex, dayResult.element, cfg);

    this.yuanName = dayResult.yuanName;
    this.jiangIndex = dayResult.jiangIndex;
    this.jiangStar = dayResult.jiangStar;

    // 2. 计算翻禽和活曜
    const fanQinResult = this.calculateFanQin(dayResult.jiangStar, hourResult.star, this.selectedHourIndex, cfg);
    const huoYaoResult = this.calculateHuoYao(hourResult.star, hourResult.element, this.selectedHourIndex, cfg);

    this.wuQinResult = {
      diQin: hourResult,       // 时禽 = 地禽/我
      tianQin: fanQinResult,   // 翻禽 = 天禽/他
      huoYao: huoYaoResult,    // 活曜 = 变
      yearStar: yearResult,
      monthStar: monthResult,
      dayStar: { star: dayResult.star, fullName: dayResult.fullName, element: dayResult.element }
    };

    // 3. 锁泊格局判断
    const branches = cfg.branches_order;
    const diQinBranch = branches[this.selectedHourIndex];
    this.diQinSuoBo = this.judgeSuoBo(hourResult.star, diQinBranch, cfg);

    // 翻禽落宫计算
    const jiangStarIndex = cfg.constellations_order.indexOf(dayResult.jiangStar);
    const hourStarIndex = cfg.constellations_order.indexOf(hourResult.star);
    const forwardSteps = ((hourStarIndex - jiangStarIndex) + 28) % 28;
    const tianQinBranchIndex = (this.selectedHourIndex + forwardSteps) % 12;
    const tianQinBranch = branches[tianQinBranchIndex];
    this.tianQinSuoBo = this.judgeSuoBo(fanQinResult.star, tianQinBranch, cfg);

    // 活曜落宫计算
    const flipStar = cfg.huo_yao_rules.element_to_flip_star[hourResult.element];
    const flipStarIndex = cfg.constellations_order.indexOf(flipStar);
    const backwardSteps = ((hourStarIndex - flipStarIndex) + 28) % 28;
    const hourStarBranch = ((2 - backwardSteps % 12) + 12) % 12;
    const huoYaoForwardSteps = ((this.selectedHourIndex - hourStarBranch) + 12) % 12;
    const huoYaoIndex = cfg.constellations_order.indexOf(huoYaoResult.star);
    const huoYaoBranchIndex = (hourStarBranch + huoYaoForwardSteps) % 12;
    const huoYaoBranch = branches[this.selectedHourIndex]; // 活曜落用时
    this.huoYaoSuoBo = this.judgeSuoBo(huoYaoResult.star, huoYaoBranch, cfg);

    // 4. 三禽分类
    this.diQinType = this.getQinType(hourResult.star, cfg);
    this.tianQinType = this.getQinType(fanQinResult.star, cfg);

    // 5. 吞啖判断
    this.tunDanDesc1 = this.judgeTunDan(hourResult.star, fanQinResult.star, cfg);
    this.tunDanDesc2 = this.judgeTunDan(fanQinResult.star, hourResult.star, cfg);

    // 6. 飞伏判断
    const feifuResult = this.judgeFeifu(hourResult.star, this.selectedHourIndex, cfg);
    this.feifuStatus = feifuResult.status;
    this.feifuDesc = feifuResult.desc;
  }

  // ============== 四禽计算 ==============

  private calculateYearStar(year: number, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const baseYear = cfg.year_star_rules.base_year;
    const baseStar = cfg.year_star_rules.base_star;
    const baseIndex = constellations.indexOf(baseStar);
    const yearDiff = year - baseYear;
    const starIndex = ((yearDiff % 28) + 28 + baseIndex) % 28;
    const star = constellations[starIndex];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
  }

  private calculateMonthStar(month: number, yearElement: string, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const startStar = cfg.month_star_rules.element_to_start_star[yearElement];
    const startIndex = constellations.indexOf(startStar);
    const monthIndex = (startIndex + (month - 1)) % 28;
    const star = constellations[monthIndex];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
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
    return { star, fullName: info.full_name, element: info.element, yuanName, jiangIndex: jiangIndex + 1, jiangStar };
  }

  private calculateHourStar(hourIndex: number, dayElement: string, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const startStar = cfg.hour_star_rules.element_to_start_star[dayElement];
    const startIndex = constellations.indexOf(startStar);
    const hourStarIndex = (startIndex + hourIndex) % 28;
    const star = constellations[hourStarIndex];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
  }

  // ============== 翻禽/活曜计算 ==============

  private calculateFanQin(jiangStar: string, hourStar: string, hourIndex: number, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const jiangStarIndex = constellations.indexOf(jiangStar);
    const hourStarIndex = constellations.indexOf(hourStar);
    const forwardSteps = ((hourStarIndex - jiangStarIndex) + 28) % 28;
    const fanQinIndex = (hourStarIndex + forwardSteps) % 28;
    const star = constellations[fanQinIndex];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
  }

  private calculateHuoYao(hourStar: string, hourElement: string, hourIndex: number, cfg: YanqinStarRulesConfig): StarCalcResult {
    const constellations = cfg.constellations_order;
    const flipStar = cfg.huo_yao_rules.element_to_flip_star[hourElement];
    const flipStarIndex = constellations.indexOf(flipStar);
    const hourStarIndex = constellations.indexOf(hourStar);
    const backwardSteps = ((hourStarIndex - flipStarIndex) + 28) % 28;
    const hourStarBranch = ((2 - backwardSteps % 12) + 12) % 12;
    const forwardSteps = ((hourIndex - hourStarBranch) + 12) % 12;
    const huoYaoIndex = (hourStarIndex + forwardSteps) % 28;
    const star = constellations[huoYaoIndex];
    const info = cfg.constellations_full[star];
    return { star, fullName: info.full_name, element: info.element };
  }

  // ============== 锁泊/吞啖/飞伏判断 ==============

  private judgeSuoBo(star: string, branch: string, cfg: YanqinStarRulesConfig): SuoBoResult {
    if (!this.suoBoConfig) {
      return { star, branch, environment: '', geName: '无配置', geText: '', geResult: '平' };
    }
    const branchEnv = this.suoBoConfig.branch_environments[branch] as BranchEnvironment;
    const environment = branchEnv?.inner || '未知';
    const geKey = `${star}_${branch}`;
    const ge = this.suoBoConfig.suo_bo_ge[geKey] as SuoBoGe;
    if (ge) {
      return { star, branch, environment, geName: ge.name, geText: ge.text, geResult: ge.result };
    }
    const starInfo = cfg.constellations_full[star];
    return {
      star, branch, environment,
      geName: `${starInfo?.animal || star}泊${environment}`,
      geText: `${starInfo?.full_name}落${branch}宫`,
      geResult: '平'
    };
  }

  private getQinType(star: string, cfg: YanqinStarRulesConfig): string {
    if (cfg.qin_classification.天禽.includes(star)) return '天禽';
    if (cfg.qin_classification.水禽.includes(star)) return '水禽';
    return '地禽';
  }

  private judgeTunDan(star1: string, star2: string, cfg: YanqinStarRulesConfig): string {
    const info1 = cfg.constellations_full[star1];
    const info2 = cfg.constellations_full[star2];
    const animal1 = info1?.animal || '';
    const animal2 = info2?.animal || '';
    const foodList = cfg.tun_dan.food_map[star1] || [];
    if (foodList.length > 0) {
      if (foodList.includes('百兽')) return `${animal1}食百兽，克${animal2}`;
      if (foodList.includes(animal2)) return `${animal1}食${animal2}，有克`;
    }
    return `${animal1}不食${animal2}`;
  }

  private judgeFeifu(star: string, hourIndex: number, cfg: YanqinStarRulesConfig): FeifuResultSimple {
    const isDayQin = cfg.ri_ye_qin.日禽.includes(star);
    const isNightQin = cfg.ri_ye_qin.夜禽.includes(star);
    const isDayNightCommon = cfg.ri_ye_qin.日夜通用.includes(star);
    const isDaytime = hourIndex >= 2 && hourIndex <= 9;
    const result: FeifuResultSimple = { status: '', desc: '' };
    if (isDayNightCommon) {
      result.status = '通';
      result.desc = '日夜通用';
    } else if (isDaytime) {
      if (isDayQin) {
        result.status = '飞';
        result.desc = '昼临日禽，显形在动';
      } else {
        result.status = '伏';
        result.desc = '昼临夜禽，隐形休息';
      }
    } else {
      if (isNightQin) {
        result.status = '飞';
        result.desc = '夜临夜禽，活跃';
      } else {
        result.status = '伏';
        result.desc = '夜临日禽，休息';
      }
    }
    return result;
  }

  private getDateString(): string {
    return `${this.selectedYear}年${this.selectedMonth}月${this.selectedDay}日`;
  }

  private getBranchName(index: number): string {
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return branches[index];
  }

  private getResultColor(result: string): string {
    if (result.includes('大吉')) return '#2e7d32';
    if (result.includes('吉')) return '#4caf50';
    if (result.includes('大凶')) return '#c62828';
    if (result.includes('凶')) return '#ef5350';
    return '#666666';
  }

  // ============== UI构建 ==============
  
  build() {
    Scroll() {
      Column() {
        // 顶部导航
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#333333')
            .onClick(() => router.back())
          Text('演禽盘式')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a1a1a')
            .margin({ left: 12 })
          Blank()
          Text(`${this.yuanName}·第${this.jiangIndex}将`)
            .fontSize(12)
            .fontColor('#888888')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })
  
        // 日期时辰显示
        Row() {
          Text(this.getDateString())
            .fontSize(14)
            .fontColor('#333333')
          Text(`${this.getBranchName(this.selectedHourIndex)}时`)
            .fontSize(14)
            .fontColor('#1a5276')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 16 })
  
        if (this.hasLoaded && this.wuQinResult) {
          // ========== 四课展示（禁星赋：日禽、时禽、翻禽、活曜） ==========
          Column() {
            Row() {
              Text('【四课】')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#555555')
              Blank()
              Text(`年禽:${this.wuQinResult.yearStar.star} 月禽:${this.wuQinResult.monthStar.star}`)
                .fontSize(10)
                .fontColor('#888888')
            }
            .width('100%')
            .margin({ bottom: 10 })
        
            // 四课网格
            Grid() {
              GridItem() {
                Column() {
                  Text('一课')
                    .fontSize(10)
                    .fontColor('#888888')
                  Text(this.wuQinResult.dayStar.star)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#8b4513')
                    .margin({ top: 2 })
                  Text('日禽')
                    .fontSize(9)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#fdf5e6')
                .borderRadius(8)
              }
        
              GridItem() {
                Column() {
                  Text('二课')
                    .fontSize(10)
                    .fontColor('#888888')
                  Text(this.wuQinResult.diQin.star)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#2d5a3d')
                    .margin({ top: 2 })
                  Text('时禽/我')
                    .fontSize(9)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#e8f5e9')
                .borderRadius(8)
              }
        
              GridItem() {
                Column() {
                  Text('三课')
                    .fontSize(10)
                    .fontColor('#888888')
                  Text(this.wuQinResult.tianQin.star)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1a5276')
                    .margin({ top: 2 })
                  Text('翻禽/他')
                    .fontSize(9)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#e3f2fd')
                .borderRadius(8)
              }
        
              GridItem() {
                Column() {
                  Text('四课')
                    .fontSize(10)
                    .fontColor('#888888')
                  Text(this.wuQinResult.huoYao.star)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#6a1b9a')
                    .margin({ top: 2 })
                  Text('活曜/变')
                    .fontSize(9)
                    .fontColor('#666666')
                    .margin({ top: 2 })
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#f3e5f5')
                .borderRadius(8)
              }
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsTemplate('1fr')
            .columnsGap(8)
            .width('100%')
            .height(75)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })
        
          // ========== 三传展示（禁星赋：日禽→时禽→翻禽） ==========
          Column() {
            Text('【三传】')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#555555')
              .width('100%')
              .margin({ bottom: 10 })
        
            Row() {
              // 初传：日禽（背景/大环境）
              Column() {
                Text('初传')
                  .fontSize(11)
                  .fontColor('#666666')
                Column() {
                  Text(this.wuQinResult.dayStar.star)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                  Text(this.wuQinResult.dayStar.fullName)
                    .fontSize(10)
                    .fontColor('#ffffffcc')
                    .margin({ top: 2 })
                }
                .width(60)
                .height(60)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#8b4513')
                .borderRadius(30)
                .margin({ top: 6 })
                Text('日禽')
                  .fontSize(10)
                  .fontColor('#8b4513')
                  .margin({ top: 4 })
                Text('彼我共用')
                  .fontSize(9)
                  .fontColor('#888888')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
        
              // 箭头
              Text('→')
                .fontSize(20)
                .fontColor('#cccccc')
                .margin({ top: 20 })
        
              // 中传：时禽/地禽（当前状态，代表我）
              Column() {
                Text('中传')
                  .fontSize(11)
                  .fontColor('#666666')
                Column() {
                  Text(this.wuQinResult.diQin.star)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                  Text(this.wuQinResult.diQin.fullName)
                    .fontSize(10)
                    .fontColor('#ffffffcc')
                    .margin({ top: 2 })
                }
                .width(60)
                .height(60)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#2d5a3d')
                .borderRadius(30)
                .margin({ top: 6 })
                Text('时禽/我')
                  .fontSize(10)
                  .fontColor('#2d5a3d')
                  .margin({ top: 4 })
                Text(this.diQinType)
                  .fontSize(9)
                  .fontColor('#888888')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
        
              // 箭头
              Text('→')
                .fontSize(20)
                .fontColor('#cccccc')
                .margin({ top: 20 })
        
              // 末传：翻禽/天禽（结果，代表他）
              Column() {
                Text('末传')
                  .fontSize(11)
                  .fontColor('#666666')
                Column() {
                  Text(this.wuQinResult.tianQin.star)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ffffff')
                  Text(this.wuQinResult.tianQin.fullName)
                    .fontSize(10)
                    .fontColor('#ffffffcc')
                    .margin({ top: 2 })
                }
                .width(60)
                .height(60)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#1a5276')
                .borderRadius(30)
                .margin({ top: 6 })
                Text('翻禽/他')
                  .fontSize(10)
                  .fontColor('#1a5276')
                  .margin({ top: 4 })
                Text(this.tianQinType)
                  .fontSize(9)
                  .fontColor('#888888')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })
  
          // ========== 锁泊十二宫图 ==========
          Column() {
            Text('【锁泊十二宫】')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#555555')
              .width('100%')
              .margin({ bottom: 10 })
  
            // 十二宫图形布局 (4x4) - 上南下北，左东右西
            Grid() {
              // 第一行（南）：巳、午、未、申
              GridItem() { this.SuoBoPalace('巳', '汤', 5) }
              GridItem() { this.SuoBoPalace('午', '火', 6) }
              GridItem() { this.SuoBoPalace('未', '野', 7) }
              GridItem() { this.SuoBoPalace('申', '刀', 8) }
              // 第二行：辰、中宫、中宫、酉
              GridItem() { this.SuoBoPalace('辰', '岗', 4) }
              GridItem() { this.CenterPalace() }
              GridItem() { this.CenterPalace2() }
              GridItem() { this.SuoBoPalace('酉', '砧', 9) }
              // 第三行：卯、中宫、中宫、戌
              GridItem() { this.SuoBoPalace('卯', '林', 3) }
              GridItem() { this.CenterPalace3() }
              GridItem() { this.CenterPalace4() }
              GridItem() { this.SuoBoPalace('戌', '路', 10) }
              // 第四行（北）：寅、丑、子、亥
              GridItem() { this.SuoBoPalace('寅', '山', 2) }
              GridItem() { this.SuoBoPalace('丑', '田', 1) }
              GridItem() { this.SuoBoPalace('子', '湖', 0) }
              GridItem() { this.SuoBoPalace('亥', '江', 11) }
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(4)
            .rowsGap(4)
            .width('100%')
            .height(260)
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })
  
          // ========== 吞啤生克 ==========
          Column() {
            Text('【吞啤生克】')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#555555')
              .width('100%')
              .margin({ bottom: 10 })
  
            Text(`· 地禽 vs 天禽：${this.tunDanDesc1}`)
              .fontSize(13)
              .fontColor('#444444')
              .width('100%')
              .margin({ bottom: 6 })
  
            Text(`· 天禽 vs 地禽：${this.tunDanDesc2}`)
              .fontSize(13)
              .fontColor('#444444')
              .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })
  
          // ========== 飞伏动静 ==========
          Column() {
            Text('【飞伏动静】')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#555555')
              .width('100%')
              .margin({ bottom: 10 })
  
            Row() {
              Text(`时禽 ${this.wuQinResult.diQin.star}`)
                .fontSize(13)
                .fontColor('#333333')
              Text(this.feifuStatus)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.feifuStatus === '飞' ? '#2e7d32' : '#ef6c00')
                .margin({ left: 8 })
              Text(`（${this.feifuDesc}）`)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ left: 8 })
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })
  
          // ========== 禽机赋断语 ==========
          Column() {
            Text('【禽机赋断语】')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#555555')
              .width('100%')
              .margin({ bottom: 10 })

            // 禽星属性
            Text(`◎ 禽星属性`)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 6 })

            Text(`· 地禽 ${this.wuQinResult.diQin.star}：${this.getQinAttribute(this.wuQinResult.diQin.star)}`)
              .fontSize(12)
              .fontColor('#444444')
              .width('100%')
              .margin({ bottom: 4 })

            Text(`· 天禽 ${this.wuQinResult.tianQin.star}：${this.getQinAttribute(this.wuQinResult.tianQin.star)}`)
              .fontSize(12)
              .fontColor('#444444')
              .width('100%')
              .margin({ bottom: 4 })

            Text(`· 活曜 ${this.wuQinResult.huoYao.star}：${this.getQinAttribute(this.wuQinResult.huoYao.star)}`)
              .fontSize(12)
              .fontColor('#444444')
              .width('100%')
              .margin({ bottom: 10 })

            // 得地/失陷判断
            Text(`◎ 得地失陷`)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 6 })

            Text(`${this.getDeDeJudgment()}`)
              .fontSize(12)
              .fontColor('#444444')
              .width('100%')
              .margin({ bottom: 10 })

            // 特殊格局
            if (this.getSpecialPattern()) {
              Text(`◎ 特殊格局`)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')
                .margin({ bottom: 6 })

              Text(`${this.getSpecialPattern()}`)
                .fontSize(12)
                .fontColor('#c62828')
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 10 })
            }

            // 昼夜规则
            Text(`◎ 昼夜动静`)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .margin({ bottom: 6 })

            Text(`${this.getDayNightRule()}`)
              .fontSize(12)
              .fontColor('#444444')
              .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#fffbf0')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })

          // 免责声明
          Text('∗ 以上内容仅供传统文化研习参考，不构成任何现实指导。')
            .fontSize(11)
            .fontColor('#aaaaaa')
            .margin({ top: 8, bottom: 32 })
            .textAlign(TextAlign.Center)
            .width('100%')
        } else {
          // 加载中
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#888888')
            Text('正在加载...')
              .fontSize(14)
              .fontColor('#888888')
              .margin({ top: 12 })
          }
          .width('100%')
          .height(300)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  // 空宫位
  @Builder
  EmptyPalace() {
    Column() {}
    .width('100%')
    .height('100%')
    .backgroundColor('#fafafa')
    .borderRadius(6)
  }

  // 锁泊宫位组件 - 天地盘双层展示
  @Builder
  SuoBoPalace(branch: string, env: string, branchIndex: number) {
    Column() {
      // 地支+环境名
      Text(`${branch}${env}`)
        .fontSize(10)
        .fontColor('#555555')
        .margin({ bottom: 2 })
      
      // 天盘（翻禽）
      if (this.getStarInBranchByType(branchIndex, 'tian')) {
        Row() {
          Text('天')
            .fontSize(8)
            .fontColor('#ffffff')
            .backgroundColor('#1a5276')
            .borderRadius(2)
            .padding({ left: 2, right: 2 })
          Text(this.getStarInBranchByType(branchIndex, 'tian'))
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a5276')
            .margin({ left: 2 })
        }
        .justifyContent(FlexAlign.Center)
      }
      
      // 地盘（时禽）
      if (this.getStarInBranchByType(branchIndex, 'di')) {
        Row() {
          Text('地')
            .fontSize(8)
            .fontColor('#ffffff')
            .backgroundColor('#2d5a3d')
            .borderRadius(2)
            .padding({ left: 2, right: 2 })
          Text(this.getStarInBranchByType(branchIndex, 'di'))
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2d5a3d')
            .margin({ left: 2 })
        }
        .justifyContent(FlexAlign.Center)
      }
      
      // 人盘（活曜）
      if (this.getStarInBranchByType(branchIndex, 'huo')) {
        Row() {
          Text('人')
            .fontSize(8)
            .fontColor('#ffffff')
            .backgroundColor('#6a1b9a')
            .borderRadius(2)
            .padding({ left: 2, right: 2 })
          Text(this.getStarInBranchByType(branchIndex, 'huo'))
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor('#6a1b9a')
            .margin({ left: 2 })
        }
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getBranchBgColor(branchIndex))
    .borderRadius(6)
    .border({ width: 1, color: '#e0e0e0' })
  }
  
  // 中宫左：地禽信息
  @Builder
  CenterPalace() {
    Column() {
      Text('地禽')
        .fontSize(10)
        .fontColor('#2d5a3d')
      Text(this.wuQinResult?.diQin.star || '')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2d5a3d')
      Text(this.diQinSuoBo?.geName || '')
        .fontSize(9)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#e8f5e9')
    .borderRadius(6)
  }
  
  // 中宫右：天禽信息
  @Builder
  CenterPalace2() {
    Column() {
      Text('天禽')
        .fontSize(10)
        .fontColor('#1a5276')
      Text(this.wuQinResult?.tianQin.star || '')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1a5276')
      Text(this.tianQinSuoBo?.geName || '')
        .fontSize(9)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#e3f2fd')
    .borderRadius(6)
  }

  // 中宫左下：活曜信息
  @Builder
  CenterPalace3() {
    Column() {
      Text('活曜')
        .fontSize(10)
        .fontColor('#6a1b9a')
      Text(this.wuQinResult?.huoYao.star || '')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#6a1b9a')
      Text(this.huoYaoSuoBo?.geName || '')
        .fontSize(9)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#f3e5f5')
    .borderRadius(6)
  }

  // 中宫右下：日禽信息
  @Builder
  CenterPalace4() {
    Column() {
      Text('日禽')
        .fontSize(10)
        .fontColor('#8b4513')
      Text(this.wuQinResult?.dayStar.star || '')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8b4513')
      Text(`${this.yuanName}`)
        .fontSize(9)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fdf5e6')
    .borderRadius(6)
  }
  
  // 获取某宫位中指定类型的禽星
  private getStarInBranchByType(branchIndex: number, type: string): string {
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    const branch = branches[branchIndex];
    
    if (type === 'tian' && this.tianQinSuoBo && this.tianQinSuoBo.branch === branch) {
      return this.tianQinSuoBo.star;
    }
    if (type === 'di' && this.diQinSuoBo && this.diQinSuoBo.branch === branch) {
      return this.diQinSuoBo.star;
    }
    if (type === 'huo' && this.huoYaoSuoBo && this.huoYaoSuoBo.branch === branch) {
      return this.huoYaoSuoBo.star;
    }
    return '';
  }

  // 获取某宫位中的禽星（兼容旧版）
  private getStarInBranch(branchIndex: number): string {
    if (!this.diQinSuoBo && !this.tianQinSuoBo && !this.huoYaoSuoBo) return '';
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    const branch = branches[branchIndex];
    const stars: Array<string> = [];
    if (this.diQinSuoBo && this.diQinSuoBo.branch === branch) {
      stars.push(this.diQinSuoBo.star);
    }
    if (this.tianQinSuoBo && this.tianQinSuoBo.branch === branch) {
      stars.push(this.tianQinSuoBo.star);
    }
    if (this.huoYaoSuoBo && this.huoYaoSuoBo.branch === branch) {
      stars.push(this.huoYaoSuoBo.star);
    }
    return stars.join(',');
  }
  
  // 获取禽星颜色（兼容旧版）
  private getStarColor(branchIndex: number): string {
    return '#333333';
  }
  
  // 获取宫位背景色
  private getBranchBgColor(branchIndex: number): string {
    if (!this.diQinSuoBo && !this.tianQinSuoBo && !this.huoYaoSuoBo) return '#fafafa';
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    const branch = branches[branchIndex];
    if (this.diQinSuoBo && this.diQinSuoBo.branch === branch) return '#e8f5e9';
    if (this.tianQinSuoBo && this.tianQinSuoBo.branch === branch) return '#e3f2fd';
    if (this.huoYaoSuoBo && this.huoYaoSuoBo.branch === branch) return '#f3e5f5';
    return '#fafafa';
  }
  
  @Builder
  SuoBoItem(label: string, result: SuoBoResult) {
    Row() {
      Text(`· ${label}`)
        .fontSize(13)
        .fontColor('#333333')
        .width(50)
      Text(`${result.star}`)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      Text(`泊「${result.branch}」${result.environment}宫`)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ left: 4 })
      Text('→')
        .fontSize(12)
        .fontColor('#888888')
        .margin({ left: 4 })
      Text(result.geName)
        .fontSize(12)
        .fontColor(this.getResultColor(result.geResult))
        .fontWeight(FontWeight.Medium)
        .margin({ left: 4 })
      Text(`(${result.geResult})`)
        .fontSize(11)
        .fontColor(this.getResultColor(result.geResult))
        .margin({ left: 4 })
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  // ============== 禽机赋断语方法 ==============

  // 获取禽星属性（日禽/夜禽/水禽/山禽等）
  private getQinAttribute(star: string): string {
    // 日禽：鸡、雉、燕、乌、蛇
    const dayBirds = ['昂', '胃', '危', '毕', '翼'];
    // 夜禽：鼠、蝠、貉、狐
    const nightBirds = ['虚', '女', '氐', '心'];
    // 水禽：蛟、龙、貔、蛓
    const waterBirds = ['角', '亢', '壁', '轸'];
    // 山禽：虎、豹、狼、猴、猿、獐、鹿
    const mountainBirds = ['尾', '箵', '奈', '觜', '参', '柳', '张'];
    // 家禽：牛、猪、羊、马、狗、鸡
    const farmBirds = ['牛', '室', '鬼', '星', '娄', '昂'];

    const attrs: Array<string> = [];
    if (dayBirds.includes(star)) attrs.push('日禽（昼飞夜宿）');
    if (nightBirds.includes(star)) attrs.push('夜禽（昼潜夜动）');
    if (waterBirds.includes(star)) attrs.push('水禽（宜江湖）');
    if (mountainBirds.includes(star)) attrs.push('山禽（宜山林）');
    if (farmBirds.includes(star)) attrs.push('家禽（宜平地）');

    return attrs.length > 0 ? attrs.join('、') : '普通禽星';
  }

  // 得地/失陷判断
  private getDeDeJudgment(): string {
    const results: Array<string> = [];

    // 地禽判断
    if (this.diQinSuoBo) {
      const diResult = this.judgeDeDeByRule(this.wuQinResult!.diQin.star, this.diQinSuoBo.branch);
      if (diResult) results.push(`地禽${diResult}`);
    }

    // 天禽判断
    if (this.tianQinSuoBo) {
      const tianResult = this.judgeDeDeByRule(this.wuQinResult!.tianQin.star, this.tianQinSuoBo.branch);
      if (tianResult) results.push(`天禽${tianResult}`);
    }

    // 活曜判断
    if (this.huoYaoSuoBo) {
      const huoResult = this.judgeDeDeByRule(this.wuQinResult!.huoYao.star, this.huoYaoSuoBo.branch);
      if (huoResult) results.push(`活曜${huoResult}`);
    }

    return results.length > 0 ? results.join('；') : '未发现明显得地或失陷';
  }

  // 根据禄机赋规则判断得地失陷
  private judgeDeDeByRule(star: string, branch: string): string {
    // 水禽得水
    const waterBirds = ['角', '亢', '壁', '轸'];
    const waterBranches = ['亥', '子'];
    if (waterBirds.includes(star) && waterBranches.includes(branch)) {
      return `${star}泊${branch}：得地（蛟龙得水，如鱼得水）`;
    }

    // 山禽得山
    const mountainBirds = ['尾', '箵', '奈', '觜', '参', '柳', '张'];
    const mountainBranches = ['寅', '卯'];
    if (mountainBirds.includes(star) && mountainBranches.includes(branch)) {
      return `${star}泊${branch}：得地（虎豹入山林，威风凛凛）`;
    }

    // 虎狼不下水
    const tigerWolf = ['尾', '箵', '奈'];
    if (tigerWolf.includes(star) && waterBranches.includes(branch)) {
      return `${star}泊${branch}：失陷（虎狼不下水）`;
    }

    // 蛟龙不上山
    const dragons = ['角', '亢'];
    if (dragons.includes(star) && mountainBranches.includes(branch)) {
      return `${star}泊${branch}：失陷（蛟龙不上山）`;
    }

    // 猪羊忌江湖
    const pigSheep = ['室', '鬼'];
    if (pigSheep.includes(star) && waterBranches.includes(branch)) {
      return `${star}泊${branch}：失陷（猪羊须忌江湖）`;
    }

    // 家禽得田
    const farmBirds = ['牛', '室', '鬼', '星', '娄', '昂'];
    const farmBranches = ['丑', '未'];
    if (farmBirds.includes(star) && farmBranches.includes(branch)) {
      return `${star}泊${branch}：得地（家禽宜居平地）`;
    }

    // 禽入刀砧
    const knifeBranches = ['午', '未', '申', '酉'];
    if (knifeBranches.includes(branch)) {
      return `${star}泊${branch}：注意（禽入刀砧，恐有损伤）`;
    }

    return '';
  }

  // 获取特殊格局
  private getSpecialPattern(): string {
    const patterns: Array<string> = [];

    // 检查井木犴特殊能力
    const allStars = [
      this.wuQinResult?.diQin.star,
      this.wuQinResult?.tianQin.star,
      this.wuQinResult?.huoYao.star
    ];

    if (allStars.includes('井')) {
      const jingBranch = this.getStarBranch('井');
      if (jingBranch === '未' || jingBranch === '寅') {
        patterns.push('井木犴司权：上山食虎豹，下水食蛟龙，破万兵之力！');
      }
    }

    // 检查心月狐克鸡
    if (allStars.includes('心') && allStars.includes('昂')) {
      patterns.push('心月狐克鸡：鸡怕心月狐食！');
    }

    // 检查寅宫虎威
    if (allStars.includes('尾')) {
      const weiBranch = this.getStarBranch('尾');
      if (weiBranch === '寅') {
        patterns.push('虎居寅宫：走兽避之，司权之地！');
      }
    }

    // 检查未上鹰威
    if (allStars.includes('张')) {
      const zhangBranch = this.getStarBranch('张');
      if (zhangBranch === '未') {
        patterns.push('未上藏鹰：飞禽不过，司权之地！');
      }
    }

    // 检查燕入辰反食蛟龙
    if (allStars.includes('危')) {
      const weiBranch = this.getStarBranch('危');
      if (weiBranch === '辰' && (allStars.includes('角') || allStars.includes('亢'))) {
        patterns.push('燕入辰反食蛟龙：弱胜强之象！');
      }
    }

    return patterns.join('；');
  }

  // 获取某禽星的落宫
  private getStarBranch(star: string): string {
    if (this.wuQinResult?.diQin.star === star && this.diQinSuoBo) {
      return this.diQinSuoBo.branch;
    }
    if (this.wuQinResult?.tianQin.star === star && this.tianQinSuoBo) {
      return this.tianQinSuoBo.branch;
    }
    if (this.wuQinResult?.huoYao.star === star && this.huoYaoSuoBo) {
      return this.huoYaoSuoBo.branch;
    }
    return '';
  }

  // 获取昼夜规则判断
  private getDayNightRule(): string {
    const results: Array<string> = [];
    const currentHour = new Date().getHours();
    const isDaytime = currentHour >= 6 && currentHour < 18;
    const timeDesc = isDaytime ? '当前为昼间' : '当前为夜间';

    // 日禽：昼飞夜宿
    const dayBirds = ['昂', '胃', '危', '毕', '翼'];
    // 夜禽：昼潜夜动
    const nightBirds = ['虚', '女', '氐', '心'];

    const checkStar = (label: string, star: string) => {
      if (dayBirds.includes(star)) {
        if (isDaytime) {
          results.push(`${label}${star}为日禽，${timeDesc}，当飞动活跃`);
        } else {
          results.push(`${label}${star}为日禽，${timeDesc}，当潜藏不动`);
        }
      }
      if (nightBirds.includes(star)) {
        if (!isDaytime) {
          results.push(`${label}${star}为夜禽，${timeDesc}，当活动出没`);
        } else {
          results.push(`${label}${star}为夜禽，${timeDesc}，当隐伏不动`);
        }
      }
    };

    if (this.wuQinResult) {
      checkStar('地禽', this.wuQinResult.diQin.star);
      checkStar('天禽', this.wuQinResult.tianQin.star);
      checkStar('活曜', this.wuQinResult.huoYao.star);
    }

    return results.length > 0 ? results.join('；') : `${timeDesc}，禽星无明显昼夜属性`;
  }
}
