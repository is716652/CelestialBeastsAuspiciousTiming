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

  // 角木蛟
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
  }
  // 亢金龙
  else if (star === '亢') {
    name = '亢金龙';
    qiYaoType = 'jin';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：后二千石禄”，可视为婚姻后有较好福泽的配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：益子孙富贵”，对造葬事体有积极加成。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财便见利”“交易辰午未时成就”，整体利于财物与买卖。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官移徙吉”，适合作为履新、调动类事体的偏吉配置。';
    }
  }
  // 氐土貉
  else if (star === '氐') {
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
  }
  // 房日兔
  else if (star === '房') {
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
  }
  // 心月狐
  else if (star === '心') {
    name = '心月狐';
    qiYaoType = 'yue';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：美”，可视为婚姻类事体的和顺偏吉配置。';
    } else if (eventName === '行商贸易') {
      level = 'neutral';
      reason = '原文“求财：难，四火时利”，整体较为不易，但在合适时机仍可谋求。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：有升”，有利于仕途发展。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：大利，益人口”，适合作为修造相关事体的积极配置。';
    }
  }
  // 尾火虎
  else if (star === '尾') {
    name = '尾火虎';
    qiYaoType = 'huo';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：小吉”，婚姻类事体略有助益。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：凶，火山向”，提示造葬事体需严格回避。';
    } else if (eventName === '行商贸易') {
      level = 'bad';
      reason = '原文“交易：主有失利”，对买卖、行商不利。';
    } else if (eventName === '造宅修建') {
      level = 'bad';
      reason = '原文“起造：不宜，主失火”，修造类事体存在较大风险。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：吉”，对履新、赴任有一定支持。';
    }
  }
  // 箕水豹
  else if (star === '箕') {
    name = '箕水豹';
    qiYaoType = 'shui';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“嫁娶：凶，若金水男女方可”，一般不利于婚姻事体。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“造作埋葬：不利”，造葬类事体应尽量回避。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四火时吉”，在适宜时机下有利于财物与交易活动。';
    }
  }
  // 斗木獬
  else if (star === '斗') {
    name = '斗木獬';
    qiYaoType = 'mu';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“婚姻：嫁娶不合，有刑”，提示婚姻事体存在相刑风险。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“造葬：不利，凶”，造葬相关事体应避免。';
    } else if (eventName === '行商贸易') {
      level = 'bad';
      reason = '原文“买卖：折本”，对买卖、行商极为不利。';
    } else if (eventName === '上官赴任') {
      level = 'bad';
      reason = '原文“上官赴任：不久被人告罢”，不利于仕途与履新。';
    } else if (eventName === '造宅修建') {
      level = 'bad';
      reason = '原文中与造葬、失火关联较多，修造相关事体宜谨慎或回避。';
    }
  }
  // 牛金牛
  else if (star === '牛') {
    name = '牛金牛';
    qiYaoType = 'jin';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：土金水男女命合吉”，婚配适宜时可视为偏吉配置。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“买卖：获利”，对交易、经营活动有一定帮助。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：四年升”，利于长期仕途发展.。';
    } else if (eventName === '求名考试') {
      level = 'neutral';
      reason = '原文“谋望：难成”，在求名、谋望上存在一定阻力。';
    }
  }
  // 女土蝠
  else if (star === '女') {
    name = '女土蝠';
    qiYaoType = 'tu';
    if (eventName === '嫁娶纳妾') {
      level = 'neutral';
      reason = '原文“婚姻嫁娶：平平”，婚姻类事体表现中性。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：损人口，六畜”，造葬事体应尽量回避。';
    } else if (eventName === '求名考试') {
      level = 'neutral';
      reason = '原文“求名：有阻”，在求名考试上有一定阻碍。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四水时吉”，适当时间下有利财务与交易。';
    }
  }
  // 虚日鼠
  else if (star === '虚') {
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
  }
  // 危月燕
  else if (star === '危') {
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
  }
  // 室火猪
  else if (star === '室') {
    name = '室火猪';
    qiYaoType = 'huo';
    if (eventName === '嫁娶纳妾') {
      level = 'greatGood';
      reason = '原文“婚姻：嫁娶大吉”，婚姻事体十分有利。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：凶，损六畜，遭火灾”，造葬相关事体应严格回避。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：四金时就”，适宜时机有利于财务与交易。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：四木时吉”，对履新、仕途发展有帮助。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“造屋：吉，寅午戌进横财”，修造事体有利财运。';
    }
  }
  // 壁水渝
  else if (star === '壁') {
    name = '壁水渝';
    qiYaoType = 'shui';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“婚姻嫁娶：吉”，适合作为婚姻类事体的偏吉配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：吉，申子年入财马”，造葬相关事体具备一定财运意味。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：用土时吉”，适当条件下有利仕途。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“造屋：吉，主入北方田地”，与修造及田宅相关事体相契合。';
    }
  }
  // 奎木狼
  else if (star === '奎') {
    name = '奎木狼';
    qiYaoType = 'mu';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：吉，宜春夏”，婚姻类事体在合宜季节尤佳。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：吉，主人田”，造葬与田宅收益相关。';
    } else if (eventName === '求名考试') {
      level = 'good';
      reason = '原文“谋望：功名可遂，大吉”，可视为求名类事体的佳选。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：用四火时吉”，有利于履新及职位提升。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“造宅：大吉，主有财”，修造类事体与财运相辅。';
    }
  }
  // 娄金狗
  else if (star === '娄') {
    name = '娄金狗';
    qiYaoType = 'jin';
    if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：进人口、金银”，造葬相关事体偏向增益。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：吉，巳酉丑年生贵子”，修造类事体有利后代。';
    }
  }
  // 胃土雉
  else if (star === '胃') {
    name = '胃土雉';
    qiYaoType = 'tu';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：吉”，婚姻类事体表现良好。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：吉”，造葬相关事体可视为偏吉。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四水时及卯时吉”，财务与交易在合适时机下较为有利。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：吉”，修造类事体有正向支撑。';
    }
  }
  // 昴日鸡
  else if (star === '昴') {
    name = '昴日鸡';
    qiYaoType = 'ri';
    if (eventName === '嫁娶纳妾') {
      level = 'greatGood';
      reason = '原文“婚姻：大吉”，可视为婚姻事体的强力利好配置。';
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
  }
  // 毕月乌
  else if (star === '毕') {
    name = '毕月乌';
    qiYaoType = 'yue';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“婚姻：金水男女命吉”，在合适命局下婚姻偏吉。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：用四木宿吉”，造葬事体在合适条件下有利。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四金宿及寅时吉”，财务与交易活动具备一定优势。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：吉”，适合履新与官职变动。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：用四金时得财”，修造事体有财运支撑。';
    }
  }
  // 觜火猴
  else if (star === '觜') {
    name = '觜火猴';
    qiYaoType = 'huo';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“婚姻：不利”，婚姻类事体应尽量回避。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：凶”，造葬相关事体有明显不利。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：四金时吉”，在适宜时机下利于财物与交易。';
    } else if (eventName === '求名考试') {
      level = 'neutral';
      reason = '原文“求名：可谋”，整体可谋但并非特别突出。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：四水时吉”，在特定条件下利于履新。';
    } else if (eventName === '造宅修建') {
      level = 'bad';
      reason = '原文“起造：凶”，修造类事体不宜。';
    }
  }
  // 参水猿
  else if (star === '参') {
    name = '参水猿';
    qiYaoType = 'shui';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“嫁娶：凶”，婚姻类事体需谨慎或回避。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：凶”，造葬类事体不宜使用。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：四火宿、四金宿时吉”，适宜条件下利于财务与交易。';
    } else if (eventName === '求名考试') {
      level = 'good';
      reason = '原文“求名：利、就”，求名类事体有较好前景。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：升，授品秩”，利于官职晋升。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：申子辰生贵子”，修造类事体与后代福泽相关。';
    }
  }
  // 井木犴
  else if (star === '井') {
    name = '井木犴';
    qiYaoType = 'mu';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶和合”，适合作为婚姻类事体的调和配置。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：凶”，在造葬相关事体中宜视为明显不宜使用的配置。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四土宿吉”，在适宜条件下有利于财务与经营活动。';
    }
  }
  // 鬼金羊
  else if (star === '鬼') {
    name = '鬼金羊';
    qiYaoType = 'jin';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“嫁娶：相刑不利”，适合作为婚姻类事体的明显规避提示。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：吉”，在造葬相关事体中可视为偏吉配置。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四木时吉”，在适宜时间条件下有利于与财物相关的活动。';
    } else if (eventName === '上官赴任') {
      level = 'bad';
      reason = '原文“赴任：不吉”，在履新、上官类事体上宜加强风险意识。';
    }
  }
  // 柳土獐
  else if (star === '柳') {
    name = '柳土獐';
    qiYaoType = 'tu';
    if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬起造：皆凶”，造葬及修造事体应尽量回避。';
    } else if (eventName === '造宅修建') {
      level = 'bad';
      reason = '原文“埋葬起造：皆凶”，修造相关事体不宜使用。';
    }
  }
  // 星日马
  else if (star === '星') {
    name = '星日马';
    qiYaoType = 'ri';
    if (eventName === '嫁娶纳妾') {
      level = 'good';
      reason = '原文“嫁娶：和合，吉”，婚姻类事体表现良好。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：不利”，提示造葬相关事体宜谨慎或回避。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“求财：用四金及午时吉”，利于财务与交易活动。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：有擢高升”，有利于职位晋升。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：大吉”，修造类事体具有较强利好。';
    }
  }
  // 张月鹿
  else if (star === '张') {
    name = '张月鹿';
    qiYaoType = 'yue';
    if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：周年生贵子”，造葬事体与后代福泽相关。';
    } else if (eventName === '行商贸易') {
      level = 'good';
      reason = '原文“出行：远去，主有财”“求财：四火时及寅时”，整体利于财富相关活动。';
    } else if (eventName === '上官赴任') {
      level = 'good';
      reason = '原文“上官赴任：吉利”，有利于官职与职责变动。';
    } else if (eventName === '求名考试') {
      level = 'good';
      reason = '原文“功名：壬癸亥子年成就”，在合适时机利于求名。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：三年内喜色临，吉”，修造事体与喜庆之事相关。';
    }
  }
  // 翼火蛇
  else if (star === '翼') {
    name = '翼火蛇';
    qiYaoType = 'huo';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“嫁娶：凶”，婚姻类事体宜回避。';
    } else if (eventName === '埋葬安葬') {
      level = 'bad';
      reason = '原文“埋葬：损人丁”，造葬相关事体不宜。';
    } else if (eventName === '求名考试') {
      level = 'bad';
      reason = '原文“求名：不遂”，在求名类事体上多有不顺。';
    } else if (eventName === '行商贸易') {
      level = 'bad';
      reason = '原文“求财：难有”，整体不利于财务与交易。';
    } else if (eventName === '造宅修建') {
      level = 'bad';
      reason = '原文“起造：主失火”，修造类事体存在较大风险。';
    }
  }
  // 轸水蚓
  else if (star === '轸') {
    name = '轸水蚓';
    qiYaoType = 'shui';
    if (eventName === '嫁娶纳妾') {
      level = 'bad';
      reason = '原文“嫁娶：不利”，婚姻类事体应谨慎或回避。';
    } else if (eventName === '埋葬安葬') {
      level = 'good';
      reason = '原文“埋葬：旺人口，六畜”，造葬相关事体在一定程度上有利人丁。';
    } else if (eventName === '行商贸易') {
      level = 'bad';
      reason = '原文“求财：不利”，提示财务与交易事体不佳。';
    } else if (eventName === '上官赴任') {
      level = 'bad';
      reason = '原文“上官赴任：失位”，不利于职责和职位稳定。';
    } else if (eventName === '造宅修建') {
      level = 'good';
      reason = '原文“起造：进人口，吉”，修造类事体与人口增加关联。';
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
