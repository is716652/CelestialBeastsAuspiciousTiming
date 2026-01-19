import { router } from '@kit.ArkUI';

@Entry
@Component
struct Splash {
  private timerId: number = -1;

  aboutToAppear(): void {
    // 6秒后自动跳转
    this.timerId = setTimeout(() => {
      this.goToIndex();
    }, 6000);
  }

  aboutToDisappear(): void {
    // 清除定时器
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
    }
  }

  private goToIndex(): void {
    router.replaceUrl({
      url: 'pages/Index'
    });
  }

  build() {
    Stack() {
      // 背景图片
      Image($rawfile('splash_bg.jpg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 底部提示文字
      Column() {
        Blank()
        Text('点击进入')
          .fontSize(16)
          .fontColor('#d4af37')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 60 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      // 点击立即进入
      if (this.timerId !== -1) {
        clearTimeout(this.timerId);
      }
      this.goToIndex();
    })
  }
}
