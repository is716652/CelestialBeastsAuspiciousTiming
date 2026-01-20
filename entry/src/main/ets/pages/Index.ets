import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { calcTimeTrendFromCalendar, TimeRiskTag } from '../utils/Knowledge15x';

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
  huo_yao_rules: HuoYaoRules;
  qin_classification: QinClassification;
  tun_dan: TunDanConfig;
  ri_ye_qin: RiYeQinConfig;
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

// ============== 演禽盘式相关接口 ==============

interface HuoYaoRules {
  description: string;
  element_to_flip_star: Record<string, string>;
  start_branch: string;
}

interface QinClassification {
  description: string;
  天禽: Array<string>;
  地禽: Array<string>;
  水禽: Array<string>;
  家禽: Array<string>;
  rules: Record<string, string>;
}

interface WuShiConfig {
  list: Array<string>;
}

interface TunDanConfig {
  description: string;
  food_map: Record<string, Array<string>>;
  wu_shi: WuShiConfig;
  animal_to_star: Record<string, string>;
}

interface RiYeQinConfig {
  description: string;
  日禽: Array<string>;
  夜禽: Array<string>;
  日夜通用: Array<string>;
  rules: Record<string, string>;
}

// ============== 锁泊规则配置接口 ==============

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

interface DefaultJudgmentRule {
  branches: Array<string>;
  result: string;
  text: string;
}

interface DefaultJudgment {
  rules: Record<string, DefaultJudgmentRule>;
}

interface SuoBoRulesConfig {
  branch_environments: Record<string, BranchEnvironment>;
  suo_bo_ge: Record<string, SuoBoGe>;
  default_judgment: DefaultJudgment;
}

interface RuleItem {
  text: string;
  category?: string;
}

interface RulesConfig {
  rules: Record<string, RuleItem>;
  branch_meanings: Record<string, BranchMeaning>;
}

interface BranchMeaning {
  direction: string;
  element: string;
  environment: string;
  time_hint: string;
  informant: string;
  general: string;
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
  jiangStar: string;  // 四将符头
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
  jiangStar: string;  // 四将符头
}

// 翻禽/活曜计算结果
interface FanQinResult {
  fanQin: string;         // 翻禽（天禽/他禽）
  fanQinFull: string;
  fanQinElement: string;
}

interface HuoYaoResult {
  huoYao: string;         // 活曜（倒将/变禽）
  huoYaoFull: string;
  huoYaoElement: string;
}

// 锁泊格局结果
interface SuoBoResult {
  star: string;           // 星宿
  branch: string;         // 落宫地支
  environment: string;    // 环境（山、林、火等）
  geName: string;         // 格局名（如"极乐宫"）
  geText: string;         // 格局断语
  geResult: string;       // 吉凶结果
}

// 吞啤关系结果
interface TunDanResult {
  star1: string;
  star1Animal: string;
  star2: string;
  star2Animal: string;
  canEat: boolean;        // star1能否吃star2
  description: string;    // 关系描述
}

// 飞伏状态结果
interface FeifuResult {
  star: string;
  isDayQin: boolean;      // 是否日禽
  isNightQin: boolean;    // 是否夜禽
  isDaytime: boolean;     // 当前是否白天
  status: string;         // 飞/伏
  description: string;    // 状态描述
}

// 三禽分类结果
interface QinTypeResult {
  star: string;
  qinType: string;        // 天禽/地禽/水禽
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
  @State suoBoConfig: SuoBoRulesConfig | null = null;  // 锁泊规则配置

  // 用户选择
  @State selectedYear: number = new Date().getFullYear();
  @State selectedMonth: number = new Date().getMonth() + 1;
  @State selectedDay: number = new Date().getDate();
  @State selectedHourIndex: number = this.getCurrentHourIndex();
  @State useGodMode: number = 0;  // 0=传统分类, 1=自定义用神
  @State selectedCategoryIndex: number = 0;  // 传统分类索引
  @State selectedTabIndex: number = 0;  // 四象Tab索引
  @State selectedUseGodStar: string = '参';  // 自定义用神星宿

  // 四禽计算结果
  @State fourStars: FourStarsResult | null = null;
  @State dayInfo: CalendarDayInfo | null = null;
  @State timeTrendTags: TimeRiskTag[] = [];

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
    const lostItems = await this.loadJsonFromRaw<LostItemsConfig>('lost_items_config.json');
    const rules = await this.loadJsonFromRaw<RulesConfig>('lost_items_rules.json');
    const suoBo = await this.loadJsonFromRaw<SuoBoRulesConfig>('suo_bo_rules.json');

    if (starRules && lostItems && rules) {
      this.starRulesConfig = starRules;
      this.lostItemsConfig = lostItems;
      this.rulesConfig = rules;
      this.suoBoConfig = suoBo;
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

  private async calculateFourStars(): Promise<void> {
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
      hourElement: hourResult.element,
      yuanName: dayResult.yuanName,
      jiangIndex: dayResult.jiangIndex,
      jiangStar: dayResult.jiangStar
    };
    this.fourStars = result;

    // 异步获取万年历信息与时间趋势标签（研习向提示）
    const info = await CalendarManager.getInstance().getDayInfo(this.selectedYear, this.selectedMonth, this.selectedDay);
    this.dayInfo = info;
    if (info) {
      const trend = await calcTimeTrendFromCalendar(info, this.context);
      this.timeTrendTags = trend.tags;
    } else {
      this.timeTrendTags = [];
    }
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

  // ============== 翻禽计算（天禽/他禽） ==============
  // 口诀：值时支上起将星，顺行逐位向时禽。寻得时禽权且止，逆回时位向他禽。
  // 算法：将星加时位 → 顺寻时禽落点 → 逆数回时位
  private calculateFanQin(jiangStar: string, hourStar: string, hourIndex: number, cfg: YanqinStarRulesConfig): FanQinResult {
    const constellations = cfg.constellations_order;
    const jiangStarIndex = constellations.indexOf(jiangStar);
    const hourStarIndex = constellations.indexOf(hourStar);

    // 1. 计算从将星到时禽的顺数步数
    const forwardSteps = ((hourStarIndex - jiangStarIndex) + 28) % 28;

    // 2. 翻禽公式：时禽位置 + 顺数步数
    // 原理：逆数回时位时，地支逆转但星宿顺转
    const fanQinIndex = (hourStarIndex + forwardSteps) % 28;
    const fanQin = constellations[fanQinIndex];
    const info = cfg.constellations_full[fanQin];

    return {
      fanQin: fanQin,
      fanQinFull: info.full_name,
      fanQinElement: info.element
    };
  }

  // ============== 活曜计算（倒将/变禽） ==============
  // 口诀：日毕月尾火翻奎，水氐木虚金骑牛，土宿还从箕位起，每从寅位逆回转。
  // 算法：寅位起翻转星宿 → 逆寻时禽落点 → 顺数回用时
  private calculateHuoYao(hourStar: string, hourElement: string, hourIndex: number, cfg: YanqinStarRulesConfig): HuoYaoResult {
    const constellations = cfg.constellations_order;
    const branches = cfg.branches_order;

    // 1. 根据时禽的七政属性确定翻转起点星宿
    const flipStar = cfg.huo_yao_rules.element_to_flip_star[hourElement];
    const flipStarIndex = constellations.indexOf(flipStar);
    const hourStarIndex = constellations.indexOf(hourStar);

    // 2. 寅位索引（固定为2）
    const yinIndex = branches.indexOf('寅'); // = 2

    // 3. 从翻转星宿逆数找时禽落点
    // 逆数步数 = 时禽位置 - 翻转星宿位置（星宿顺行，地支逆行）
    const backwardSteps = ((hourStarIndex - flipStarIndex) + 28) % 28;

    // 4. 时禽落在的地支（从寅逆数）
    const hourStarBranch = ((yinIndex - backwardSteps % 12) + 12) % 12;

    // 5. 从时禽落点顺数回用时
    const forwardSteps = ((hourIndex - hourStarBranch) + 12) % 12;

    // 6. 活曜 = 时禽 + 顺数步数
    const huoYaoIndex = (hourStarIndex + forwardSteps) % 28;
    const huoYao = constellations[huoYaoIndex];
    const info = cfg.constellations_full[huoYao];

    return {
      huoYao: huoYao,
      huoYaoFull: info.full_name,
      huoYaoElement: info.element
    };
  }

  // ============== 锁泊格局判断 ==============
  // 根据星宿落在的地支，判断格局吉凶
  private judgeSuoBo(star: string, branch: string, cfg: YanqinStarRulesConfig): SuoBoResult {
    if (!this.suoBoConfig) {
      return {
        star: star,
        branch: branch,
        environment: '',
        geName: '无配置',
        geText: '锁泊规则未加载',
        geResult: '平'
      };
    }

    const suoBoCfg = this.suoBoConfig;
    
    // 获取地支环境
    const branchEnv = suoBoCfg.branch_environments[branch] as BranchEnvironment;
    const environment = branchEnv ? branchEnv.inner : '未知';

    // 查找特定格局
    const geKey = `${star}_${branch}`;
    const ge = suoBoCfg.suo_bo_ge[geKey] as SuoBoGe;

    if (ge) {
      return {
        star: star,
        branch: branch,
        environment: environment,
        geName: ge.name,
        geText: ge.text,
        geResult: ge.result
      };
    }

    // 无特定格局时，使用通用规则判断
    const starInfo = cfg.constellations_full[star];
    const starElement = starInfo?.element || '未知';
    const branchElement = branchEnv?.element || '未知';

    // 检查通用规则
    const defaultRules = suoBoCfg.default_judgment.rules;
    for (const ruleKey of Object.keys(defaultRules)) {
      const rule = defaultRules[ruleKey];
      if (rule.branches.includes(branch)) {
        // 检查五行匹配
        if (ruleKey.startsWith('水禽') && starElement === '水') {
          return { star, branch, environment, geName: ruleKey, geText: rule.text, geResult: rule.result };
        }
        if (ruleKey.startsWith('火禽') && starElement === '火') {
          return { star, branch, environment, geName: ruleKey, geText: rule.text, geResult: rule.result };
        }
        if (ruleKey.startsWith('木禽') && starElement === '木') {
          return { star, branch, environment, geName: ruleKey, geText: rule.text, geResult: rule.result };
        }
        if (ruleKey.startsWith('金禽') && starElement === '金') {
          return { star, branch, environment, geName: ruleKey, geText: rule.text, geResult: rule.result };
        }
        if (ruleKey.startsWith('土禽') && starElement === '土') {
          return { star, branch, environment, geName: ruleKey, geText: rule.text, geResult: rule.result };
        }
      }
    }

    // 默认结果
    return {
      star: star,
      branch: branch,
      environment: environment,
      geName: `${starInfo?.animal || star}泊${environment}`,
      geText: `${starInfo?.full_name || star}落${branch}宫（${environment}）`,
      geResult: '平'
    };
  }

  // ============== 三禽分类判断 ==============
  // 天禽/地禽/水禽分类
  private judgeQinType(star: string, cfg: YanqinStarRulesConfig): QinTypeResult {
    const classification = cfg.qin_classification;
    
    if (classification.天禽.includes(star)) {
      return { star, qinType: '天禽' };
    }
    if (classification.水禽.includes(star)) {
      return { star, qinType: '水禽' };
    }
    return { star, qinType: '地禽' };
  }

  // ============== 吞啖关系判断 ==============
  // 判断 star1 能否吃 star2
  private judgeTunDan(star1: string, star2: string, cfg: YanqinStarRulesConfig): TunDanResult {
    const tunDan = cfg.tun_dan;
    const info1 = cfg.constellations_full[star1];
    const info2 = cfg.constellations_full[star2];
    const animal1 = info1?.animal || '';
    const animal2 = info2?.animal || '';
  
    // 获取 star1 的食物列表
    const foodList = tunDan.food_map[star1] || [];
    let canEat = false;
    let description = '';
  
    if (foodList.length > 0) {
      // 检查是否包含 "百兽"(吃一切)
      if (foodList.includes('百兽')) {
        canEat = true;
        description = `${info1?.full_name || star1}食百兽，能克${info2?.full_name || star2}`;
      } else if (foodList.includes(animal2)) {
        canEat = true;
        description = `${animal1}食${animal2}，${info1?.full_name || star1}克${info2?.full_name || star2}`;
      }
    }
  
    if (!canEat) {
      // 检查是否无食
      const wuShiList = tunDan.wu_shi?.list || [];
      if (wuShiList.includes(animal1)) {
        description = `${animal1}为无食之禽，不能克他禽`;
      } else {
        description = `${animal1}不食${animal2}，无克`;
      }
    }
  
    return {
      star1,
      star1Animal: animal1,
      star2,
      star2Animal: animal2,
      canEat,
      description
    };
  }

  // ============== 飞伏状态判断 ==============
  // 根据日禽/夜禽和时辰判断飞伏
  private judgeFeifu(star: string, hourIndex: number, cfg: YanqinStarRulesConfig): FeifuResult {
    const riYeQin = cfg.ri_ye_qin;
    const isDayQin = riYeQin.日禽.includes(star);
    const isNightQin = riYeQin.夜禽.includes(star);
    const isDayNightCommon = riYeQin.日夜通用.includes(star);

    // 判断当前是否白天（寅时刻卯时，5:00-19:00）
    // 时辰索引: 子(0), 丑(1), 寅(2), 卯(3), 辰(4), 巳(5), 午(6), 未(7), 申(8), 酉(9), 戌(10), 亥(11)
    // 白天约为 寅(2) ~ 酉(9)
    const isDaytime = hourIndex >= 2 && hourIndex <= 9;

    let status = '';
    let description = '';

    if (isDayNightCommon) {
      status = '通';
      description = `${star}为日夜通用之禽，无论昼夜皆可活动`;
    } else if (isDaytime) {
      // 白天
      if (isDayQin) {
        status = '飞';
        description = `昼间临日禽${star}，飞（显形、在动）`;
      } else {
        status = '伏';
        description = `昼间临夜禽${star}，伏（隐形、休息）`;
      }
    } else {
      // 夜晚
      if (isNightQin) {
        status = '飞';
        description = `夜间临夜禽${star}，飞（活跃）`;
      } else {
        status = '伏';
        description = `夜间临日禽${star}，伏（休息）`;
      }
    }

    return {
      star,
      isDayQin,
      isNightQin,
      isDaytime,
      status,
      description
    };
  }

  // ============== 排盘演算 ==============

  private doCalculate(): void {
    if (!this.fourStars || !this.lostItemsConfig || !this.rulesConfig || !this.starRulesConfig) {
      return;
    }

    const constellations = this.starRulesConfig.constellations_order;
    const branches = this.lostItemsConfig.branches_order;

    // 根据模式确定用神星宿
    let useGodStar: string;
    let categoryName: string;
    if (this.useGodMode === 0) {
      // 传统分类模式
      const useGod = this.lostItemsConfig.use_gods[this.selectedCategoryIndex];
      useGodStar = useGod.star;
      categoryName = useGod.category;
    } else {
      // 自定义用神模式
      useGodStar = this.selectedUseGodStar;
      categoryName = '自定义读象';
    }

    const dayStarIndex = constellations.indexOf(this.fourStars.dayStar);
    const hourIndex = this.selectedHourIndex;
    const useStarIndex = constellations.indexOf(useGodStar);

    if (dayStarIndex < 0 || useStarIndex < 0) {
      this.resultSummary = '数据配置不完整，无法演算。';
      this.resultDetail = '';
      this.showResult = true;
      return;
    }

    const deltaStars = (useStarIndex - dayStarIndex + 28) % 28;
    const resultBranchIndex = (hourIndex + deltaStars) % 12;
    this.resultBranch = branches[resultBranchIndex];

    const key = this.buildRuleKey(useGodStar, this.resultBranch);
    this.resultKey = key;

    const rule = this.rulesConfig.rules[key];
    const starInfo = this.starRulesConfig.constellations_full[useGodStar];

    if (this.useGodMode === 0) {
      // 传统分类模式：显示分类名称
      this.resultSummary = `寻${categoryName} · 用神「${useGodStar}」宿 · 落「${this.resultBranch}」宫`;
    } else {
      // 自定义用神模式
      this.resultSummary = `用神「${starInfo?.full_name || useGodStar}」 · 落「${this.resultBranch}」宫`;
    }

    if (rule) {
      this.resultDetail = rule.text;
    } else {
      // 无具体断语时，使用宫位通用含义推导
      const branchMeaning = this.rulesConfig.branch_meanings[this.resultBranch];
      if (branchMeaning) {
        this.resultDetail = `【通用推导】此组合无古籍记载，以下为宫位基本含义推导：\n\n` +
          `◎ 方位：${branchMeaning.direction}\n` +
          `◎ 五行：${branchMeaning.element}\n` +
          `◎ 环境：${branchMeaning.environment}\n` +
          `◎ 报信人：${branchMeaning.informant}\n` +
          `◎ 时间：${branchMeaning.time_hint}\n\n` +
          `【综合分析】${branchMeaning.general}\n\n` +
          `用神「${starInfo?.full_name || useGodStar}」属${starInfo?.element || '未知'}，落${this.resultBranch}宫属${branchMeaning.element}，可结合五行生克参考判断。`;
      } else {
        this.resultDetail = `当前组合（${key}）在案例库中暂无详细记载。`;
      }
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

  private getUseGodDisplayText(): string {
    if (!this.lostItemsConfig || !this.starRulesConfig) return '';
    if (this.useGodMode === 0) {
      const useGod = this.lostItemsConfig.use_gods[this.selectedCategoryIndex];
      return `${useGod.star}宿（寻${useGod.category}）→ 落${this.resultBranch}宫`;
    } else {
      const starInfo = this.starRulesConfig.constellations_full[this.selectedUseGodStar];
      return `${this.selectedUseGodStar}宿（${starInfo?.full_name || ''}）→ 落${this.resultBranch}宫`;
    }
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
        .padding({ top: 40, bottom: 16 })
        .alignItems(HorizontalAlign.Center)

        // ========== 功能入口双卡片 ==========
        Row() {
          // 方位推演卡片
          Column() {
            Text('方位推演')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2d5a3d')
            Text('简易歌诀 · 速查')
              .fontSize(11)
              .fontColor('#666666')
              .margin({ top: 4 })
            Text('用神落宫·方位参考')
              .fontSize(10)
              .fontColor('#888888')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(90)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#f5f9f6')
          .borderRadius(14)
          .border({ width: 2, color: '#3d6b4f' })

          // 演禽盘式卡片
          Column() {
            Text('演禽盘式')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a5276')
            Text('完整排盘 · 精研')
              .fontSize(11)
              .fontColor('#666666')
              .margin({ top: 4 })
            Text('三传四课·锁泊十二宫')
              .fontSize(10)
              .fontColor('#888888')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .height(90)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#e8f4fc')
          .borderRadius(14)
          .border({ width: 1, color: '#d4e6f1' })
          .margin({ left: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/YanQinPanShi',
              params: {
                year: this.selectedYear,
                month: this.selectedMonth,
                day: this.selectedDay,
                hourIndex: this.selectedHourIndex
              }
            });
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })

        // ========== 高级研习入口（案例库示例） ==========
        Row() {
          Column() {
            Text('📚 高级研习 · 案例库 示例')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#312e81')
              .width('100%')
              .margin({ bottom: 4 })

            Text('收录官司等场景的演禽研习案例，使用模拟数据，仅供学习参考。')
              .fontSize(11)
              .fontColor('#4b5563')
              .width('100%')
          }
          .layoutWeight(1)

          Text('进入')
            .fontSize(12)
            .fontColor('#4c1d95')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(72)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#f5f3ff')
        .borderRadius(14)
        .margin({ left: 16, right: 16, bottom: 12 })
        .border({ width: 1, color: '#ddd6fe' })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/AdvancedStudyCases'
          });
        })

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

            // 显示万年历详细信息
            if (this.dayInfo) {
              Row() {
                Text(`农历：${this.dayInfo.lunar_month}月${this.dayInfo.lunar_day} · ${this.dayInfo.year_gan}${this.dayInfo.year_zhi}年 · ${this.dayInfo.zodiac} · ${this.dayInfo.week_name}`)
                  .fontSize(12)
                  .fontColor('#4caf50')
                  .fontWeight(FontWeight.Medium)
                if (this.dayInfo.solar_term) {
                  Text(` · ${this.dayInfo.solar_term}`)
                    .fontSize(12)
                    .fontColor('#ff9800')
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 4 })
                }
                if (this.dayInfo.festivals) {
                  Text(` · ${this.dayInfo.festivals}`)
                    .fontSize(12)
                    .fontColor('#e91e63')
                    .margin({ left: 4 })
                }
              }
              .width('100%')
              .margin({ top: 10 })
              .padding({ left: 4 })
            }

            // 时间趋势 · 研习提示
            if (this.dayInfo && this.timeTrendTags.length > 0) {
              Column() {
                Row() {
                  Text('时间趋势 · 研习提示')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#374151')
                  Blank()
                  Text('基于传统十五卷等规则，仅供学习参考')
                    .fontSize(10)
                    .fontColor('#9ca3af')
                }
                .width('100%')
                .margin({ bottom: 4 })

                ForEach(this.timeTrendTags, (tag: TimeRiskTag) => {
                  Column() {
                    Text(tag.label)
                      .fontSize(11)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(tag.level === 'high' ? '#b91c1c' : (tag.level === 'medium' ? '#b45309' : '#1f2933'))
                    Text(tag.safeSummary)
                      .fontSize(10)
                      .fontColor('#4b5563')
                      .lineHeight(14)
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .padding({ top: 6, bottom: 6, left: 8, right: 8 })
                  .margin({ top: 4 })
                  .backgroundColor(tag.level === 'high' ? '#fef2f2' : (tag.level === 'medium' ? '#fffbeb' : '#f3f4f6'))
                  .borderRadius(8)
                })
              }
              .width('100%')
              .margin({ top: 8 })
            }
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

          // ========== 用神选择区 ==========
          Column() {
            // 模式切换Tab
            Row() {
              Text('传统分类')
                .fontSize(14)
                .fontWeight(this.useGodMode === 0 ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(this.useGodMode === 0 ? '#ffffff' : '#666666')
                .backgroundColor(this.useGodMode === 0 ? '#3d6b4f' : '#f0f0f0')
                .borderRadius(20)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  this.useGodMode = 0;
                  this.showResult = false;
                })
              Text('自定义用神')
                .fontSize(14)
                .fontWeight(this.useGodMode === 1 ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(this.useGodMode === 1 ? '#ffffff' : '#666666')
                .backgroundColor(this.useGodMode === 1 ? '#3d6b4f' : '#f0f0f0')
                .borderRadius(20)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 12 })
                .onClick(() => {
                  this.useGodMode = 1;
                  this.showResult = false;
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 16 })

            if (this.useGodMode === 0) {
              // ========== 传统分类模式 ==========
              Column() {
                Text('选择要寻找的对象')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .width('100%')
                  .margin({ bottom: 12 })

                // 分类网格
                Grid() {
                  ForEach(this.lostItemsConfig!.use_gods, (item: LostItemUseGod, index: number) => {
                    GridItem() {
                      Column() {
                        Text(item.category)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.selectedCategoryIndex === index ? '#ffffff' : '#333333')
                        Text(item.note)
                          .fontSize(10)
                          .fontColor(this.selectedCategoryIndex === index ? '#ffffffcc' : '#888888')
                          .margin({ top: 4 })
                      }
                      .width('100%')
                      .height('100%')
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor(this.selectedCategoryIndex === index ? '#3d6b4f' : '#f8f8f6')
                      .borderRadius(10)
                      .onClick(() => {
                        this.selectedCategoryIndex = index;
                        this.showResult = false;
                      })
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
                .columnsGap(8)
                .rowsGap(8)
                .width('100%')
                .height(280)
              }
              .width('100%')
            } else {
              // ========== 自定义用神模式 ==========
              Column() {
                Row() {
                  Text('根据读象选择用神星宿')
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                  Blank()
                  Text(this.starRulesConfig!.constellations_full[this.selectedUseGodStar]?.full_name || '')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#3d6b4f')
                }
                .width('100%')
                .margin({ bottom: 10 })

                // 四象Tab
                Row() {
                  ForEach(this.starRulesConfig!.four_symbols.groups, (group: FourSymbolGroup, index: number) => {
                    Text(group.name)
                      .fontSize(12)
                      .fontColor(this.selectedTabIndex === index ? '#ffffff' : '#666666')
                      .backgroundColor(this.selectedTabIndex === index ? group.color : '#f0f0f0')
                      .borderRadius(14)
                      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                      .margin({ right: index < 3 ? 6 : 0 })
                      .onClick(() => {
                        this.selectedTabIndex = index;
                      })
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                .margin({ bottom: 10 })

                // 星宿网格
                Grid() {
                  ForEach(this.starRulesConfig!.four_symbols.groups[this.selectedTabIndex].stars,
                    (star: string) => {
                      GridItem() {
                        Column() {
                          Text(this.starRulesConfig!.constellations_full[star]?.animal || '')
                            .fontSize(18)
                          Text(star)
                            .fontSize(13)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(this.selectedUseGodStar === star ? '#ffffff' : '#333333')
                            .margin({ top: 2 })
                        }
                        .width('100%')
                        .height('100%')
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor(this.selectedUseGodStar === star ?
                          this.starRulesConfig!.four_symbols.groups[this.selectedTabIndex].color : '#f8f8f6')
                        .borderRadius(8)
                        .onClick(() => {
                          this.selectedUseGodStar = star;
                          this.showResult = false;
                        })
                      }
                    })
                }
                .columnsTemplate('1fr 1fr 1fr 1fr')
                .rowsTemplate('1fr 1fr')
                .columnsGap(6)
                .rowsGap(6)
                .width('100%')
                .height(110)

                // 用神参考提示
                Row() {
                  Text('参考：')
                    .fontSize(11)
                    .fontColor('#888888')
                  Text(this.starRulesConfig!.use_god_hints.hints[this.selectedUseGodStar] || '')
                    .fontSize(11)
                    .fontColor('#666666')
                    .layoutWeight(1)
                }
                .width('100%')
                .margin({ top: 8 })
                .padding({ left: 6, right: 6, top: 6, bottom: 6 })
                .backgroundColor('#fafaf8')
                .borderRadius(6)
              }
              .width('100%')
            }
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
                  Text(this.getUseGodDisplayText())
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
