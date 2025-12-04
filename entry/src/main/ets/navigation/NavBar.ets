import { AboutPage } from "../pages/About";
import { TodosPage } from "../pages/Todos";
import { SettingsPage } from "../pages/Settings";

interface NavItem {
  name: string;
  icon: Resource;
  label: string;
  title: string;
}

@Entry
@Component
struct MyNavigation {
  @State currentIndex: number = 0
  @State isInSettings: boolean = false
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  private navItems: NavItem[] = [
    {
      name: "Todos",
      icon: $r('app.media.home'),
      label: "待办",
      title: "待办事项"
    },
    {
      name: "About",
      icon: $r('app.media.info'),
      label: "关于",
      title: "关于我们"
    }
  ]

  @Builder
  PageMap(name: string) {
    if (name === "Settings") {
      SettingsPage()
    }
  }

  @Builder
  NavigationBarItem(index: number) {
    Column() {
      Stack() {
        if (this.currentIndex === index) {
          Row()
            .width(64)
            .height(32)
            .backgroundColor('#E8DEF8')
            .borderRadius(16)
        }
        Image(this.navItems[index].icon)
          .width(24)
          .height(24)
          .fillColor(this.currentIndex === index ? '#1D1B20' : '#49454F')
      }
      .width(64)
      .height(32)

      Text(this.navItems[index].label)
        .fontSize(12)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? '#1D1B20' : '#49454F')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index
    })
  }

  @Builder
  ContentPage() {
    if (this.currentIndex === 0) {
      TodosPage()
    } else if (this.currentIndex === 1) {
      AboutPage()
    }
  }

  getCurrentTitle(): string {
    if (this.isInSettings) {
      return "设置"
    }
    return this.navItems[this.currentIndex].title
  }

  build() {
    Column() {
      Navigation(this.pageInfos) {
        Column() {
          this.ContentPage()
        }
        .width('100%')
        .layoutWeight(1)
      }
      .title(this.getCurrentTitle())
      .titleMode(NavigationTitleMode. Mini)
      .mode(NavigationMode. Stack)
      .navDestination(this.PageMap)
      . hideToolBar(true)
      . hideBackButton(! this.isInSettings)
      .menus([
        {
          value: '',
          icon: $r('app.media.setting'),
          action: () => {
            this.isInSettings = true
            this.pageInfos.pushPath({ name: 'Settings' })
          }
        }
      ])
      .onNavBarStateChange((isVisible: boolean) => {
        if (isVisible) {
          this.isInSettings = false
        }
      })
      .layoutWeight(1)

      Row() {
        ForEach(this. navItems, (item: NavItem, index: number) => {
          Column() {
            this.NavigationBarItem(index)
          }
          .layoutWeight(1)
          .height('100%')
        }, (item: NavItem) => item.name)
      }
      .width('100%')
      . height(80)
      .backgroundColor('#FFFFFF')
      . shadow({
        radius: 8,
        color: '#14000000',
        offsetX: 0,
        offsetY: -2
      })
      .padding({ bottom: 12 })
      .visibility(this.isInSettings ? Visibility. None : Visibility. Visible)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F7F2FA')
  }
}

export default MyNavigation