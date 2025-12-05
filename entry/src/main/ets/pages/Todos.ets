import { TodoItem, TodoItemInfo, PreferenceUtil } from '../utils/PreferenceUtil';
import { TodoEditDialog } from '../components/TodoEditDialog';
import { TodoSection } from '../components/TodoSection';
import common from '@ohos.app.ability.common';

@Component
export struct TodosPage {
  @State todoList: TodoItem[] = [];
  @State unfinishedList: TodoItem[] = [];
  @State finishedList: TodoItem[] = [];
  @State currentTodo: TodoItem = new TodoItem({
    id: '',
    name: '',
    ddl: Date.now(),
    isFinished: false,
    notice: false
  });
  @State isNewTodo: boolean = true;

  private dialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.initPreferences();
  }

  async initPreferences(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await PreferenceUtil. init(context);
    await this.loadTodoList();
  }

  async loadTodoList(): Promise<void> {
    const list = await PreferenceUtil.getTodoList();
    this.todoList = list;
    this.updateFilteredLists();
  }

  updateFilteredLists(): void {
    this.unfinishedList = this.todoList. filter((item: TodoItem) => ! item.isFinished);
    this. finishedList = this.todoList. filter((item: TodoItem) => item. isFinished);
  }

  showEditDialog(todo: TodoItem, isNew: boolean): void {
    this.currentTodo = todo;
    this.isNewTodo = isNew;

    this.dialogController = new CustomDialogController({
      builder: TodoEditDialog({
        todoItem: this.currentTodo,
        isNewTodo: this.isNewTodo,
        onConfirm: async (updatedTodo: TodoItem): Promise<void> => {
          if (this.isNewTodo) {
            await PreferenceUtil.addTodo(updatedTodo);
          } else {
            await PreferenceUtil.updateTodo(updatedTodo);
          }
          await this.loadTodoList();
        }
      }),
      alignment: DialogAlignment.Center,
      customStyle: true
    });

    this.dialogController.open();
  }

  async handleToggleFinish(todo: TodoItem): Promise<void> {
    await PreferenceUtil.updateTodo(todo);
    await this. loadTodoList();
  }

  async handleDelete(id: string): Promise<void> {
    await PreferenceUtil.deleteTodo(id);
    await this.loadTodoList();
  }

  handleEdit(todo: TodoItem): void {
    this.showEditDialog(todo, false);
  }

  handleAddTodo(): void {
    const info: TodoItemInfo = {
      id: PreferenceUtil.generateId(),
      name: '',
      ddl: Date.now() + 86400000,
      isFinished: false,
      notice: false
    };
    const newTodo = new TodoItem(info);
    this.showEditDialog(newTodo, true);
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column() {
            // 未完成列表
            if (this. unfinishedList.length > 0) {
              TodoSection({
                title: '未完成',
                todoList: $unfinishedList,
                onToggleFinish: (todo: TodoItem): void => {
                  this.handleToggleFinish(todo);
                },
                onEdit: (todo: TodoItem): void => {
                  this.handleEdit(todo);
                },
                onDelete: (id: string): void => {
                  this.handleDelete(id);
                }
              })
                .margin({ bottom: 16 })
            }

            // 已完成列表
            if (this. finishedList. length > 0) {
              TodoSection({
                title: '已完成',
                todoList: $finishedList,
                onToggleFinish: (todo: TodoItem): void => {
                  this.handleToggleFinish(todo);
                },
                onEdit: (todo: TodoItem): void => {
                  this.handleEdit(todo);
                },
                onDelete: (id: string): void => {
                  this.handleDelete(id);
                }
              })
            }

            // 空状态
            if (this.todoList.length === 0) {
              Column() {
                Image($r('app.media.empty'))
                  .width(120)
                  . height(120)
                  .opacity(0.5)
                Text('暂无待办事项')
                  . fontSize(16)
                  . fontColor('#9E9E9E')
                  .margin({ top: 16 })
                Text('点击右下角按钮添加')
                  .fontSize(14)
                  .fontColor('#BDBDBD')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
            }
          }
          . width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })
        }
        .width('100%')
        .height('100%')
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      . height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      // 悬浮添加按钮
      Button() {
        Image($r('app.media.add'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
      }
      .width(56)
      . height(56)
      .backgroundColor('#6750A4')
      .borderRadius(16)
      . shadow({
        radius: 8,
        color: '#406750A4',
        offsetX: 0,
        offsetY: 4
      })
      .position({ x: '100%', y: '100%' })
      . translate({ x: -72, y: -72 })
      .onClick((): void => {
        this.handleAddTodo();
      })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
    . backgroundColor('#F7F2FA')
  }
}