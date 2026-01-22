import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { router } from '@kit.ArkUI';
import { loadKnowledge15xConfig, Knowledge15xConfig } from '../utils/Knowledge15x';
import { CalendarManager, CalendarDayInfo } from '../utils/CalendarManager';
import { getQiYaoTypeFromStar, getQiYaoInfo, QiYaoInfo } from '../utils/QiYaoUtils';
import { evaluateDayQuality, DayQualityEvaluation } from '../utils/BaoYiZhuanUtils';
import { getStarEventEvaluation, StarEventEvaluation, StarEventType, StarEventLevel } from '../utils/StarEventRulesUtils';

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

interface StrengthTagsConfig {
  base_branches: Record<string, Array<string>>;
  strong_stars: Array<string>;
}

interface SanheGroupConfig {
  id: string;
  name: string;
  stars: Array<string>;
  tag: string;
  safeSummary: string;
}

interface LiuhePairConfig {
  id: string;
  name: string;
  stars: Array<string>;
  safeSummary: string;
}

interface ComboRulesConfig {
  sanhe_groups: Array<SanheGroupConfig>;
  liuhe_pairs: Array<LiuhePairConfig>;
}

interface SeasonalSeasonInfo {
  label: string;
  branches: Array<string>;
  stars: Array<string>;
  safeSummary: string;
}

interface SeasonalHintsConfig {
  seasons: Record<string, SeasonalSeasonInfo>;
}

interface NobleStarHintItem {
  type: string;
  label: string;
  safeSummary: string;
}

interface NobleStarHintsConfig {
  items: Record<string, NobleStarHintItem>;
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
  strength_tags?: StrengthTagsConfig;
  combo_rules?: ComboRulesConfig;
  seasonal_hints?: SeasonalHintsConfig;
  noble_star_hints?: NobleStarHintsConfig;
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

// 星宿物象信息
interface StarImageryInfo {
  imagery: string;
  material: string;
  examples: string;
}

interface StarGroup {
  name: string;
  stars: string[];
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
  @State useGodSuoBo: SuoBoResult | null = null;

  // 选项数据
  private years: string[] = [];
  private months: string[] = [];
  private days: string[] = [];
  private hourBranches: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
  private stars28: string[] = ['角', '亢', '氐', '房', '心', '尾', '箵', '斗', '牛', '女', '虚', '危', '室', '壁', '奎', '娄', '胃', '昂', '毕', '觜', '参', '井', '鬼', '柳', '星', '张', '翼', '轸'];
  
  // 用神选择
  @State selectedUseGodStar: string = '';
  @State isShowUseGodSheet: boolean = false;

  private starEmojis: Record<string, string> = {
    '角': '🐉', '亢': '🐲', '氐': '🦡', '房': '🐰', '心': '🦊', '尾': '🐯', '箵': '🐆',
    '斗': '🦄', '牛': '🐂', '女': '🦇', '虚': '🐀', '危': '燕', '室': '🐖', '壁': '🦌',
    '奎': '🐺', '娄': '🐕', '胃': '雉', '昂': '🐓', '毕': ' crows', '觜': '🐒', '参': '🦍',
    '井': '🐶', '鬼': '🐏', '柳': '🦌', '星': '🐎', '张': '🦌', '翼': '🐍', '轸': '🐛'
  };
  // 修正部分emoji: 毕(乌)、危(燕)、轸(蚓)、张(鹿)等
  private starEmojiMap: Record<string, string> = {
    '角': '🐉', '亢': '🐲', '氐': '🦡', '房': '🐰', '心': '🦊', '尾': '🐯', '箵': '🐆',
    '斗': '獬', '牛': '🐂', '女': '🦇', '虚': '🐀', '危': '🕊️', '室': '🐖', '壁': '🦌',
    '奎': '🐺', '娄': '🐕', '胃': '雉', '昂': '🐓', '毕': '🐦', '觜': '🐒', '参': '🦍',
    '井': '🐕', '鬼': '🐏', '柳': '🦌', '星': '🐎', '张': '🦌', '翼': '🐍', '轸': '🐛'
  };

  private starGroups: StarGroup[] = [];

  // 吞啖结果
  @State tunDanDesc1: string = '';  // 地禽vs天禽
  @State tunDanDesc2: string = '';  // 天禽vs地禽

  // 飞伏状态
  @State feifuStatus: string = '';
  @State feifuDesc: string = '';

  // 三禽分类
  @State diQinType: string = '';
  @State tianQinType: string = '';
  @State strengthTags: Array<string> = [];
  @State comboHints: Array<string> = [];
  @State seasonalHints: Array<string> = [];
  @State nobleHints: Array<string> = [];
  @State panRiskHints: Array<string> = [];

  // 七曜与宝义专日
  @State dayQiYaoInfo: QiYaoInfo | null = null;
  @State dayInfo: CalendarDayInfo | null = null;
  @State dayLevelInfo: DayQualityEvaluation | null = null;

  aboutToAppear(): void {
    // 初始化选项数据
    for (let i = 0; i < 120; i++) {
      this.years.push((1924 + i).toString());
    }
    for (let i = 1; i <= 12; i++) {
      this.months.push(i.toString());
    }
    for (let i = 1; i <= 31; i++) {
      this.days.push(i.toString());
    }

    this.starGroups = [
      { name: '东方青龙', stars: ['角', '亢', '氐', '房', '心', '尾', '箵'] },
      { name: '北方玄武', stars: ['斗', '牛', '女', '虚', '危', '室', '壁'] },
      { name: '西方白虎', stars: ['奎', '娄', '胃', '昂', '毕', '觜', '参'] },
      { name: '南方朱雀', stars: ['井', '鬼', '柳', '星', '张', '翼', '轸'] }
    ];

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
      await this.calculateAll();
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

  private async calculateAll(): Promise<void> {
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

    // 获取七曜信息
    const qiYaoType = getQiYaoTypeFromStar(dayResult.star);
    if (qiYaoType) {
      this.dayQiYaoInfo = getQiYaoInfo(qiYaoType);
    }

    // 获取万年历信息和宝义专日评估
    this.dayInfo = await CalendarManager.getInstance().getDayInfo(this.selectedYear, this.selectedMonth, this.selectedDay);
    if (this.dayInfo) {
      this.dayLevelInfo = evaluateDayQuality(this.dayInfo.day_gan, this.dayInfo.year_gan);
    }

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

    // 4. 用神锁泊计算
    if (this.selectedUseGodStar) {
      // 用神落宫逻辑：用神泊于落用时 (selectedHourIndex)
      this.useGodSuoBo = this.judgeSuoBo(this.selectedUseGodStar, branches[this.selectedHourIndex], cfg);
    } else {
      this.useGodSuoBo = null;
    }

    // 5. 三禽分类
    this.diQinType = this.getQinType(hourResult.star, cfg);
    this.tianQinType = this.getQinType(fanQinResult.star, cfg);

    // 5. 吞啖判断
    this.tunDanDesc1 = this.judgeTunDan(hourResult.star, fanQinResult.star, cfg);
    this.tunDanDesc2 = this.judgeTunDan(fanQinResult.star, hourResult.star, cfg);

    // 6. 飞伏判断
    const feifuResult = this.judgeFeifu(hourResult.star, this.selectedHourIndex, cfg);
    this.feifuStatus = feifuResult.status;
    this.feifuDesc = feifuResult.desc;

    // 7. 力量标签（入庙与强势星宿）
    this.calculateStrengthTags(cfg);

    // 8. 组合提示（三合/六合）
    this.calculateComboHints();

    // 9. 四季方位提示（魁星方简化）
    this.calculateSeasonalHints(cfg);

    // 10. 贵人宿提示
    this.calculateNobleHints(cfg);

    // 11. 盘面凶煞研习提示（基于 15.13 ~ 15.16 摘要）
    await this.calculatePanRiskHints();
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

  private calculateStrengthTags(cfg: YanqinStarRulesConfig): void {
    const tags: Array<string> = [];
    if (!this.wuQinResult || !cfg.strength_tags) {
      this.strengthTags = tags;
      return;
    }

    const baseBranches = cfg.strength_tags.base_branches;
    const strongStars = cfg.strength_tags.strong_stars;

    const pushTag = (label: string, star: string, branch: string) => {
      if (!star || !branch) {
        tags.push(`${label}：暂无位置信息`);
        return;
      }
      const bases = baseBranches[star] || [];
      const inBase = bases.includes(branch);
      const isStrong = strongStars.includes(star);
      const descParts: Array<string> = [];
      if (inBase) {
        descParts.push('临传统本位宫，发挥较充分');
      }
      if (isStrong) {
        descParts.push('传统视作影响力较强的星宿');
      }
      if (descParts.length === 0) {
        descParts.push('表现中性，可结合其他规则综合参考');
      }
      tags.push(`${label}${star}（${branch}宫）：${descParts.join('，')}`);
    };

    if (this.diQinSuoBo) {
      pushTag('地禽', this.wuQinResult.diQin.star, this.diQinSuoBo.branch);
    }
    if (this.tianQinSuoBo) {
      pushTag('天禽', this.wuQinResult.tianQin.star, this.tianQinSuoBo.branch);
    }
    if (this.huoYaoSuoBo) {
      pushTag('活曜', this.wuQinResult.huoYao.star, this.huoYaoSuoBo.branch);
    }

    this.strengthTags = tags;
  }

  private calculateComboHints(): void {
    const hints: Array<string> = [];
    if (!this.wuQinResult || !this.starRulesConfig || !this.starRulesConfig.combo_rules) {
      this.comboHints = hints;
      return;
    }

    const comboRules = this.starRulesConfig.combo_rules;
    const activeStars: Array<string> = [];
    activeStars.push(this.wuQinResult.yearStar.star);
    activeStars.push(this.wuQinResult.monthStar.star);
    activeStars.push(this.wuQinResult.dayStar.star);
    activeStars.push(this.wuQinResult.diQin.star);
    activeStars.push(this.wuQinResult.tianQin.star);
    activeStars.push(this.wuQinResult.huoYao.star);

    const containsStar = (star: string) => activeStars.includes(star);

    // 三合局提示
    comboRules.sanhe_groups.forEach((group: SanheGroupConfig) => {
      let count = 0;
      group.stars.forEach((s: string) => {
        if (containsStar(s)) {
          count++;
        }
      });
      if (count >= 2) {
        hints.push(`组合【${group.name}】：当前出现 ${count} 宿（${group.stars.join('、')}），${group.safeSummary}`);
      }
    });

    // 六合对提示
    comboRules.liuhe_pairs.forEach((pair: LiuhePairConfig) => {
      const a = pair.stars[0];
      const b = pair.stars[1];
      if (containsStar(a) && containsStar(b)) {
        hints.push(`组合【${pair.name}】：包含 ${a} 与 ${b}，${pair.safeSummary}`);
      }
    });

    this.comboHints = hints;
  }

  private calculateSeasonalHints(cfg: YanqinStarRulesConfig): void {
    const hints: Array<string> = [];
    if (!this.wuQinResult || !cfg.seasonal_hints) {
      this.seasonalHints = hints;
      return;
    }

    const month = this.selectedMonth;
    let seasonKey = '';
    if (month >= 3 && month <= 5) {
      seasonKey = 'spring';
    } else if (month >= 6 && month <= 8) {
      seasonKey = 'summer';
    } else if (month >= 9 && month <= 11) {
      seasonKey = 'autumn';
    } else {
      seasonKey = 'winter';
    }

    const seasonInfo = cfg.seasonal_hints.seasons[seasonKey];
    if (!seasonInfo) {
      this.seasonalHints = hints;
      return;
    }

    // 通用提示
    hints.push(`当前节令：${seasonInfo.label}。${seasonInfo.safeSummary}`);

    // 若时禽同时落在该季节推荐方位，则额外提示一条
    if (this.diQinSuoBo && seasonInfo.branches.includes(this.diQinSuoBo.branch) && seasonInfo.stars.includes(this.wuQinResult.diQin.star)) {
      hints.push(`地禽${this.wuQinResult.diQin.star}落在推荐方位（${this.diQinSuoBo.branch}宫），适合参考为当前主题布置环境或规划方向的提示。`);
    }

    this.seasonalHints = hints;
  }

  private calculateNobleHints(cfg: YanqinStarRulesConfig): void {
    const hints: Array<string> = [];
    if (!this.wuQinResult || !cfg.noble_star_hints) {
      this.nobleHints = hints;
      return;
    }

    const nobleItems = cfg.noble_star_hints.items;

    const pushHintForStar = (roleLabel: string, star: string, branch: string) => {
      const info = nobleItems[star];
      if (!info) {
        return;
      }
      const placeText = branch ? `（${branch}宫）` : '';
      const text = `${roleLabel}${star}${placeText}：${info.label}，${info.safeSummary}`;
      hints.push(text);
    };

    // 只取对解读更直观的四个角色：日禽、地禽、天禽、活曜
    const dayStar = this.wuQinResult.dayStar.star;
    if (nobleItems[dayStar]) {
      pushHintForStar('日禽', dayStar, '');
    }

    if (this.diQinSuoBo && nobleItems[this.wuQinResult.diQin.star]) {
      pushHintForStar('地禽', this.wuQinResult.diQin.star, this.diQinSuoBo.branch);
    }
    if (this.tianQinSuoBo && nobleItems[this.wuQinResult.tianQin.star]) {
      pushHintForStar('天禽', this.wuQinResult.tianQin.star, this.tianQinSuoBo.branch);
    }
    if (this.huoYaoSuoBo && nobleItems[this.wuQinResult.huoYao.star]) {
      pushHintForStar('活曜', this.wuQinResult.huoYao.star, this.huoYaoSuoBo.branch);
    }

    this.nobleHints = hints;
  }

  private async calculatePanRiskHints(): Promise<void> {
    const hints: Array<string> = [];
    if (!this.wuQinResult) {
      this.panRiskHints = hints;
      return;
    }

    const cfg = await loadKnowledge15xConfig(this.context);
    if (!cfg || !cfg.pan_risk) {
      this.panRiskHints = hints;
      return;
    }

    const panCfg = cfg.pan_risk;

    const dayStar = this.wuQinResult.dayStar.star;
    const suoBos: Array<SuoBoResult | null> = [this.diQinSuoBo, this.tianQinSuoBo, this.huoYaoSuoBo];

    // 无头星结构（简化版）
    const wuTouCfg = panCfg.wu_tou;
    for (let i = 0; i < suoBos.length; i++) {
      const sb = suoBos[i];
      if (sb && wuTouCfg.branches.indexOf(sb.branch) >= 0 && wuTouCfg.stars.indexOf(sb.star) >= 0) {
        let text = wuTouCfg.safeSummaryTemplate;
        text = text.replace('{{star}}', sb.star).replace('{{branch}}', sb.branch);
        hints.push(text);
        break;
      }
    }

    // 六恶禽日 / 大煞六凶日（按日禽）
    const liuECfg = panCfg.liu_e_da_sha;
    if (liuECfg.liu_e_stars.indexOf(dayStar) >= 0 || liuECfg.da_sha_stars.indexOf(dayStar) >= 0) {
      let text = liuECfg.safeSummaryTemplate;
      text = text.replace('{{star}}', dayStar);
      hints.push(text);
    }

    // 刑害刀砧 / 汤火方向
    const dangerCfg = panCfg.xinghai_tanghuo;
    const dangerBranches: Array<string> = [];
    for (let i = 0; i < suoBos.length; i++) {
      const sb = suoBos[i];
      if (!sb) {
        continue;
      }
      if (dangerCfg.danger_branches.indexOf(sb.branch) >= 0) {
        if (dangerBranches.indexOf(sb.branch) < 0) {
          dangerBranches.push(sb.branch);
        }
      }
    }
    if (dangerBranches.length > 0) {
      const branchesText = dangerBranches.join('、');
      let text = dangerCfg.safeSummaryTemplate;
      text = text.replace('{{branches}}', branchesText);
      hints.push(text);
    }

    // 空亡 / 寡亡星组
    const kongWangCfg = panCfg.kong_wang_group;
    if (kongWangCfg.stars.indexOf(dayStar) >= 0) {
      let text = kongWangCfg.safeSummaryTemplate;
      text = text.replace('{{star}}', dayStar);
      hints.push(text);
    }

    this.panRiskHints = hints;
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
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // 交互式日期选择区
        Column() {
          Row() {
            // 年
            Select(this.years.map((y: string): SelectOption => ({ value: y + '年' })))
              .value(this.selectedYear.toString() + '年')
              .selected(this.years.indexOf(this.selectedYear.toString()))
              .onSelect((index: number) => {
                this.selectedYear = parseInt(this.years[index]);
                this.calculateAll();
              })
              .height(32)
              .backgroundColor('#f0f0f0')
              .borderRadius(8)
            
            // 月
            Select(this.months.map((m: string): SelectOption => ({ value: m + '月' })))
              .value(this.selectedMonth.toString() + '月')
              .selected(this.selectedMonth - 1)
              .onSelect((index: number) => {
                this.selectedMonth = index + 1;
                this.calculateAll();
              })
              .height(32)
              .backgroundColor('#f0f0f0')
              .borderRadius(8)
              .margin({ left: 4 })

            // 日
            Select(this.days.map((d: string): SelectOption => ({ value: d + '日' })))
              .value(this.selectedDay.toString() + '日')
              .selected(this.selectedDay - 1)
              .onSelect((index: number) => {
                this.selectedDay = index + 1;
                this.calculateAll();
              })
              .height(32)
              .backgroundColor('#f0f0f0')
              .borderRadius(8)
              .margin({ left: 4 })

            // 时辰
            Select(this.hourBranches.map((b: string): SelectOption => ({ value: b + '时' })))
              .value(this.getBranchName(this.selectedHourIndex) + '时')
              .selected(this.selectedHourIndex)
              .onSelect((index: number) => {
                this.selectedHourIndex = index;
                this.calculateAll();
              })
              .height(32)
              .backgroundColor('#f0f0f0')
              .borderRadius(8)
              .margin({ left: 4 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 8 })

          // 用神选择
          Row() {
            Text('🎯 焦点用神')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            
            Blank()
            
            Row() {
              if (this.selectedUseGodStar) {
                Text(this.starEmojiMap[this.selectedUseGodStar] || '✨')
                  .fontSize(18)
                  .margin({ right: 4 })
                Text(`${this.selectedUseGodStar}宿`)
                  .fontSize(14)
                  .fontColor('#d32f2f')
                  .fontWeight(FontWeight.Medium)
              } else {
                Text('未选择')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              Text(' 〉')
                .fontSize(14)
                .fontColor('#cccccc')
            }
            .padding({ left: 12, right: 8, top: 6, bottom: 6 })
            .backgroundColor('#f5f5f5')
            .borderRadius(20)
            .onClick(() => {
              this.isShowUseGodSheet = true;
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .margin({ bottom: 8 })
          .bindSheet(this.isShowUseGodSheet, this.UseGodPicker(), {
            height: SheetSize.MEDIUM,
            title: { title: "选择焦点用神", subtitle: "28星宿分类速选" },
            onDisappear: () => { this.isShowUseGodSheet = false }
          })
        }
        .width('100%')
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

          // ========== 七曜总断与宝义专日 ==========
          if (this.dayQiYaoInfo && this.dayLevelInfo) {
            this.QiYaoBaoYiZhuanCard()

            if (this.getDayStarEventHints().length > 0) {
              Column() {
                Row() {
                  Text('📚 二十八宿用事研习')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#92400e')
                  Blank()
                  Text('仅针对当前日禽')
                    .fontSize(11)
                    .fontColor('#fb923c')
                }
                .width('100%')
                .margin({ bottom: 6 })

                Text('根据《二十八宿诸禽断诀》，整理当前日禽星宿在部分常见用事上的倾向，仅作文化研习参考。')
                  .fontSize(11)
                  .fontColor('#92400e')
                  .width('100%')
                  .margin({ bottom: 6 })

                ForEach(this.getDayStarEventHints(), (item: StarEventEvaluation) => {
                  Column() {
                    Text(this.getStarEventLevelLabel(item.level) + ' · ' + item.eventName)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#7c2d12')
                      .width('100%')
                    Text(item.reason)
                      .fontSize(11)
                      .fontColor('#92400e')
                      .width('100%')
                      .margin({ top: 2 })
                  }
                  .width('100%')
                  .margin({ bottom: 6 })
                })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#fffbeb')
              .borderRadius(12)
              .margin({ left: 16, right: 16, bottom: 12 })
            }
          }
  
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
            .margin({ bottom: 8 })

            if (this.selectedUseGodStar && this.useGodSuoBo) {
              Divider().margin({ top: 4, bottom: 8 })
              Row() {
                Text('🎯 焦点用神：')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#d32f2f')
                Text(this.selectedUseGodStar)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#d32f2f')
                Text(`泊「${this.useGodSuoBo.branch}」${this.useGodSuoBo.environment}宫`)
                  .fontSize(13)
                  .fontColor('#333333')
                  .margin({ left: 8 })
              }
              .width('100%')
              .margin({ bottom: 4 })

              Text(`断语：${this.useGodSuoBo.geName} (${this.useGodSuoBo.geResult})`)
                .fontSize(12)
                .fontColor(this.getResultColor(this.useGodSuoBo.geResult))
                .fontWeight(FontWeight.Medium)
                .width('100%')
              
              Text(this.useGodSuoBo.geText)
                .fontSize(11)
                .fontColor('#666666')
                .width('100%')
                .margin({ top: 2 })
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .margin({ left: 16, right: 16, bottom: 12 })
          
          // ========== 力量提示（入庙与强势星宿） ==========
          if (this.strengthTags.length > 0) {
            Column() {
              Row() {
                Text('⚡ 力量提示')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2e7d32')
                Blank()
                Text('入庙 · 本位 · 强势星一览')
                  .fontSize(11)
                  .fontColor('#4caf50')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Text('根据传统入庙本位与强势星宿，标出当前盘中更容易被关注的位置，仅作文化研习参考。')
                .fontSize(11)
                .fontColor('#666666')
                .width('100%')
                .margin({ bottom: 8 })

              ForEach(this.strengthTags, (item: string) => {
                Row() {
                  Text('●')
                    .fontSize(10)
                    .fontColor('#2e7d32')
                  Text(item)
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 4 })
              })
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#f1f8e9')
            .borderRadius(14)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

          // ========== 组合提示（三合 / 六合） ==========
          if (this.comboHints.length > 0) {
            Column() {
              Row() {
                Text('🤝 组合提示')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1565c0')
                Blank()
                Text('三合局 · 六合对')
                  .fontSize(11)
                  .fontColor('#1e88e5')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Text('根据传统三合局与组合关系，提示盘中哪些星宿彼此呼应，仅作结构理解与文化研习参考。')
                .fontSize(11)
                .fontColor('#666666')
                .width('100%')
                .margin({ bottom: 8 })

              ForEach(this.comboHints, (item: string) => {
                Row() {
                  Text('●')
                    .fontSize(10)
                    .fontColor('#1565c0')
                  Text(item)
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 4 })
              })
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#e3f2fd')
            .borderRadius(14)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

          // ========== 四季方位提示（魁星方简化） ==========
          if (this.seasonalHints.length > 0) {
            Column() {
              Row() {
                Text('🧭 四季方位提示')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ef6c00')
                Blank()
                Text('时令 · 方位参考')
                  .fontSize(11)
                  .fontColor('#fb8c00')
              }
              .width('100%')
              .margin({ bottom: 8 })

              ForEach(this.seasonalHints, (item: string) => {
                Row() {
                  Text('●')
                    .fontSize(10)
                    .fontColor('#ef6c00')
                  Text(item)
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 4 })
              })
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#fff3e0')
            .borderRadius(14)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

          // ========== 凶煞研习提示（15.x 摘要） ==========
          if (this.panRiskHints.length > 0) {
            Column() {
              Row() {
                Text('⚠️ 凶煞研习提示')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#b91c1c')
                Blank()
                Text('仅标记经典格局，供学习使用')
                  .fontSize(11)
                  .fontColor('#f97316')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Text('下列提示仅用于指向 15.13 ~ 15.16 等文档中描述的典型盘面结构，帮助在真实盘面中找到对应案例，不参与结果判断。')
                .fontSize(11)
                .fontColor('#6b7280')
                .width('100%')
                .margin({ bottom: 8 })

              ForEach(this.panRiskHints, (item: string) => {
                Row() {
                  Text('●')
                    .fontSize(10)
                    .fontColor('#b91c1c')
                  Text(item)
                    .fontSize(12)
                    .fontColor('#111827')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 4 })
              })
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#fef2f2')
            .borderRadius(14)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

          // ========== 贵人宿提示 ==========
          if (this.nobleHints.length > 0) {
            Column() {
              Row() {
                Text('⭐ 贵人宿提示')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#8e24aa')
                Blank()
                Text('角色倾向 · 协助氛围')
                  .fontSize(11)
                  .fontColor('#ab47bc')
              }
              .width('100%')
              .margin({ bottom: 8 })

              Text('根据传统禽星贵人宿，只描述角色倾向与协助氛围，用于文化研习参考。')
                .fontSize(11)
                .fontColor('#666666')
                .width('100%')
                .margin({ bottom: 8 })

              ForEach(this.nobleHints, (item: string) => {
                Row() {
                  Text('●')
                    .fontSize(10)
                    .fontColor('#8e24aa')
                  Text(item)
                    .fontSize(12)
                    .fontColor('#333333')
                    .margin({ left: 4 })
                }
                .width('100%')
                .margin({ bottom: 4 })
              })
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#f3e5f5')
            .borderRadius(14)
            .margin({ left: 16, right: 16, bottom: 12 })
          }

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

          // ========== 星宿物象 ==========
          Column() {
            Text('【星宿物象】')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#555555')
              .width('100%')
              .margin({ bottom: 6 })

            Text('出自《射覆玄机赋》— 文化知识参考')
              .fontSize(10)
              .fontColor('#888888')
              .width('100%')
              .margin({ bottom: 10 })

            // 地禽物象
            this.StarImageryItem('地禽', this.wuQinResult.diQin.star, '#2d5a3d')

            // 天禽物象
            this.StarImageryItem('天禽', this.wuQinResult.tianQin.star, '#1a5276')

            // 活曜物象
            this.StarImageryItem('活曜', this.wuQinResult.huoYao.star, '#6a1b9a')

            // 用神物象
            if (this.selectedUseGodStar) {
              this.StarImageryItem('用神', this.selectedUseGodStar, '#d32f2f')
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#f5f5f5')
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
  
  // ============== 锁泊宫位组件 - 天地盘双层展示 ==============
  
  @Builder
  UseGodPicker() {
    Column() {
      Scroll() {
        Column() {
          // 重置选项
          Row() {
            Text('清除当前选择')
              .fontSize(13)
              .fontColor('#666666')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#eeeeee')
              .borderRadius(16)
              .onClick(() => {
                this.selectedUseGodStar = '';
                this.calculateAll();
                this.isShowUseGodSheet = false;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .padding({ right: 16, top: 10, bottom: 4 })

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
                      this.calculateAll();
                      this.isShowUseGodSheet = false;
                    })
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .padding({ left: 16, right: 16 })
              .height(160) // 7个星宿两行高度
            }
          })
          
          // 底部留白，防止被系统手势栏遮挡
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
    .border({ 
      width: this.isUseGodInBranch(branchIndex) ? 2 : 1, 
      color: this.isUseGodInBranch(branchIndex) ? '#d32f2f' : '#e0e0e0' 
    })
    .shadow(this.isUseGodInBranch(branchIndex) ? { radius: 10, color: '#ffcdd2', offsetX: 0, offsetY: 0 } : null)
  }

  // 判断用神是否在该宫位
  private isUseGodInBranch(branchIndex: number): boolean {
    if (!this.selectedUseGodStar) return false;
    const branches = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return this.useGodSuoBo !== null && this.useGodSuoBo.branch === branches[branchIndex];
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

  // 获取二十八宿用事研习提示（仅日禽）
  private getDayStarEventHints(): Array<StarEventEvaluation> {
    const results: Array<StarEventEvaluation> = [];
    if (!this.wuQinResult) {
      return results;
    }
    const star: string = this.wuQinResult.dayStar.star;
    const events: Array<StarEventType> = ['埋葬安葬', '嫁娶纳妾', '行商贸易', '求名考试'];
    events.forEach((eventName: StarEventType) => {
      const evalResult = getStarEventEvaluation(star, eventName);
      if (evalResult) {
        results.push(evalResult);
      }
    });
    return results;
  }

  private getStarEventLevelLabel(level: StarEventLevel): string {
    if (level === 'greatGood') {
      return '大吉';
    }
    if (level === 'good') {
      return '可用';
    }
    if (level === 'neutral') {
      return '平平';
    }
    return '不宜';
  }

  // ============== 星宿物象方法 ==============

  // 星宿物象展示组件
  @Builder
  StarImageryItem(label: string, star: string, color: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(11)
          .fontColor('#ffffff')
          .backgroundColor(color)
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        Text(`${star}宿`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(color)
          .margin({ left: 6 })
        Text(`→ ${this.getStarImagery(star).imagery}`)
          .fontSize(12)
          .fontColor('#333333')
          .margin({ left: 6 })
      }
      .width('100%')
      .margin({ bottom: 4 })

      Row() {
        Text(`材质：${this.getStarImagery(star).material}`)
          .fontSize(11)
          .fontColor('#666666')
        Text(`类例：${this.getStarImagery(star).examples}`)
          .fontSize(11)
          .fontColor('#666666')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 60 })
    }
    .width('100%')
    .margin({ bottom: 10 })
  }

  // 获取星宿物象
  private getStarImagery(star: string): StarImageryInfo {
    const imageryMap = new Map<string, StarImageryInfo>([
      ['角', { imagery: '雕刻精巧之物', material: '木质、绿色', examples: '木雕、竹器、绿色工艺品' }],
      ['亢', { imagery: '首饰、尊贵物', material: '金属、白色', examples: '金饰、印章、贵重饰品' }],
      ['氐', { imagery: '豆麦、瓦石', material: '土质、黄褐色', examples: '不圆不方之物、豆类容器' }],
      ['房', { imagery: '契约、文书', material: '纸质、白色', examples: '合同、书信、印刷品' }],
      ['心', { imagery: '诗词歌赋', material: '纸质、红色', examples: '文学作品、歌谱、音乐类' }],
      ['尾', { imagery: '诗词歌赋', material: '纸质、红色', examples: '文学作品、唱词、印号' }],
      ['箵', { imagery: '破损衣物', material: '布质、黑色', examples: '旧衣、破布、纸币' }],
      ['斗', { imagery: '雕刻精巧之物', material: '木质、绿色', examples: '木器、竹制品' }],
      ['牛', { imagery: '钱财、金银', material: '金属、白色', examples: '钱币、金银器皿、财宝' }],
      ['女', { imagery: '豆麦、瓦石', material: '土质、黄色', examples: '不圆不方之物、石器' }],
      ['虚', { imagery: '文书、词讼', material: '纸质、白色', examples: '官方文书、诉状、契约' }],
      ['危', { imagery: '美至大吉', material: '布质、黑色', examples: '美观物品、硬币、印章' }],
      ['室', { imagery: '猪形物品', material: '土质、黑色', examples: '猪形器皿、陶器' }],
      ['壁', { imagery: '文书、字画', material: '纸质、白色', examples: '书籍、字画、壁挂' }],
      ['奈', { imagery: '雕刻精巧之物', material: '木质、白色', examples: '精美工艺品、狼形器物' }],
      ['娄', { imagery: '狗形物品', material: '金属、白色', examples: '狗形器皿、金属器具' }],
      ['胃', { imagery: '谷米、瓦缸石器', material: '土质、黄色', examples: '米缸、石器、陶罐' }],
      ['昂', { imagery: '鸡形物品', material: '金属、白色', examples: '鸡形器皿、羽毛制品' }],
      ['毕', { imagery: '字画、朱赤印号', material: '纸质、红色', examples: '字画、印章、朱砂制品' }],
      ['觜', { imagery: '宝玉', material: '玉石、绿色', examples: '玉器、翡翠、宝石' }],
      ['参', { imagery: '绸缎', material: '丝绸、白色', examples: '绸布、缎缚、精美布料' }],
      ['井', { imagery: '破旧木器', material: '木质、黄色', examples: '井栏、木桶、破旧木器' }],
      ['鬼', { imagery: '破损铜铁器', material: '金属、黑色', examples: '破损铜器、铁器、旧金属' }],
      ['柳', { imagery: '谷米、瓦缸石器', material: '土质、黄色', examples: '米缸、石器、陶罐' }],
      ['星', { imagery: '音乐乐器', material: '木质、红色', examples: '乐器、音乐盒、马形物品' }],
      ['张', { imagery: '契约、文书', material: '纸质、红色', examples: '合同、文书、美观之物' }],
      ['翼', { imagery: '宝玉、朱赤印号', material: '玉石、红色', examples: '红色宝石、印章、蛇形物' }],
      ['轸', { imagery: '破损破衣物', material: '布质、黑色', examples: '旧衣、破布、蛓蛓形物' }]
    ]);

    const result = imageryMap.get(star);
    if (result) {
      return result;
    }
    return { imagery: '普通物品', material: '不详', examples: '无特殊象义' } as StarImageryInfo;
  }

  // ============== 七曜与宝义专日组件 ==============

  @Builder
  QiYaoBaoYiZhuanCard() {
    Column() {
      Text('── 本日吉凶总断 ──')
        .fontSize(12)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 12 })

      Row() {
        // 左侧：七曜总断
        Column() {
          Row() {
            Text('🌟')
              .fontSize(14)
              .margin({ right: 4 })
            Text(this.dayQiYaoInfo!.name)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.dayQiYaoInfo!.color)
          }
          .margin({ bottom: 6 })

          Text('性质：' + this.dayQiYaoInfo!.nature)
            .fontSize(11)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 4 })

          if (this.dayQiYaoInfo!.suitableEvents.length > 0) {
            Text('✅ ' + this.dayQiYaoInfo!.suitableEvents.join('、'))
              .fontSize(10)
              .fontColor('#4caf50')
              .width('100%')
              .margin({ bottom: 3 })
          }

          if (this.dayQiYaoInfo!.avoidEvents.length > 0) {
            Text('❌ ' + this.dayQiYaoInfo!.avoidEvents.join('、'))
              .fontSize(10)
              .fontColor('#f44336')
              .width('100%')
          }
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor('#f5f5f5')
        .borderRadius(8)

        // 右侧：宝义专日
        Column() {
          Row() {
            Text(this.dayLevelInfo!.dayLevelInfo.emoji)
              .fontSize(14)
              .margin({ right: 4 })
            Text(this.dayLevelInfo!.dayLevelInfo.name)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.dayLevelInfo!.dayLevelInfo.color)
          }
          .margin({ bottom: 6 })

          Text(this.dayLevelInfo!.dayLevelInfo.description)
            .fontSize(11)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 4 })

          if (this.dayLevelInfo!.isChenFanJun) {
            Text('⚠️ 臣犯君大忌')
              .fontSize(10)
              .fontColor('#f44336')
              .width('100%')
              .padding(4)
              .backgroundColor('#fff3e0')
              .borderRadius(4)
          }
        }
        .layoutWeight(1)
        .padding(10)
        .backgroundColor('#e3f2fd')
        .borderRadius(8)
        .margin({ left: 8 })
      }
      .width('100%')

      Text('💡 ' + this.dayLevelInfo!.recommendation)
        .fontSize(11)
        .fontColor('#2196f3')
        .width('100%')
        .lineHeight(16)
        .margin({ top: 10 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#ffffff')
    .borderRadius(14)
    .margin({ left: 16, right: 16, bottom: 12 })
  }
}
