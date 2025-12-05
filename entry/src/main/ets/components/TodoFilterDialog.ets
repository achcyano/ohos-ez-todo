@CustomDialog
export struct TodoFilterDialog {
  controller: CustomDialogController;
  onConfirm: (filterType: number, weekDays: boolean[], startDate: number, endDate: number) => void = (): void => {};

  @State filterType: number = 0; // 0: 全部, 1: 按星期, 2: 按日期区间
  @State weekDays: boolean[] = [false, false, false, false, false, false, false]; // 周日到周六
  @State startDate: Date = new Date();
  @State endDate: Date = new Date();

  private weekDayNames: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  aboutToAppear(): void {
    const today = new Date();
    this.startDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    this.endDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7);
  }

  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  showStartDatePicker(): void {
    DatePickerDialog. show({
      start: new Date('2020-1-1'),
      end: new Date('2030-12-31'),
      selected: this.startDate,
      lunar: false,
      onDateAccept: (value: Date): void => {
        this.startDate = value;
        if (this.startDate. getTime() > this.endDate. getTime()) {
          this.endDate = new Date(this.startDate);
        }
      }
    });
  }

  showEndDatePicker(): void {
    DatePickerDialog.show({
      start: new Date('2020-1-1'),
      end: new Date('2030-12-31'),
      selected: this. endDate,
      lunar: false,
      onDateAccept: (value: Date): void => {
        if (value.getTime() >= this.startDate. getTime()) {
          this.endDate = value;
        }
      }
    });
  }

  build() {
    Column() {
      Text('筛选待办')
        .fontSize(20)
        . fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Column() {
        Text('筛选方式')
          . fontSize(14)
          .fontColor('#49454F')
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          ForEach(['全部', '按星期', '按日期'], (item: string, index: number) => {
            Row() {
              Radio({ value: item, group: 'filterType' })
                .checked(this.filterType === index)
                .onChange((isChecked: boolean): void => {
                  if (isChecked) {
                    this.filterType = index;
                  }
                })
              Text(item)
                .fontSize(14)
                .margin({ left: 4 })
            }
            .margin({ right: 16 })
          }, (item: string): string => item)
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.filterType === 1) {
        Column() {
          Text('选择星期')
            .fontSize(14)
            .fontColor('#49454F')
            .width('100%')
            .margin({ bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.weekDayNames, (day: string, index: number) => {
              Row() {
                Checkbox()
                  .select(this.weekDays[index])
                  .selectedColor('#6750A4')
                  .onChange((isChecked: boolean): void => {
                    this.weekDays[index] = isChecked;
                  })
                Text(day)
                  .fontSize(14)
                  . margin({ left: 4 })
              }
              .width('33%')
              .height(40)
            }, (day: string): string => day)
          }
          .width('100%')
        }
        .width('100%')
        . margin({ bottom: 16 })
      }

      if (this. filterType === 2) {
        Column() {
          Text('开始日期')
            .fontSize(14)
            .fontColor('#49454F')
            .width('100%')
          Row() {
            Text(this.formatDate(this.startDate))
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
          .borderRadius(8)
          .onClick((): void => {
            this.showStartDatePicker();
          })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Column() {
          Text('结束日期')
            .fontSize(14)
            .fontColor('#49454F')
            .width('100%')
          Row() {
            Text(this.formatDate(this.endDate))
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
          . margin({ top: 8 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick((): void => {
            this.showEndDatePicker();
          })
        }
        .width('100%')
        .margin({ bottom: 16 })
      }

      Row() {
        Button('取消')
          . fontSize(16)
          .fontColor('#6750A4')
          .backgroundColor('#FFFFFF')
          . border({ width: 1, color: '#6750A4' })
          .layoutWeight(1)
          .height(44)
          .onClick((): void => {
            this.controller.close();
          })

        Button('确定')
          .fontSize(16)
          .fontColor('#FFFFFF')
          . backgroundColor('#6750A4')
          . layoutWeight(1)
          .height(44)
          .margin({ left: 12 })
          . onClick((): void => {
            const weekDaysCopy: boolean[] = [];
            for (let i = 0; i < this.weekDays. length; i++) {
              weekDaysCopy.push(this.weekDays[i]);
            }
            this. onConfirm(
              this.filterType,
              weekDaysCopy,
              this.startDate. getTime(),
              this.endDate. getTime() + 86400000 - 1
            );
            this.controller.close();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    . borderRadius(16)
  }
}