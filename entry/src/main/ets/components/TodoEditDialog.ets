import { TodoItem, TodoItemInfo } from '../utils/PreferenceUtil';

@CustomDialog
export struct TodoEditDialog {
  controller: CustomDialogController;
  todoItem: TodoItem = new TodoItem({ id: '', name: '', ddl: Date.now(), isFinished: false, notice: false });
  onConfirm: (todo: TodoItem) => void = (): void => {};
  isNewTodo: boolean = false;

  @State tempName: string = '';
  @State tempDdl: number = 0;
  @State tempIsFinished: boolean = false;
  @State tempNotice: boolean = false;
  @State selectedDate: Date = new Date();

  aboutToAppear(): void {
    this.tempName = this.todoItem.name;
    this. tempDdl = this.todoItem. ddl;
    this.tempIsFinished = this.todoItem.isFinished;
    this. tempNotice = this.todoItem.notice;
    this. selectedDate = new Date(this.todoItem. ddl);
  }

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date. getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  build() {
    Column() {
      Text(this.isNewTodo ? '新建待办' : '编辑待办')
        .fontSize(20)
        .fontWeight(FontWeight. Bold)
        .margin({ bottom: 20 })

      // 名称输入
      Column() {
        Text('待办名称')
          .fontSize(14)
          .fontColor('#49454F')
          .width('100%')
        TextInput({ text: this.tempName, placeholder: '请输入待办名称' })
          .width('100%')
          .height(44)
          .margin({ top: 8 })
          . backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string): void => {
            this.tempName = value;
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 截止日期
      Column() {
        Text('截止日期')
          .fontSize(14)
          .fontColor('#49454F')
          .width('100%')
        Row() {
          Text(this.formatDate(this.tempDdl))
            .fontSize(16)
          Blank()
          Image($r('app.media.calendar'))
            .width(24)
            .height(24)
            .fillColor('#49454F')
        }
        .width('100%')
        .height(44)
        .padding({ left: 12, right: 12 })
        .margin({ top: 8 })
        .backgroundColor('#F5F5F5')
        . borderRadius(8)
        .onClick((): void => {
          DatePickerDialog. show({
            start: new Date('2020-1-1'),
            end: new Date('2030-12-31'),
            selected: this.selectedDate,
            onDateAccept: (value: Date): void => {
              this. selectedDate = value;
              this.tempDdl = value.getTime();
            }
          })
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 是否提醒
      Row() {
        Text('开启提醒')
          .fontSize(16)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this. tempNotice })
          .selectedColor('#6750A4')
          . onChange((isOn: boolean): void => {
            this.tempNotice = isOn;
          })
      }
      . width('100%')
      .height(48)

      // 是否已完成
      Row() {
        Text('已完成')
          .fontSize(16)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this. tempIsFinished })
          .selectedColor('#6750A4')
          .onChange((isOn: boolean): void => {
            this.tempIsFinished = isOn;
          })
      }
      . width('100%')
      .height(48)
      . margin({ bottom: 20 })

      // 按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor('#6750A4')
          . backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#6750A4' })
          .layoutWeight(1)
          . height(44)
          .onClick((): void => {
            this.controller.close();
          })

        Button('确定')
          .fontSize(16)
          .fontColor('#FFFFFF')
          . backgroundColor('#6750A4')
          . layoutWeight(1)
          .height(44)
          . margin({ left: 12 })
          . onClick((): void => {
            const info: TodoItemInfo = {
              id: this.todoItem. id,
              name: this.tempName,
              ddl: this.tempDdl,
              isFinished: this.tempIsFinished,
              notice: this.tempNotice
            };
            const updatedTodo = new TodoItem(info);
            this.onConfirm(updatedTodo);
            this.controller. close();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}