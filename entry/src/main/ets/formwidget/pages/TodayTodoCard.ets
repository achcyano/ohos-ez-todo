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

  @State dimension: string = '2*4';

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hour = date.getHours(). toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${hour}:${minute}`;
  }

  build() {
    Column() {
      if (this.dimension === '2*2') {
        this.SmallCard()
      } else if (this.dimension === '2*4') {
        this. MediumCard()
      } else {
        this.LargeCard()
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

  @Builder
  SmallCard() {
    Column() {
      Row() {
        Text('今日待办')
          .fontSize(14)
          .fontWeight(FontWeight. Medium)
          . fontColor('#1D1B20')
        Blank()
        Text(this.dateText)
          .fontSize(10)
          .fontColor('#49454F')
      }
      .width('100%')

      Blank()

      Column() {
        Text(this.unfinishedCount. toString())
          . fontSize(36)
          .fontWeight(FontWeight. Bold)
          . fontColor('#6750A4')
        Text('项未完成')
          .fontSize(12)
          .fontColor('#49454F')
      }

      Blank()

      Row() {
        Text(`已完成 ${this.finishedCount}/${this.totalCount}`)
          .fontSize(10)
          .fontColor('#49454F')
      }
      .width('100%')
    }
    . width('100%')
    .height('100%')
  }

  @Builder
  MediumCard() {
    Column() {
      Row() {
        Column() {
          Text('今日待办')
            .fontSize(16)
            .fontWeight(FontWeight. Medium)
            . fontColor('#1D1B20')
          Text(this.dateText)
            .fontSize(12)
            .fontColor('#49454F')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text(this. unfinishedCount.toString())
            .fontSize(28)
            .fontWeight(FontWeight. Bold)
            . fontColor('#6750A4')
          Text('项未完成')
            . fontSize(10)
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
        List() {
          ForEach(this. todoList. slice(0, 3), (item: TodoItemData) => {
            ListItem() {
              this.TodoItemRow(item)
            }
          }, (item: TodoItemData): string => item.id)
        }
        .width('100%')
        . layoutWeight(1)
      }
    }
    .width('100%')
    . height('100%')
  }

  @Builder
  LargeCard() {
    Column() {
      Row() {
        Column() {
          Text('今日待办')
            .fontSize(18)
            .fontWeight(FontWeight. Bold)
            .fontColor('#1D1B20')
          Text(this.dateText)
            . fontSize(14)
            .fontColor('#49454F')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Row() {
          Column() {
            Text(this.unfinishedCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight. Bold)
              . fontColor('#6750A4')
            Text('未完成')
              .fontSize(10)
              .fontColor('#49454F')
          }
          .margin({ right: 16 })

          Column() {
            Text(this.finishedCount.toString())
              .fontSize(24)
              .fontWeight(FontWeight. Bold)
              . fontColor('#4CAF50')
            Text('已完成')
              .fontSize(10)
              .fontColor('#49454F')
          }
        }
      }
      .width('100%')

      Divider()
        .color('#E8E0E8')
        . margin({ top: 12, bottom: 12 })

      if (this.todoList.length === 0) {
        Column() {
          Text('🎉')
            .fontSize(32)
          Text('今日暂无待办')
            . fontSize(16)
            .fontColor('#9E9E9E')
            .margin({ top: 8 })
          Text('点击添加新待办')
            .fontSize(12)
            .fontColor('#BDBDBD')
            .margin({ top: 4 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign. Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.todoList, (item: TodoItemData) => {
            ListItem() {
              this.TodoItemRow(item)
            }
          }, (item: TodoItemData): string => item.id)
        }
        . width('100%')
        .layoutWeight(1)
      }

      // 刷新按钮
      Row() {
        Text('点击刷新')
          .fontSize(10)
          .fontColor('#6750A4')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8 })
      .onClick((): void => {
        postCardAction(this, {
          action: 'message',
          params: { message: 'refresh' }
        });
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TodoItemRow(item: TodoItemData) {
    Row() {
      // 完成状态图标
      if (item.isFinished) {
        Row() {
          Text('✓')
            .fontSize(12)
            .fontColor('#FFFFFF')
        }
        .width(20)
        .height(20)
        .backgroundColor('#4CAF50')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)
      } else {
        Row()
          .width(20)
          .height(20)
          . border({ width: 2, color: '#6750A4' })
          .borderRadius(4)
      }

      // 待办信息
      Column() {
        Text(item.name)
          .fontSize(14)
          .fontColor(item.isFinished ? '#9E9E9E' : '#1D1B20')
          .decoration({ type: item.isFinished ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.formatTime(item.ddl))
          .fontSize(10)
          .fontColor(item.isFinished ? '#BDBDBD' : '#49454F')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })
    }
    .width('100%')
    .height(40)
    . backgroundColor('#FFFFFF')
    .borderRadius(8)
    .padding({ left: 8, right: 8 })
  }
}