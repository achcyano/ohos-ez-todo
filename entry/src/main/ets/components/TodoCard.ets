import { TodoItem } from '../utils/PreferenceUtil';

@Component
export struct TodoCard {
  @ObjectLink todoItem: TodoItem;
  onToggleFinish: (todo: TodoItem) => void = (): void => {};
  onEdit: (todo: TodoItem) => void = (): void => {};
  onDelete: (id: string) => void = (): void => {};

  @State offsetX: number = 0;

  aboutToAppear(): void {
    this.offsetX = 0;
  }

  formatDateTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString(). padStart(2, '0');
    return `${month}-${day} ${hour}:${minute}`;
  }

  isOverdue(): boolean {
    return ! this.todoItem. isFinished && this.todoItem.ddl < Date.now();
  }

  build() {
    Stack() {
      if (this.offsetX < 0) {
        Row() {
          Blank()
          Column() {
            Image($r('app.media.delete'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
            Text('删除')
              .fontSize(12)
              .fontColor('#FFFFFF')
              . margin({ top: 4 })
          }
          .width(80)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FF4444')
          . onClick((): void => {
            this.onDelete(this.todoItem.id);
          })
        }
        . width('100%')
        .height('100%')
      }

      Row() {
        Column() {
          if (this.todoItem.isFinished) {
            Row() {
              Image($r('app.media.check'))
                .width(16)
                .height(16)
                .fillColor('#FFFFFF')
            }
            .width(24)
            .height(24)
            .backgroundColor('#6750A4')
            .borderRadius(4)
            . justifyContent(FlexAlign.Center)
          } else {
            Row()
              .width(24)
              . height(24)
              .border({ width: 2, color: '#6750A4' })
              .borderRadius(4)
          }
        }
        .width(48)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick((): void => {
          this.todoItem.isFinished = !this.todoItem.isFinished;
          this. onToggleFinish(this.todoItem);
        })

        Column() {
          Text(this.todoItem.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.todoItem. isFinished ? '#9E9E9E' : '#1D1B20')
            .decoration({ type: this.todoItem.isFinished ? TextDecorationType.LineThrough : TextDecorationType. None })
            . maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(this.formatDateTime(this.todoItem.ddl))
              .fontSize(12)
              . fontColor(this. isOverdue() ?  '#FF4444' : '#49454F')

            if (this. todoItem.notice) {
              Image($r('app.media.notice'))
                .width(14)
                .height(14)
                .fillColor('#49454F')
                .margin({ left: 8 })
            }
          }
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        . alignItems(HorizontalAlign.Start)
        .padding({ right: 16 })
        .onClick((): void => {
          this.onEdit(this.todoItem);
        })
      }
      .width('100%')
      .height(72)
      .backgroundColor('#FFFFFF')
      . borderRadius(12)
      .translate({ x: this.offsetX })
      . gesture(
        PanGesture({ direction: PanDirection. Horizontal })
          .onActionUpdate((event: GestureEvent): void => {
            if (event.offsetX < 0) {
              this.offsetX = Math.max(event.offsetX, -80);
            } else if (this. offsetX < 0) {
              this.offsetX = Math.min(this. offsetX + event. offsetX, 0);
            }
          })
          . onActionEnd((): void => {
            if (this.offsetX < -40) {
              this. offsetX = -80;
            } else {
              this. offsetX = 0;
            }
          })
      )
      .animation({ duration: 200, curve: Curve. EaseOut })
    }
    . width('100%')
    .height(72)
    . clip(true)
    .borderRadius(12)
  }
}