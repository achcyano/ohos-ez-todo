// PageTwo.ets
@Component
export struct AboutPage {
  @Consume('pageInfos') pageInfos: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Text("NavDestinationContent2")
      }.width('100%').height('100%')
    }.title("About")
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop();
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
  }
}