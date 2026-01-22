/**
 * 宝义专日工具类
 * 实现15.19规则：时间能量评级体系
 */

export type DayLevel = 'bao' | 'yi' | 'zhuan' | 'zhi' | 'fa' | 'unknown';

export interface DayLevelInfo {
  level: DayLevel;
  name: string;
  quality: 'excellent' | 'good' | 'good' | 'neutral' | 'bad';
  description: string;
  suitableEvents: string[];
  color: string;
  emoji: string;
}

/**
 * 五级日分类配置
 */
const DAY_LEVEL_CONFIG: Record<DayLevel, DayLevelInfo> = {
  'bao': {
    level: 'bao',
    name: '宝日',
    quality: 'excellent',
    description: '如珍宝，百事皆宜',
    suitableEvents: ['造葬', '嫁娶', '上官', '开业', '出行'],
    color: '#4caf50',
    emoji: '💎'
  },
  'yi': {
    level: 'yi',
    name: '义日',
    quality: 'good',
    description: '主道义、合作',
    suitableEvents: ['签约', '结盟', '求医', '合作'],
    color: '#2196f3',
    emoji: '🤝'
  },
  'zhuan': {
    level: 'zhuan',
    name: '专日',
    quality: 'good',
    description: '专一成就，事有专功',
    suitableEvents: ['开业', '动土', '求名', '专项事务'],
    color: '#ff9800',
    emoji: '🎯'
  },
  'zhi': {
    level: 'zhi',
    name: '制日',
    quality: 'neutral',
    description: '受制约，需谨慎',
    suitableEvents: ['小事可用，大事不宜'],
    color: '#9e9e9e',
    emoji: '⚠️'
  },
  'fa': {
    level: 'fa',
    name: '伐日',
    quality: 'bad',
    description: '主征伐、破坏',
    suitableEvents: [],
    color: '#f44336',
    emoji: '❌'
  },
  'unknown': {
    level: 'unknown',
    name: '未知',
    quality: 'neutral',
    description: '无特殊标记',
    suitableEvents: [],
    color: '#757575',
    emoji: '❓'
  }
};

/**
 * 宝义专日查询表（按地支）
 * 宝日：戊己；义日：丙丁；专日：壬癸
 */
const BAO_YI_ZHUAN_BY_GAN: Record<string, DayLevel> = {
  '甲': 'unknown',
  '乙': 'unknown',
  '丙': 'yi',
  '丁': 'yi',
  '戊': 'bao',
  '己': 'bao',
  '庚': 'unknown',
  '辛': 'unknown',
  '壬': 'zhuan',
  '癸': 'zhuan'
};

/**
 * 根据日干判断宝义专日
 */
export function getDayLevelByGan(dayGan: string): DayLevel {
  return BAO_YI_ZHUAN_BY_GAN[dayGan] || 'unknown';
}

/**
 * 获取日级别完整信息
 */
export function getDayLevelInfo(level: DayLevel): DayLevelInfo {
  return DAY_LEVEL_CONFIG[level];
}

export interface ChenFanJunResult {
  isChenFanJun: boolean;
  description: string;
}

/**
 * 判断是否臣犯君（日干克岁干）
 */
export function checkChenFanJun(dayGan: string, yearGan: string): ChenFanJunResult {
  const kezhiMap: Map<string, string[]> = new Map([
    ['甲', ['戊', '己']],  // 木克土
    ['乙', ['戊', '己']],
    ['丙', ['庚', '辛']],  // 火克金
    ['丁', ['庚', '辛']],
    ['戊', ['壬', '癸']],  // 土克水
    ['己', ['壬', '癸']],
    ['庚', ['甲', '乙']],  // 金克木
    ['辛', ['甲', '乙']],
    ['壬', ['丙', '丁']],  // 水克火
    ['癸', ['丙', '丁']]
  ]);

  const beikeGan = kezhiMap.get(dayGan) || [];
  const isChenFanJun = beikeGan.includes(yearGan);

  const result: ChenFanJunResult = {
    isChenFanJun,
    description: isChenFanJun 
      ? `⚠️ 日干${dayGan}克岁干${yearGan}，臣犯君，主以下犯上、损人丁、官非牢狱` 
      : ''
  };
  return result;
}

export interface DayQualityEvaluation {
  dayLevel: DayLevel;
  dayLevelInfo: DayLevelInfo;
  isChenFanJun: boolean;
  chenFanJunDesc: string;
  finalQuality: 'excellent' | 'good' | 'neutral' | 'bad';
  recommendation: string;
}

/**
 * 综合评估当日吉凶（结合宝义专日、臣犯君）
 */
export function evaluateDayQuality(dayGan: string, yearGan: string): DayQualityEvaluation {
  const dayLevel = getDayLevelByGan(dayGan);
  const dayLevelInfo = getDayLevelInfo(dayLevel);
  const chenFanJun = checkChenFanJun(dayGan, yearGan);

  // 如果臣犯君，降级处理
  let finalQuality = dayLevelInfo.quality;
  let recommendation = '';

  if (chenFanJun.isChenFanJun) {
    if (dayLevel === 'bao' || dayLevel === 'yi' || dayLevel === 'zhuan') {
      finalQuality = 'bad';
      recommendation = `虽为${dayLevelInfo.name}，但犯臣犯君大忌，吉神被制，反凶！建议改日`;
    } else {
      finalQuality = 'bad';
      recommendation = `${dayLevelInfo.name}且犯臣犯君，极凶之日，百事不宜`;
    }
  } else {
    // 无臣犯君，按原等级
    if (dayLevel === 'bao') {
      recommendation = '宝日大吉，百事皆宜，可配合月善宿或日喜宿，吉上加吉';
    } else if (dayLevel === 'yi') {
      recommendation = '义日吉利，主道义合作，宜签约结盟、求医问药';
    } else if (dayLevel === 'zhuan') {
      recommendation = '专日吉利，事有专功，宜开业动土、求名考试';
    } else if (dayLevel === 'zhi') {
      recommendation = '制日平平，小事可行，大事需慎重考虑';
    } else if (dayLevel === 'fa') {
      recommendation = '伐日大凶，主征伐破坏，百事忌用，尤忌造葬嫁娶';
    } else {
      recommendation = '平常日期，可结合禽星七曜判断';
    }
  }

  const result: DayQualityEvaluation = {
    dayLevel,
    dayLevelInfo,
    isChenFanJun: chenFanJun.isChenFanJun,
    chenFanJunDesc: chenFanJun.description,
    finalQuality,
    recommendation
  };
  return result;
}

export interface FutureBaoYiZhuanDay {
  date: string;
  dayGan: string;
  dayLevel: DayLevel;
  levelInfo: DayLevelInfo;
}

/**
 * 获取未来N天的宝义专日列表（用于择日助手）
 */
export function getFutureBaoYiZhuanDays(
  startYear: number,
  startMonth: number,
  startDay: number,
  daysCount: number,
  targetLevel: DayLevel[]
): FutureBaoYiZhuanDay[] {
  // 简化实现：需要配合万年历数据
  // 实际使用时应调用CalendarManager获取真实干支
  const result: FutureBaoYiZhuanDay[] = [];

  // 此处仅示例结构，实际需要异步加载万年历数据
  // 暂时返回空数组，实际使用时在调用层处理

  return result;
}

/**
 * 口诀记忆辅助
 */
export const BAO_YI_ZHUAN_FORMULA = '戊己为宝，丙丁为义，壬癸为专';

/**
 * 使用指南
 */
export const USAGE_GUIDE = `
宝义专日使用流程：
1. 先排除伏断、空亡、伐日等凶日
2. 根据事体选择适配禽星（参考七曜总断）
3. 在吉日中优选宝义专日
4. 确认不犯臣犯君（日干不克岁干）
5. 配合时辰禽星，最终择定吉时
`;
