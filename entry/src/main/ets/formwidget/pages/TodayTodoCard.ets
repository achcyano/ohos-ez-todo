interface TodoItemData {
  id: string;
  name: string;
  ddl: number;
  isFinished: boolean;
  notice: boolean;
}

@Entry
@Component
struct TodayTodoCard {
  @LocalStorageProp('todoList') todoList: TodoItemData[] = [];
  @LocalStorageProp('totalCount') totalCount: number = 0;
  @LocalStorageProp('finishedCount') finishedCount: number = 0;
  @LocalStorageProp('unfinishedCount') unfinishedCount: number = 0;
  @LocalStorageProp('dateText') dateText: string = '';

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hour = date.getHours(). toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return hour + ':' + minute;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('今日待办')
            .fontSize(16)
            .fontWeight(FontWeight. Medium)
            .fontColor('#1D1B20')
          Text(this.dateText)
            . fontSize(12)
            .fontColor('#49454F')
            . margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text(this.unfinishedCount. toString())
            . fontSize(28)
            .fontWeight(FontWeight. Bold)
            . fontColor('#6750A4')
          Text('项未完成')
            .fontSize(10)
            .fontColor('#49454F')
        }
      }
      .width('100%')

      Divider()
        .color('#E8E0E8')
        .margin({ top: 8, bottom: 8 })

      if (this.todoList.length === 0) {
        Column() {
          Text('今日暂无待办')
            .fontSize(14)
            .fontColor('#9E9E9E')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 6 }) {
          ForEach(this. todoList, (item: TodoItemData) => {
            ListItem() {
              Row() {
                if (item.isFinished) {
                  Row() {
                    Text('✓')
                      . fontSize(12)
                      . fontColor('#FFFFFF')
                  }
                  .width(20)
                  .height(20)
                  .backgroundColor('#6750A4')
                  .borderRadius(4)
                  . justifyContent(FlexAlign.Center)
                } else {
                  Row()
                    .width(20)
                    .height(20)
                    .border({ width: 2, color: '#6750A4' })
                    .borderRadius(4)
                }

                Column() {
                  Text(item.name)
                    .fontSize(13)
                    . fontColor(item.isFinished ?  '#9E9E9E' : '#1D1B20')
                    .decoration({ type: item.isFinished ?  TextDecorationType.LineThrough : TextDecorationType.None })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Text(this.formatTime(item.ddl))
                    . fontSize(10)
                    . fontColor(item.isFinished ? '#BDBDBD' : '#49454F')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 8 })
              }
              .width('100%')
              .height(40)
              .backgroundColor('#FFFFFF')
              . borderRadius(8)
              .padding({ left: 8, right: 8 })
            }
          }, (item: TodoItemData): string => {
            const finishedFlag = item.isFinished ? '1' : '0';
            return item.id + '_' + finishedFlag;
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F2FA')
    .borderRadius(16)
    .padding(12)
    .onClick((): void => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: { targetPage: 'todos' }
      });
    })
  }
}