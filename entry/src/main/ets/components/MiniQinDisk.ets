// 演禽微缩盘组件
// 用于在案例库或提示卡片中展示简化的三传与落宫信息

export interface MiniPalaceData {
  branch: string;
  env: string;
  star?: string;
}

export interface MiniThreePassData {
  chu: string;
  chuColor: string;
  zhong: string;
  zhongColor: string;
  mo: string;
  moColor: string;
}

@Component
export struct MiniQinDisk {
  @Prop threePass: MiniThreePassData;
  @Prop palaces: Array<MiniPalaceData>;

  @Builder
  ThreePassItem(label: string, star: string, bgColor: string) {
    Column() {
      Text(label)
        .fontSize(9)
        .fontColor('#888888')
      Column() {
        Text(star)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(bgColor)
      .borderRadius(18)
      .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  PalaceItem(item: MiniPalaceData) {
    Column() {
      Row() {
        Text(item.branch)
          .fontSize(10)
          .fontColor('#ffffff')
          .fontWeight(FontWeight.Bold)
        Text(item.env)
          .fontSize(9)
          .fontColor('#ffffffcc')
          .margin({ left: 2 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1a5276')
      .padding({ top: 2, bottom: 2 })

      if (item.star) {
        Text(item.star)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#c62828')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height(44)
    .backgroundColor('#ffffff')
    .border({ width: 0.5, color: '#dddddd' })
  }

  build() {
    Row() {
      // 左侧：三传小图
      Column() {
        Text('【三传概览】')
          .fontSize(10)
          .fontColor('#555555')
          .margin({ bottom: 8 })
        Row() {
          this.ThreePassItem('初传', this.threePass.chu, this.threePass.chuColor)
          Text('→').fontSize(12).fontColor('#cccccc').margin({ left: 4, right: 4, top: 12 })
          this.ThreePassItem('中传', this.threePass.zhong, this.threePass.zhongColor)
          Text('→').fontSize(12).fontColor('#cccccc').margin({ left: 4, right: 4, top: 12 })
          this.ThreePassItem('末传', this.threePass.mo, this.threePass.moColor)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 右侧：锁泊小图 (2x2网格)
      Column() {
        Text('【关键落宫】')
          .fontSize(10)
          .fontColor('#555555')
          .margin({ bottom: 8 })
        Grid() {
          ForEach(this.palaces, (item: MiniPalaceData) => {
            GridItem() {
              this.PalaceItem(item)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(2)
        .rowsGap(2)
        .width(100)
        .height(90)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
  }
}
