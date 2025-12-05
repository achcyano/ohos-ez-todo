import { TodoItem } from '../utils/PreferenceUtil';
import { TodoCard } from './TodoCard';

@Component
export struct TodoSection {
  title: string = '';
  @Link todoList: TodoItem[];
  onToggleFinish: (todo: TodoItem) => void = (): void => {};
  onEdit: (todo: TodoItem) => void = (): void => {};
  onDelete: (id: string) => void = (): void => {};

  @State isExpanded: boolean = true;

  build() {
    Column() {
      // 标题栏
      Row() {
        Text(this.title)
          .fontSize(14)
          .fontWeight(FontWeight. Medium)
          .fontColor('#49454F')

        Text(`(${this.todoList.length})`)
          .fontSize(14)
          .fontColor('#9E9E9E')
          .margin({ left: 4 })

        Blank()

        Image($r('app.media.arrow_down'))
          .width(20)
          .height(20)
          .fillColor('#49454F')
          .rotate({ angle: this.isExpanded ?  0 : -90 })
          .animation({ duration: 300, curve: Curve.EaseInOut })
      }
      .width('100%')
      .height(40)
      .onClick((): void => {
        this.isExpanded = !this. isExpanded;
      })

      // 列表内容
      if (this.isExpanded) {
        Column({ space: 12 }) {
          ForEach(this. todoList, (item: TodoItem) => {
            TodoCard({
              todoItem: item,
              onToggleFinish: this.onToggleFinish,
              onEdit: this. onEdit,
              onDelete: this. onDelete
            })
          }, (item: TodoItem): string => item.id)
        }
        .width('100%')
        .transition(
          TransitionEffect. OPACITY.combine(
            TransitionEffect.translate({ y: -20 })
          ). animation({ duration: 300, curve: Curve. EaseInOut })
        )
      }
    }
    .width('100%')
  }
}