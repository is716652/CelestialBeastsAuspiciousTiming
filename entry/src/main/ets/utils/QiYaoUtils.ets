/**
 * 七曜总断工具类
 * 实现16.1规则：将28宿分为7类，指导事体适配
 */

export type QiYaoType = 'ri' | 'yue' | 'shui' | 'mu' | 'jin' | 'tu' | 'huo';

export interface QiYaoInfo {
  type: QiYaoType;
  name: string;
  alias: string;
  nature: string;
  suitableEvents: string[];
  avoidEvents: string[];
  stars: string[];
  color: string;
}

export interface EventSuggestion {
  eventName: string;
  preferredQiYao: QiYaoType[];
  alternativeQiYao: QiYaoType[];
  forbiddenQiYao: QiYaoType[];
  description: string;
}

/**
 * 七曜完整配置表
 */
const QI_YAO_CONFIG: Record<QiYaoType, QiYaoInfo> = {
  'ri': {
    type: 'ri',
    name: '日曜',
    alias: '喜宿',
    nature: '光明速成',
    suitableEvents: ['求财', '开市', '嫁娶', '出行', '祈福'],
    avoidEvents: ['埋葬', '阴宅修造'],
    stars: ['虚', '昴', '星', '房'],
    color: '#ff9800'
  },
  'yue': {
    type: 'yue',
    name: '月曜',
    alias: '善宿',
    nature: '柔和圆满',
    suitableEvents: ['埋葬', '行商', '百事皆宜'],
    avoidEvents: [],
    stars: ['危', '毕', '心', '张'],
    color: '#4caf50'
  },
  'shui': {
    type: 'shui',
    name: '水曜',
    alias: '弱宿',
    nature: '阴柔怯懦',
    suitableEvents: [],
    avoidEvents: ['造葬', '嫁娶', '上官', '开业', '出行'],
    stars: ['箕', '轸', '参', '壁'],
    color: '#9e9e9e'
  },
  'mu': {
    type: 'mu',
    name: '木曜',
    alias: '文宿',
    nature: '文昌贵气',
    suitableEvents: ['求名', '考试', '出任', '造宅', '签约'],
    avoidEvents: [],
    stars: ['角', '奎', '斗', '井'],
    color: '#2196f3'
  },
  'jin': {
    type: 'jin',
    name: '金曜',
    alias: '威宿',
    nature: '威权肃杀',
    suitableEvents: ['征伐', '上官', '捕盗', '诉讼'],
    avoidEvents: ['嫁娶', '安床', '祈福'],
    stars: ['亢', '娄', '牛', '鬼'],
    color: '#f44336'
  },
  'tu': {
    type: 'tu',
    name: '土曜',
    alias: '怒宿',
    nature: '沉滞官非',
    suitableEvents: [],
    avoidEvents: ['百事皆忌', '主官符牢狱'],
    stars: ['胃', '柳', '氐', '女'],
    color: '#795548'
  },
  'huo': {
    type: 'huo',
    name: '火曜',
    alias: '燥宿',
    nature: '炎上躁动',
    suitableEvents: ['埋葬'],
    avoidEvents: ['造宅', '驾车', '嫁娶', '出行'],
    stars: ['觜', '室', '尾', '翼'],
    color: '#e91e63'
  }
};

/**
 * 28宿到七曜的映射表
 */
const STAR_TO_QIYAO_MAP: Record<string, QiYaoType> = {
  '虚': 'ri', '昴': 'ri', '星': 'ri', '房': 'ri',
  '危': 'yue', '毕': 'yue', '心': 'yue', '张': 'yue',
  '箕': 'shui', '轸': 'shui', '参': 'shui', '壁': 'shui',
  '角': 'mu', '奎': 'mu', '斗': 'mu', '井': 'mu',
  '亢': 'jin', '娄': 'jin', '牛': 'jin', '鬼': 'jin',
  '胃': 'tu', '柳': 'tu', '氐': 'tu', '女': 'tu',
  '觜': 'huo', '室': 'huo', '尾': 'huo', '翼': 'huo'
};

/**
 * 事体配置表
 */
const EVENT_SUGGESTIONS: EventSuggestion[] = [
  {
    eventName: '埋葬安葬',
    preferredQiYao: ['yue', 'huo'],
    alternativeQiYao: [],
    forbiddenQiYao: ['ri', 'shui'],
    description: '月善宿最吉，火燥宿次之；日喜宿阳气太盛不安阴灵，水弱宿主盗主凶'
  },
  {
    eventName: '嫁娶纳妾',
    preferredQiYao: ['ri'],
    alternativeQiYao: ['yue'],
    forbiddenQiYao: ['jin', 'shui'],
    description: '日喜宿最佳，月善宿次之；金威宿主刑伤，水弱宿主懦弱'
  },
  {
    eventName: '求名考试',
    preferredQiYao: ['mu'],
    alternativeQiYao: ['ri'],
    forbiddenQiYao: ['shui', 'tu'],
    description: '木文宿文昌贵气，最利考运；水弱宿主失败，土怒宿主沉滞'
  },
  {
    eventName: '上官赴任',
    preferredQiYao: ['jin', 'mu'],
    alternativeQiYao: ['ri'],
    forbiddenQiYao: ['shui', 'tu'],
    description: '金威宿主权威，木文宿主升迁；水弱宿主受欺，土怒宿遇官符'
  },
  {
    eventName: '征伐捕盗',
    preferredQiYao: ['jin'],
    alternativeQiYao: [],
    forbiddenQiYao: ['shui'],
    description: '金威宿主肃杀制敌，最利征战；水弱宿主盗贼逃逸'
  },
  {
    eventName: '行商贸易',
    preferredQiYao: ['yue'],
    alternativeQiYao: ['ri'],
    forbiddenQiYao: ['shui', 'tu'],
    description: '月善宿柔和顺遂，最利行商；水弱宿主失败被盗，土怒宿主拖延'
  },
  {
    eventName: '造宅修建',
    preferredQiYao: ['mu'],
    alternativeQiYao: ['yue'],
    forbiddenQiYao: ['huo', 'shui'],
    description: '木文宿主生发利建造；火燥宿主火灾，水弱宿主倒塌'
  },
  {
    eventName: '祈福祭祀',
    preferredQiYao: ['ri'],
    alternativeQiYao: ['yue'],
    forbiddenQiYao: ['jin', 'tu'],
    description: '日喜宿阳气充足最佳；金威宿煞气太重，土怒宿主官非'
  }
];

/**
 * 根据日禽获取七曜类型
 */
export function getQiYaoTypeFromStar(star: string): QiYaoType | null {
  return STAR_TO_QIYAO_MAP[star] || null;
}

/**
 * 获取七曜完整信息
 */
export function getQiYaoInfo(type: QiYaoType): QiYaoInfo {
  return QI_YAO_CONFIG[type];
}

/**
 * 获取所有七曜信息列表
 */
export function getAllQiYaoInfo(): QiYaoInfo[] {
  return Object.values(QI_YAO_CONFIG);
}

/**
 * 根据事体名称获取推荐建议
 */
export function getEventSuggestion(eventName: string): EventSuggestion | null {
  return EVENT_SUGGESTIONS.find(e => e.eventName === eventName) || null;
}

/**
 * 获取所有事体类型
 */
export function getAllEventTypes(): string[] {
  return EVENT_SUGGESTIONS.map(e => e.eventName);
}

export interface SuitabilityResult {
  suitable: boolean;
  level: 'excellent' | 'good' | 'neutral' | 'bad' | 'terrible';
  reason: string;
}

export interface SuitableEventsResult {
  excellent: string[];
  good: string[];
  avoid: string[];
}

/**
 * 判断当前日禽是否适合指定事体
 */
export function isStarSuitableForEvent(star: string, eventName: string): SuitabilityResult {
  const qiYaoType = getQiYaoTypeFromStar(star);
  if (!qiYaoType) {
    const result: SuitabilityResult = { suitable: false, level: 'neutral', reason: '未知星宿' };
    return result;
  }

  const suggestion = getEventSuggestion(eventName);
  if (!suggestion) {
    const result: SuitabilityResult = { suitable: false, level: 'neutral', reason: '未知事体类型' };
    return result;
  }

  const qiYaoInfo = getQiYaoInfo(qiYaoType);

  // 判断等级
  if (suggestion.forbiddenQiYao.includes(qiYaoType)) {
    const result: SuitabilityResult = {
      suitable: false,
      level: 'terrible',
      reason: `${qiYaoInfo.name}（${qiYaoInfo.alias}）大凶：${qiYaoInfo.avoidEvents.join('、')}`
    };
    return result;
  }

  if (suggestion.preferredQiYao.includes(qiYaoType)) {
    const result: SuitabilityResult = {
      suitable: true,
      level: 'excellent',
      reason: `${qiYaoInfo.name}（${qiYaoInfo.alias}）大吉：${qiYaoInfo.suitableEvents.join('、')}`
    };
    return result;
  }

  if (suggestion.alternativeQiYao.includes(qiYaoType)) {
    const result: SuitabilityResult = {
      suitable: true,
      level: 'good',
      reason: `${qiYaoInfo.name}（${qiYaoInfo.alias}）次吉：可用但不如首选`
    };
    return result;
  }

  const result: SuitabilityResult = {
    suitable: false,
    level: 'neutral',
    reason: `${qiYaoInfo.name}（${qiYaoInfo.alias}）平平：无明显吉凶倾向`
  };
  return result;
}

/**
 * 获取当前日禽推荐的所有适宜事体
 */
export function getSuitableEventsForStar(star: string): SuitableEventsResult {
  const qiYaoType = getQiYaoTypeFromStar(star);
  if (!qiYaoType) {
    const result: SuitableEventsResult = { excellent: [], good: [], avoid: [] };
    return result;
  }

  const excellent: string[] = [];
  const good: string[] = [];
  const avoid: string[] = [];

  EVENT_SUGGESTIONS.forEach(suggestion => {
    if (suggestion.preferredQiYao.includes(qiYaoType)) {
      excellent.push(suggestion.eventName);
    } else if (suggestion.alternativeQiYao.includes(qiYaoType)) {
      good.push(suggestion.eventName);
    } else if (suggestion.forbiddenQiYao.includes(qiYaoType)) {
      avoid.push(suggestion.eventName);
    }
  });

  const result: SuitableEventsResult = { excellent, good, avoid };
  return result;
}
