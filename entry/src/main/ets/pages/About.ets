import { common } from '@kit.AbilityKit';

@Component
export struct AboutPage {
  private githubUrl: string = 'https://github.com/achcyano';

  openUrl(url: string): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      context.openLink(url);
    } catch (err) {
      console.error('Failed to open URL: ' + JSON.stringify(err));
    }
  }

  @Builder
  buildGithubCard() {
    Row() {
      Row() {
        Image($r('app.media.code'))
          .width(20)
          .height(20)
          .fillColor('#FFFFFF')
      }
      .width(36)
      .height(36)
      .backgroundColor('#6750A4')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text('GitHub开发者主页')
          . fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1D1B20')

        Text('查看源代码和更多项目')
          .fontSize(12)
          .fontColor('#49454F')
          .margin({ top: 4 })
      }
      . alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      . layoutWeight(1)

      Image($r('app.media.arrow_right'))
        . width(20)
        .height(20)
        .fillColor('#49454F')
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick((): void => {
      this.openUrl(this.githubUrl);
    })
  }

  @Builder
  buildInfoCard(icon: Resource, iconColor: string, title: string, subtitle: string) {
    Row() {
      Row() {
        Image(icon)
          .width(20)
          .height(20)
          .fillColor('#FFFFFF')
      }
      .width(36)
      .height(36)
      .backgroundColor(iconColor)
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(title)
          .fontSize(16)
          . fontWeight(FontWeight.Medium)
          .fontColor('#1D1B20')

        Text(subtitle)
          .fontSize(12)
          .fontColor('#49454F')
          .margin({ top: 4 })
      }
      . alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    . width('100%')
    .height(72)
    . padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildSectionTitle(title: string) {
    Row() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight. Medium)
        . fontColor('#49454F')
    }
    .width('100%')
    .height(40)
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Image($r('app.media.startIcon'))
              .width(80)
              .height(80)
              .borderRadius(16)
          }
          .width(88)
          .height(88)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .shadow({
            radius: 8,
            color: '#1A000000',
            offsetX: 0,
            offsetY: 2
          })

          Text('TODO Manager')
            . fontSize(24)
            .fontWeight(FontWeight. Bold)
            . fontColor('#1D1B20')
            .margin({ top: 16 })

          Row() {
            Text('v0.1.0')
              .fontSize(12)
              .fontColor('#FFFFFF')
              . padding({ left: 8, right: 8, top: 4, bottom: 4 })
          }
          .backgroundColor('#6750A4')
          .borderRadius(12)
          . margin({ top: 8 })

          Text('一个简洁高效的待办事项管理应用')
            .fontSize(14)
            . fontColor('#49454F')
            . margin({ top: 12 })
        }
        .width('100%')
        . padding({ top: 32, bottom: 32 })
        .alignItems(HorizontalAlign.Center)

        Column() {
          this.buildSectionTitle('链接')
          this.buildGithubCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        Column() {
          this.buildSectionTitle('开发者信息')

          Column({ space: 12 }) {
            this.buildInfoCard(
              $r('app.media.person'),
              '#6750A4',
              '开发者',
              'AChCyano'
            )

            this.buildInfoCard(
              $r('app.media.code'),
              '#2196F3',
              '联系方式',
              'github.com/achcyano'
            )
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: 8 })

        Column() {
          this.buildSectionTitle('技术栈')

          Column({ space: 12 }) {
            this.buildInfoCard(
              $r('app.media.device'),
              '#4CAF50',
              '开发框架',
              'HarmonyOS ArkTS'
            )

            this.buildInfoCard(
              $r('app.media.info'),
              '#FF9800',
              '最低版本',
              'OpenHarmony API 12'
            )
          }
        }
        .width('100%')
        . padding({ left: 16, right: 16 })
        .margin({ top: 8 })

        Text('© 2025 AChCyano.  All Rights Reserved')
          .fontSize(12)
          .fontColor('#9E9E9E')
          .margin({ top: 32, bottom: 24 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    . height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState. Off)
    . backgroundColor('#F7F2FA')
  }
}