@Component
export struct SettingsPage {
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    NavDestination() {
      Column() {
        List({ space: 12 }) {
          ListItem() {
            Row() {
              Text('通知设置')
                . fontSize(16)
              Blank()
              Image($r('app.media.arrow_right'))
                .width(20)
                .height(20)
                .fillColor('#49454F')
            }
            .width('100%')
            .height(56)
            . padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }

          ListItem() {
            Row() {
              Text('主题设置')
                . fontSize(16)
              Blank()
              Image($r('app.media.arrow_right'))
                .width(20)
                .height(20)
                . fillColor('#49454F')
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          }

          ListItem() {
            Row() {
              Text('关于应用')
                . fontSize(16)
              Blank()
              Text('v1.0.0')
                .fontSize(14)
                .fontColor('#49454F')
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
            . backgroundColor('#FFFFFF')
            .borderRadius(12)
          }
        }
        .width('90%')
        . margin({ top: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F7F2FA')
    }
    .title('设置')
  }
}