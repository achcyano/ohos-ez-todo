import { TodoItem, TodoItemInfo, PreferenceUtil } from '../utils/PreferenceUtil';
import { TodoEditDialog } from '../components/TodoEditDialog';
import { TodoSection } from '../components/TodoSection';
import common from '@ohos.app.ability.common';

interface FilterState {
  filterType: number;
  weekDays: boolean[];
  startDate: number;
  endDate: number;
}

@Component
export struct TodosPage {
  @State todoList: TodoItem[] = [];
  @State filteredList: TodoItem[] = [];
  @State unfinishedList: TodoItem[] = [];
  @State finishedList: TodoItem[] = [];
  @State currentTodo: TodoItem = new TodoItem({
    id: '',
    name: '',
    ddl: Date. now(),
    isFinished: false,
    notice: false
  });
  @State isNewTodo: boolean = true;
  @State filterText: string = '';

  @Consume('todoFilter') @Watch('onFilterChange') todoFilter: FilterState;

  private dialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.initPreferences();
  }

  onFilterChange(): void {
    this.applyFilter();
  }

  async initPreferences(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await PreferenceUtil. init(context);
    await this.loadTodoList();
  }

  async loadTodoList(): Promise<void> {
    const list = await PreferenceUtil.getTodoList();
    this.todoList = list;
    this.applyFilter();
  }

  applyFilter(): void {
    if (this.todoFilter.filterType === 0) {
      this.filteredList = this.todoList;
      this.filterText = '';
    } else if (this.todoFilter.filterType === 1) {
      this. filteredList = this.todoList.filter((item: TodoItem): boolean => {
        const dayOfWeek = new Date(item.ddl). getDay();
        return this.todoFilter.weekDays[dayOfWeek];
      });
      this.filterText = this.getWeekFilterText();
    } else if (this.todoFilter. filterType === 2) {
      this.filteredList = this.todoList. filter((item: TodoItem): boolean => {
        return item. ddl >= this. todoFilter.startDate && item.ddl <= this.todoFilter. endDate;
      });
      this. filterText = this. getDateRangeFilterText();
    }
    this. updateFilteredLists();
  }

  getWeekFilterText(): string {
    const weekDayNames: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const selected: string[] = [];
    for (let i = 0; i < this.todoFilter.weekDays.length; i++) {
      if (this.todoFilter.weekDays[i]) {
        selected.push(weekDayNames[i]);
      }
    }
    if (selected.length === 0) {
      return '';
    }
    return selected.join('、');
  }

  getDateRangeFilterText(): string {
    const startDate = new Date(this.todoFilter.startDate);
    const endDate = new Date(this.todoFilter.endDate);
    const formatDate = (date: Date): string => {
      const month = (date.getMonth() + 1).toString(). padStart(2, '0');
      const day = date. getDate().toString(). padStart(2, '0');
      return `${month}-${day}`;
    };
    return `${formatDate(startDate)} 至 ${formatDate(endDate)}`;
  }

  updateFilteredLists(): void {
    this.unfinishedList = this.filteredList.filter((item: TodoItem) => !item.isFinished);
    this.finishedList = this.filteredList.filter((item: TodoItem) => item.isFinished);
  }

  showEditDialog(todo: TodoItem, isNew: boolean): void {
    this.currentTodo = todo;
    this.isNewTodo = isNew;

    this. dialogController = new CustomDialogController({
      builder: TodoEditDialog({
        todoItem: this.currentTodo,
        isNewTodo: this.isNewTodo,
        onConfirm: async (updatedTodo: TodoItem): Promise<void> => {
          if (this.isNewTodo) {
            await PreferenceUtil. addTodo(updatedTodo);
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
    await this.loadTodoList();
  }

  async handleDelete(id: string): Promise<void> {
    await PreferenceUtil. deleteTodo(id);
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

  clearFilter(): void {
    this.todoFilter = {
      filterType: 0,
      weekDays: [false, false, false, false, false, false, false],
      startDate: 0,
      endDate: 0
    };
  }

  build() {
    Stack() {
      Column() {
        // 筛选提示条
        if (this. todoFilter.filterType !== 0 && this.filterText !== '') {
          Row() {
            Image($r('app.media.filter'))
              .width(16)
              .height(16)
              .fillColor('#6750A4')
            Text(this.filterText)
              . fontSize(12)
              .fontColor('#6750A4')
              .margin({ left: 8 })
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text('清除')
              .fontSize(12)
              . fontColor('#6750A4')
              .fontWeight(FontWeight.Medium)
              .onClick((): void => {
                this.clearFilter();
              })
          }
          .width('100%')
          .height(36)
          .padding({ left: 16, right: 16 })
          . backgroundColor('#F3EDF7')
        }

        Scroll() {
          Column() {
            // 未完成列表
            if (this.unfinishedList.length > 0) {
              TodoSection({
                title: '未完成',
                todoList: $unfinishedList,
                onToggleFinish: (todo: TodoItem): void => {
                  this. handleToggleFinish(todo);
                },
                onEdit: (todo: TodoItem): void => {
                  this. handleEdit(todo);
                },
                onDelete: (id: string): void => {
                  this.handleDelete(id);
                }
              })
                . margin({ bottom: 16 })
            }

            // 已完成列表
            if (this.finishedList.length > 0) {
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
                  this. handleDelete(id);
                }
              })
            }

            // 空状态
            if (this.filteredList.length === 0) {
              Column() {
                Image($r('app.media.empty'))
                  . width(120)
                  .height(120)
                  .opacity(0.5)
                Text(this.todoFilter.filterType === 0 ? '暂无待办事项' : '没有符合条件的待办')
                  .fontSize(16)
                  .fontColor('#9E9E9E')
                  .margin({ top: 16 })
                Text(this.todoFilter.filterType === 0 ? '点击右下角按钮添加' : '尝试调整筛选条件')
                  .fontSize(14)
                  . fontColor('#BDBDBD')
                  .margin({ top: 8 })
              }
              .width('100%')
              . height(300)
              .justifyContent(FlexAlign.Center)
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState. Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign. Start)

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
      .translate({ x: -72, y: -72 })
      . onClick((): void => {
        this. handleAddTodo();
      })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopStart)
    . backgroundColor('#F7F2FA')
  }
}