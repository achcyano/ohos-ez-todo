import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

interface TodoItemData {
  id: string;
  name: string;
  ddl: number;
  isFinished: boolean;
  notice: boolean;
}

interface FormData {
  todoList: TodoItemData[];
  totalCount: number;
  finishedCount: number;
  unfinishedCount: number;
  dateText: string;
}

export default class TodoFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData. FormBindingData {
    const formId = this.getFormId(want);
    console.info(`TodoFormAbility onAddForm, formId: ${formId}`);

    const formData = this.getTodayTodoData();
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    console. info(`TodoFormAbility onCastToNormalForm, formId: ${formId}`);
  }

  onUpdateForm(formId: string): void {
    console.info(`TodoFormAbility onUpdateForm, formId: ${formId}`);

    const formData = this.getTodayTodoData();
    const bindingData = formBindingData.createFormBindingData(formData);

    formProvider.updateForm(formId, bindingData)
      .then((): void => {
        console.info('Update form success');
      })
      .catch((err: BusinessError): void => {
        console.error(`Failed to update form.  Code: ${err.code}, message: ${err.message}`);
      });
  }

  onFormEvent(formId: string, message: string): void {
    console.info(`TodoFormAbility onFormEvent, formId: ${formId}, message: ${message}`);

    if (message === 'refresh') {
      this.onUpdateForm(formId);
    }
  }

  onRemoveForm(formId: string): void {
    console.info(`TodoFormAbility onRemoveForm, formId: ${formId}`);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private getFormId(want: Want): string {
    if (want.parameters === null || want.parameters === undefined) {
      return '';
    }
    const wantParams: Record<string, Object> = want.parameters as Record<string, Object>;
    const formIdValue: Object | undefined = wantParams[formInfo.FormParam.IDENTITY_KEY];
    if (formIdValue === undefined) {
      return '';
    }
    return formIdValue. toString();
  }

  private getTodayTodoData(): FormData {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate()). getTime();
    const endOfDay = startOfDay + 86400000 - 1;

    const month = today.getMonth() + 1;
    const day = today.getDate();
    const dateText: string = month. toString() + '月' + day.toString() + '日';

    let todoList: TodoItemData[] = [];
    let finishedCount = 0;

    try {
      const context = this.context;
      const options: preferences.Options = { name: 'todo_preferences' };
      const store = preferences.getPreferencesSync(context, options);
      const jsonStr = store.getSync('todo_list', '[]') as string;
      const allTodos: TodoItemData[] = JSON.parse(jsonStr) as TodoItemData[];

      // 筛选今日待办
      const filteredTodos: TodoItemData[] = [];
      for (let i = 0; i < allTodos.length; i++) {
        const item: TodoItemData = allTodos[i];
        if (item.ddl >= startOfDay && item. ddl <= endOfDay) {
          filteredTodos. push(item);
        }
      }
      todoList = filteredTodos;

      // 按完成状态和时间排序
      todoList.sort((a: TodoItemData, b: TodoItemData): number => {
        if (a.isFinished !== b.isFinished) {
          if (a.isFinished) {
            return 1;
          } else {
            return -1;
          }
        }
        return a.ddl - b.ddl;
      });

      // 统计已完成数量
      for (let i = 0; i < todoList.length; i++) {
        if (todoList[i]. isFinished) {
          finishedCount++;
        }
      }

      // 限制显示数量
      if (todoList. length > 5) {
        const limitedList: TodoItemData[] = [];
        for (let i = 0; i < 5; i++) {
          limitedList.push(todoList[i]);
        }
        todoList = limitedList;
      }
    } catch (err) {
      const error = err as BusinessError;
      console. error('Failed to get todo list: ' + error. message);
    }

    const result: FormData = {
      todoList: todoList,
      totalCount: todoList. length,
      finishedCount: finishedCount,
      unfinishedCount: todoList. length - finishedCount,
      dateText: dateText
    };

    return result;
  }
}