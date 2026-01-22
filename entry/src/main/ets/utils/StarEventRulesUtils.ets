/**
 * 二十八宿用事规则工具类（规划中，首批仅录入部分星宿示例）
 *
 * 设计目标：
 * - 在七曜总断（QiYaoUtils）与宝义专日（BaoYiZhuanUtils）两层规则之上，
 *   针对“具体星宿 × 具体事体”提供精细化的用事吉凶等级与简短提示文案；
 * - 仅作为研习与提示使用，保持中性、安全，不直接用于“占断式”结论；
 * - 为后续逐步补全 28 宿规则预留结构。
 */

import { QiYaoType } from './QiYaoUtils';

export type StarEventLevel = 'greatGood' | 'good' | 'neutral' | 'bad';

/**
 * 与 QiYaoUtils 中的事体名称保持一致，便于在智能择日等功能中复用。
 */
export type StarEventType =
  '埋葬安葬' |
  '嫁娶纳妾' |
  '求名考试' |
  '上官赴任' |
  '征伐捕盗' |
  '行商贸易' |
  '造宅修建' |
  '祈福祭祀';

export interface StarEventRule {
  level: StarEventLevel;
  /**
   * 简要原因说明，尽量引用原文含义，但用中性表达方式呈现。
   */
  reason: string;
}

export interface StarEventMap {
  '埋葬安葬'?: StarEventRule;
  '嫁娶纳妾'?: StarEventRule;
  '求名考试'?: StarEventRule;
  '上官赴任'?: StarEventRule;
  '征伐捕盗'?: StarEventRule;
  '行商贸易'?: StarEventRule;
  '造宅修建'?: StarEventRule;
  '祈福祭祀'?: StarEventRule;
}

export interface StarRules {
  /**
   * 星宿简称，如“角”“亢”“房”等。
   */
  star: string;
  /**
   * 星宿全名，如“角木蛟”“房日兔”等。
   */
  name: string;
  /**
   * 所属七曜类型，复用 QiYaoUtils 的七曜分类，方便在 UI 中联动展示。
   */
  qiYaoType: QiYaoType;
  /**
   * 针对不同事体的用事规则（仅录入有明确原文依据的条目）。
   */
  events: StarEventMap;
}

export interface StarEventEvaluation {
  star: string;
  name: string;
  qiYaoType: QiYaoType;
  eventName: StarEventType;
  level: StarEventLevel;
  reason: string;
}

/**
 * 首批示例：根据《二十八宿诸禽断诀》为 8 颗星宿录入部分用事规则，
 * 用于验证数据结构与后续 UI 集成链路。
 */
const STAR_EVENT_RULES: StarRules[] = [
  {
    star: '角',
    name: '角木蛟',
    qiYaoType: 'mu',
    events: {
      // 嫁娶：吉。
      '嫁娶纳妾': {
        level: 'good',
        reason: '原文记载嫁娶为吉，可视为婚姻类事体的顺利配置。'
      },
      // 埋葬：不利。
      '埋葬安葬': {
        level: 'bad',
        reason: '原文记载埋葬不利，适合作为造葬择日时的谨慎提示。'
      },
      // 交易：易成。
      '行商贸易': {
        level: 'good',
        reason: '文中“交易易成”，可理解为从事买卖、行商类事体时较易达成。'
      }
    }
  },
  {
    star: '氐',
    name: '氐土貉',
    qiYaoType: 'tu',
    events: {
      // 嫁娶：婚姻吉。
      '嫁娶纳妾': {
        level: 'good',
        reason: '原文“婚姻吉”，适合作为婚姻类事体的偏吉提示。'
      },
      // 修造迁移埋葬：吉。
      '埋葬安葬': {
        level: 'good',
        reason: '原文“修造迁移埋葬吉”，对造葬相关事体有正向支持。'
      },
      // 上官：赴任吉。
      '上官赴任': {
        level: 'good',
        reason: '原文“上官赴任吉”，可视为仕途、履新场景下的有利配置。'
      }
    }
  },
  {
    star: '房',
    name: '房日兔',
    qiYaoType: 'ri',
    events: {
      // 嫁娶：吉。
      '嫁娶纳妾': {
        level: 'good',
        reason: '原文直接标明嫁娶吉，适合作为婚姻类事体的积极提示。'
      },
      // 埋葬：进益人口，子孙富贵。
      '埋葬安葬': {
        level: 'good',
        reason: '原文“埋葬进益人口，子孙富贵”，可作为造葬择日时的偏吉参考。'
      },
      // 求财：吉，用辰及水时吉。
      '行商贸易': {
        level: 'good',
        reason: '原文“求财吉”，配合适当时辰有利于财物类事务与交易推进。'
      },
      // 上官赴任：有升钦宠。
      '上官赴任': {
        level: 'good',
        reason: '原文“上官赴任有升钦宠”，偏向仕途上升与获得赏识。'
      }
    }
  },
  {
    star: '虚',
    name: '虚日鼠',
    qiYaoType: 'ri',
    events: {
      // 嫁娶：凶。
      '嫁娶纳妾': {
        level: 'bad',
        reason: '原文直接标明嫁娶为凶，适合作为婚姻类事体的明显规避信号。'
      },
      // 造宅：凶。
      '造宅修建': {
        level: 'bad',
        reason: '原文“造宅凶”，在房屋营造与修建相关事体上需特别谨慎。'
      },
      // 求名：先凶后吉，可谋。
      '求名考试': {
        level: 'neutral',
        reason: '原文“求名先凶后吉，可谋”，整体可视为有波折但尚可谋求之象。'
      }
    }
  },
  {
    star: '危',
    name: '危月燕',
    qiYaoType: 'yue',
    events: {
      // 婚姻嫁娶：和合吉。
      '嫁娶纳妾': {
        level: 'good',
        reason: '原文“婚姻嫁娶和合吉”，适合作为婚姻类事体的和顺配置。'
      },
      // 埋葬：四金时吉。
      '埋葬安葬': {
        level: 'good',
        reason: '原文“埋葬四金时吉”，在配合适当时辰时对造葬有加分意义。'
      },
      // 买卖：折本。
      '行商贸易': {
        level: 'bad',
        reason: '原文“买卖折本”，提示与交易、行商相关事体宜多加防范。'
      }
    }
  },
  {
    star: '昴',
    name: '昴日鸡',
    qiYaoType: 'ri',
    events: {
      // 婚姻：大吉。
      '嫁娶纳妾': {
        level: 'greatGood',
        reason: '原文“婚姻大吉”，可视为婚姻事体的强力利好配置。'
      },
      // 埋葬：凶。
      '埋葬安葬': {
        level: 'bad',
        reason: '原文明确标注埋葬为凶，适合作为造葬相关事体的强烈规避信号。'
      },
      // 求财：四金时吉。
      '行商贸易': {
        level: 'good',
        reason: '原文“求财四金时吉”，在合适时间条件下有利于财务及交易活动。'
      },
      // 上官赴任：有贵人提拔。
      '上官赴任': {
        level: 'good',
        reason: '原文“上官赴任有贵人提拔”，偏向职场升迁与外力助推。'
      }
    }
  },
  {
    star: '井',
    name: '井木犴',
    qiYaoType: 'mu',
    events: {
      // 嫁娶：和合。
      '嫁娶纳妾': {
        level: 'good',
        reason: '原文“嫁娶和合”，适合作为婚姻类事体的调和配置。'
      },
      // 埋葬：凶。
      '埋葬安葬': {
        level: 'bad',
        reason: '原文“埋葬凶”，在造葬相关事体中宜视为明显不宜使用的配置。'
      },
      // 求财：用四土宿吉。
      '行商贸易': {
        level: 'good',
        reason: '原文“求财用四土宿吉”，在适宜条件下有利于财务与经营活动。'
      }
    }
  },
  {
    star: '鬼',
    name: '鬼金羊',
    qiYaoType: 'jin',
    events: {
      // 嫁娶：相刑不利。
      '嫁娶纳妾': {
        level: 'bad',
        reason: '原文“嫁娶相刑不利”，适合作为婚姻类事体的明显规避提示。'
      },
      // 埋葬：吉。
      '埋葬安葬': {
        level: 'good',
        reason: '原文“埋葬吉”，在造葬相关事体中可视为偏吉配置。'
      },
      // 求财：用四木时吉。
      '行商贸易': {
        level: 'good',
        reason: '原文“求财用四木时吉”，在适宜时间条件下有利于与财物相关的活动。'
      },
      // 赴任：不吉。
      '上官赴任': {
        level: 'bad',
        reason: '原文“赴任不吉”，在履新、上官类事体上宜加强风险意识。'
      }
    }
  }
];

/**
 * 获取指定星宿在某个事体上的用事评价。
 * 若当前星宿或事体暂未录入规则，返回 null。该行为在业务层面
 * 视为“无额外星宿级加减分，仅依七曜与宝义专日判断”。
 */
export function getStarEventEvaluation(star: string, eventName: StarEventType): StarEventEvaluation | null {
  let name: string = '';
  let qiYaoType: QiYaoType = 'ri';
  let level: StarEventLevel | null = null;
  let reason: string = '';

  if (star === '角') {
    name = '角木蛟';
    qiYaoType = 'mu';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文记载嫁娶为吉，可视为婚姻类事体的顺利配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文记载埋葬不利，适合作为造葬择日时的谨慎提示。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '文中“交易易成”，可理解为从事买卖、行商类事体时较易达成。';
    }
  } else if (star === '氐') {
    name = '氐土貉';
    qiYaoType = 'tu';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“婚姻吉”，适合作为婚姻类事体的偏吉提示。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“修造迁移埋葬吉”，对造葬相关事体有正向支持。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任吉”，可视为仕途、履新场景下的有利配置。';
    }
  } else if (star === '房') {
    name = '房日兔';
    qiYaoType = 'ri';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文直接标明嫁娶吉，适合作为婚姻类事体的积极提示。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬进益人口，子孙富贵”，可作为造葬择日时的偏吉参考。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财吉”，配合适当时辰有利于财物类事务与交易推进。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任有升钦宠”，偏向仕途上升与获得赏识。';
    }
  } else if (star === '虚') {
    name = '虚日鼠';
    qiYaoType = 'ri';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文直接标明嫁娶为凶，适合作为婚姻类事体的明显规避信号。';
    } else if (eventName === '造宅修建') {
      level = 'bad';
      reason = '原文“造宅凶”，在房屋营造与修建相关事体上需特别谨慎。';
    } else if (eventName === '求名考试') {
      level = 'neutral';
      reason = '原文“求名先凶后吉，可谋”，整体可视为有波折但尚可谋求之象。';
    }
  } else if (star === '危') {
    name = '危月燕';
    qiYaoType = 'yue';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“婚姻嫁娶和合吉”，适合作为婚姻类事体的和顺配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬四金时吉”，在配合适当时辰时对造葬有加分意义。';
    } else if (eventName === '行商贸易') {
      level = 'bad';
      reason = '原文“买卖折本”，提示与交易、行商相关事体宜多加防范。';
    }
  } else if (star === '昴') {
    name = '昴日鸡';
    qiYaoType = 'ri';
    if (eventName === '嫁娶纳妾') {
      level = 'greatGood';
      reason = '原文“婚姻大吉”，可视为婚姻事体的强力利好配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文明确标注埋葬为凶，适合作为造葬相关事体的强烈规避信号。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财四金时吉”，在合适时间条件下有利于财务及交易活动。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任有贵人提拔”，偏向职场升迁与外力助推。';
    }
  } else if (star === '井') {
    name = '井木犴';
    qiYaoType = 'mu';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶和合”，适合作为婚姻类事体的调和配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬凶”，在造葬相关事体中宜视为明显不宜使用的配置。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财用四土宿吉”，在适宜条件下有利于财务与经营活动。';
    }
  } else if (star === '鬼') {
    name = '鬼金羊';
    qiYaoType = 'jin';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“嫁娶相刑不利”，适合作为婚姻类事体的明显规避提示。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬吉”，在造葬相关事体中可视为偏吉配置。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财用四木时吉”，在适宜时间条件下有利于与财物相关的活动。';
    } else if (eventName === '上官赴任') {
      level = 'bad';
      reason = '原文“赴任不吉”，在履新、上官类事体上宜加强风险意识。';
    }
  }

  if (level === null) {
    return null;
  }

  const evaluation: StarEventEvaluation = {
    star,
    name,
    qiYaoType,
    eventName,
    level,
    reason
  };
  return evaluation;
}
