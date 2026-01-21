import { common } from '@kit.AbilityKit';
import { buffer, JSON as ArkJSON } from '@kit.ArkTS';
import { CalendarDayInfo } from './CalendarManager';

export type RiskLevel = 'mild' | 'medium' | 'high';

export interface TimeRiskTag {
  id: string;
  label: string;
  level: RiskLevel;
  safeSummary: string;
}

export interface TimeTrendResult {
  tags: Array<TimeRiskTag>;
}

export interface TimeTrendTenEvilConfig {
  gan_zhi: Array<string>;
  label: string;
  level: RiskLevel;
  safeSummary: string;
}

export interface TimeTrendHuangWuConfig {
  branch_by_month: Array<string>;
  label: string;
  level: RiskLevel;
  safeSummary: string;
}

export interface TimeTrendLuoTianRuleConfig {
  lunar_day: number;
  retreat_branch?: string;
  advance_branch?: string;
}

export interface TimeTrendLuoTianLabelConfig {
  label: string;
  level: RiskLevel;
  safeSummary: string;
}

export interface TimeTrendLuoTianConfig {
  rules: Array<TimeTrendLuoTianRuleConfig>;
  retreat: TimeTrendLuoTianLabelConfig;
  advance: TimeTrendLuoTianLabelConfig;
}

export interface TimeTrendSixJiaItemConfig {
  gan_zhi: Array<string>;
  label: string;
  level: RiskLevel;
  safeSummary: string;
}

export interface TimeTrendSixJiaConfig {
  progress: TimeTrendSixJiaItemConfig;
  retreat: TimeTrendSixJiaItemConfig;
  hide: TimeTrendSixJiaItemConfig;
}

export interface TimeTrendGeneralArrowGroupConfig {
  day_gan: Array<string>;
  branches: Array<string>;
}

export interface TimeTrendGeneralArrowConfig {
  groups: Array<TimeTrendGeneralArrowGroupConfig>;
  label: string;
  level: RiskLevel;
  safeSummaryTemplate: string;
}

export interface TimeTrendShiZhongGroupConfig {
  day_zhi: Array<string>;
  time: string;
  group_label: string;
}

export interface TimeTrendShiZhongConfig {
  groups: Array<TimeTrendShiZhongGroupConfig>;
  label: string;
  level: RiskLevel;
  safeSummaryTemplate: string;
}

export interface TimeTrendConfig {
  ten_evil: TimeTrendTenEvilConfig;
  huang_wu: TimeTrendHuangWuConfig;
  luotian: TimeTrendLuoTianConfig;
  sixjia: TimeTrendSixJiaConfig;
  general_arrow: TimeTrendGeneralArrowConfig;
  shi_zhong_jiangxing: TimeTrendShiZhongConfig;
}

export interface PanRiskWuTouConfig {
  stars: Array<string>;
  branches: Array<string>;
  label: string;
  safeSummaryTemplate: string;
}

export interface PanRiskLiuEDaShaConfig {
  liu_e_stars: Array<string>;
  da_sha_stars: Array<string>;
  label: string;
  safeSummaryTemplate: string;
}

export interface PanRiskXingHaiTangHuoConfig {
  danger_branches: Array<string>;
  label: string;
  safeSummaryTemplate: string;
}

export interface PanRiskKongWangConfig {
  stars: Array<string>;
  label: string;
  safeSummaryTemplate: string;
}

export interface PanRiskConfig {
  wu_tou: PanRiskWuTouConfig;
  liu_e_da_sha: PanRiskLiuEDaShaConfig;
  xinghai_tanghuo: PanRiskXingHaiTangHuoConfig;
  kong_wang_group: PanRiskKongWangConfig;
}

export interface Knowledge15xConfig {
  time_trend: TimeTrendConfig;
  pan_risk: PanRiskConfig;
}

let cachedKnowledgeConfig: Knowledge15xConfig | null = null;

export interface WeatherResult {
  label: string;
  description: string;
}

const NAYIN_ELEMENT_MAP: Record<string, string> = {
  '甲子': '金', '乙丑': '金', '丙寅': '火', '丁卯': '火', '戊辰': '木', '己巳': '木', '庚午': '土', '辛未': '土', '壬申': '金', '癸酉': '金',
  '甲戌': '火', '乙亥': '火', '丙子': '水', '丁丑': '水', '戊寅': '土', '己卯': '土', '庚辰': '金', '辛巳': '金', '壬午': '木', '癸未': '木',
  '甲申': '水', '乙酉': '水', '丙戌': '土', '丁亥': '土', '戊子': '火', '己丑': '火', '庚寅': '木', '辛卯': '木', '壬辰': '水', '癸巳': '水',
  '甲午': '金', '乙未': '金', '丙申': '火', '丁酉': '火', '戊戌': '木', '己亥': '木', '庚子': '土', '辛丑': '土', '壬寅': '金', '癸卯': '金',
  '甲辰': '火', '乙巳': '火', '丙午': '水', '丁未': '水', '戊申': '土', '己酉': '土', '庚戌': '金', '辛亥': '金', '壬子': '木', '癸丑': '木',
  '甲寅': '水', '乙卯': '水', '丙辰': '土', '丁巳': '土', '戊午': '火', '己未': '火', '庚申': '木', '辛酉': '木', '壬戌': '水', '癸亥': '水'
};

const ELEMENT_RELATION: Record<string, Record<string, string>> = {
  '金': { '金': '比和', '木': '我克', '水': '我生', '火': '克我', '土': '生我' },
  '木': { '金': '克我', '木': '比和', '水': '生我', '火': '我生', '土': '我克' },
  '水': { '金': '生我', '木': '我生', '水': '比和', '火': '我克', '土': '克我' },
  '火': { '金': '我克', '木': '生我', '水': '克我', '火': '比和', '土': '我生' },
  '土': { '金': '生我', '木': '克我', '水': '我克', '火': '生我', '土': '比和' }
};

export function calcWeatherPrediction(day: CalendarDayInfo, dayStarElement: string): WeatherResult {
  const ganZhi = `${day.day_gan}${day.day_zhi}`;
  const dayElement = NAYIN_ELEMENT_MAP[ganZhi] || '土';
  const starElement = dayStarElement;

  const relation = ELEMENT_RELATION[dayElement]?.[starElement] || '比和';

  let label = '未知';
  let description = '';

  if (relation === '我克') {
    label = '阴晦';
    description = '日辰克日宿，主能量受压，阴云密布。';
  } else if (relation === '克我') {
    label = '天晴';
    description = '日宿克日辰，反主天朗气清，阳光明媚。';
  } else if (relation === '我生') {
    label = '阴天';
    description = '日辰生日宿，能量泄化，云雾渐生。';
  } else if (relation === '生我') {
    label = '晴朗';
    description = '日宿生日辰，气机回补，晴空万里。';
  } else {
    // 比和
    if (dayElement === '火') {
      label = '大晴';
      description = '日宿日辰皆火，烈日当空。';
    } else if (dayElement === '金' || dayElement === '水') {
      label = '雨雪';
      description = '日宿日辰寒湿比和，易生雨雪。';
    } else if (dayElement === '木') {
      label = '生风';
      description = '日宿日辰皆木，气流涌动，主大风。';
    } else {
      label = '阴晦';
      description = '日宿日辰皆土，气机滞塞，天色昏暗。';
    }
  }

  return { label, description };
}

export async function loadKnowledge15xConfig(context: common.Context): Promise<Knowledge15xConfig | null> {
  if (cachedKnowledgeConfig) {
    return cachedKnowledgeConfig;
  }
  try {
    const value = await context.resourceManager.getRawFileContent('yanqin_knowledge_15x.json');
    const str = buffer.from(value.buffer).toString();
    const cfg = ArkJSON.parse(str) as Knowledge15xConfig;
    cachedKnowledgeConfig = cfg;
    return cfg;
  } catch (err) {
    console.error('Failed to load yanqin_knowledge_15x.json, error: ' + JSON.stringify(err));
    return null;
  }
}

export async function calcTimeTrendFromCalendar(day: CalendarDayInfo, context: common.Context): Promise<TimeTrendResult> {
  const tags: Array<TimeRiskTag> = [];

  const cfg = await loadKnowledge15xConfig(context);
  if (!cfg || !cfg.time_trend) {
    return { tags };
  }

  const timeCfg = cfg.time_trend;

  const ganZhi = `${day.day_gan}${day.day_zhi}`;

  // 十恶大败日
  const tenEvil = timeCfg.ten_evil;
  if (tenEvil.gan_zhi.indexOf(ganZhi) >= 0) {
    tags.push({
      id: 'ten_evil_day',
      label: tenEvil.label,
      level: tenEvil.level,
      safeSummary: tenEvil.safeSummary
    });
  }

  // 天地荒芜日
  const huangWu = timeCfg.huang_wu;
  if (day.lunar_month >= 1 && day.lunar_month < huangWu.branch_by_month.length) {
    const branch = huangWu.branch_by_month[day.lunar_month];
    if (branch && branch === day.day_zhi) {
      tags.push({
        id: 'huang_wu_day',
        label: huangWu.label,
        level: huangWu.level,
        safeSummary: huangWu.safeSummary
      });
    }
  }

  // 罗天大进退日
  const luotian = timeCfg.luotian;
  for (let i = 0; i < luotian.rules.length; i++) {
    const rule = luotian.rules[i];
    if (rule.lunar_day === day.lunar_day) {
      if (rule.retreat_branch && rule.retreat_branch === day.day_zhi) {
        tags.push({
          id: 'luotian_retreat',
          label: luotian.retreat.label,
          level: luotian.retreat.level,
          safeSummary: luotian.retreat.safeSummary
        });
      } else if (rule.advance_branch && rule.advance_branch === day.day_zhi) {
        tags.push({
          id: 'luotian_advance',
          label: luotian.advance.label,
          level: luotian.advance.level,
          safeSummary: luotian.advance.safeSummary
        });
      }
      break;
    }
  }

  // 六甲进退伏起始日
  const sixjia = timeCfg.sixjia;
  if (sixjia.progress.gan_zhi.indexOf(ganZhi) >= 0) {
    tags.push({
      id: 'sixjia_progress',
      label: sixjia.progress.label,
      level: sixjia.progress.level,
      safeSummary: sixjia.progress.safeSummary
    });
  } else if (sixjia.retreat.gan_zhi.indexOf(ganZhi) >= 0) {
    tags.push({
      id: 'sixjia_retreat',
      label: sixjia.retreat.label,
      level: sixjia.retreat.level,
      safeSummary: sixjia.retreat.safeSummary
    });
  } else if (sixjia.hide.gan_zhi.indexOf(ganZhi) >= 0) {
    tags.push({
      id: 'sixjia_hide',
      label: sixjia.hide.label,
      level: sixjia.hide.level,
      safeSummary: sixjia.hide.safeSummary
    });
  }

  // 李广将军箭方（研习提示）
  const arrowCfg = timeCfg.general_arrow;
  let arrowBranches = '';
  for (let i = 0; i < arrowCfg.groups.length; i++) {
    const group = arrowCfg.groups[i];
    if (group.day_gan.indexOf(day.day_gan) >= 0) {
      arrowBranches = group.branches.join('、');
      break;
    }
  }
  if (arrowBranches !== '') {
    let summary = arrowCfg.safeSummaryTemplate;
    summary = summary.replace('{{gan}}', day.day_gan).replace('{{branches}}', arrowBranches);
    tags.push({
      id: 'general_arrow',
      label: arrowCfg.label,
      level: arrowCfg.level,
      safeSummary: summary
    });
  }

  // 时中将星（研习提示）
  const jiangCfg = timeCfg.shi_zhong_jiangxing;
  let jiangTime = '';
  let groupLabel = '';
  for (let i = 0; i < jiangCfg.groups.length; i++) {
    const group = jiangCfg.groups[i];
    if (group.day_zhi.indexOf(day.day_zhi) >= 0) {
      jiangTime = group.time;
      groupLabel = group.group_label;
      break;
    }
  }
  if (jiangTime !== '') {
    let summary = jiangCfg.safeSummaryTemplate;
    summary = summary.replace('{{groupLabel}}', groupLabel).replace('{{time}}', jiangTime);
    tags.push({
      id: 'shi_zhong_jiangxing',
      label: jiangCfg.label,
      level: jiangCfg.level,
      safeSummary: summary
    });
  }

  return { tags };
}
