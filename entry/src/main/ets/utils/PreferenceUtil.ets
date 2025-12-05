import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { formProvider, formBindingData } from '@kit.FormKit';
import { SharedDataUtil } from './SharedDataUtil';

export interface TodoItemInfo {
  id: string;
  name: string;
  ddl: number;
  isFinished: boolean;
  notice: boolean;
}

@Observed
export class TodoItem {
  id: string;
  name: string;
  ddl: number;
  isFinished: boolean;
  notice: boolean;

  constructor(info: TodoItemInfo) {
    this.id = info.id;
    this.name = info.name;
    this.ddl = info.ddl;
    this.isFinished = info.isFinished;
    this. notice = info.notice;
  }

  toInfo(): TodoItemInfo {
    return {
      id: this. id,
      name: this.name,
      ddl: this.ddl,
      isFinished: this.isFinished,
      notice: this.notice
    };
  }
}

interface FormTodoData {
  id: string;
  name: string;
  ddl: number;
  isFinished: boolean;
  notice: boolean;
}

interface FormData {
  todoList: FormTodoData[];
  totalCount: number;
  finishedCount: number;
  unfinishedCount: number;
  dateText: string;
}

export class PreferenceUtil {
  private static appContext: common.UIAbilityContext | null = null;

  static getContext(): common.UIAbilityContext | null {
    return PreferenceUtil. appContext;
  }

  static init(context: common. UIAbilityContext): void {
    PreferenceUtil. appContext = context;
    console.info('PreferenceUtil init success');
  }

  static getTodoList(): TodoItem[] {
    if (PreferenceUtil. appContext === null) {
      return [];
    }
    try {
      const dataList = SharedDataUtil. getTodoList(PreferenceUtil. appContext);
      const result: TodoItem[] = [];
      for (let i = 0; i < dataList. length; i++) {
        const info: TodoItemInfo = {
          id: dataList[i].id,
          name: dataList[i]. name,
          ddl: dataList[i].ddl,
          isFinished: dataList[i].isFinished,
          notice: dataList[i].notice
        };
        result.push(new TodoItem(info));
      }
      return result;
    } catch (err) {
      const error = err as BusinessError;
      console.error('PreferenceUtil getTodoList failed: ' + error.message);
      return [];
    }
  }

  static saveTodoList(todoList: TodoItem[]): void {
    if (PreferenceUtil.appContext === null) {
      return;
    }
    try {
      const dataList: TodoItemInfo[] = [];
      for (let i = 0; i < todoList.length; i++) {
        dataList.push(todoList[i]. toInfo());
      }
      SharedDataUtil.saveTodoList(PreferenceUtil.appContext, dataList);
      console.info('PreferenceUtil saveTodoList success, count: ' + todoList.length. toString());

      PreferenceUtil.updateAllForms();
    } catch (err) {
      const error = err as BusinessError;
      console.error('PreferenceUtil saveTodoList failed: ' + error. message);
    }
  }

  static addTodo(todo: TodoItem): void {
    const todoList = PreferenceUtil.getTodoList();
    todoList.push(todo);
    PreferenceUtil.saveTodoList(todoList);
  }

  static updateTodo(todo: TodoItem): void {
    const todoList = PreferenceUtil.getTodoList();
    for (let i = 0; i < todoList.length; i++) {
      if (todoList[i].id === todo. id) {
        todoList[i] = todo;
        break;
      }
    }
    PreferenceUtil. saveTodoList(todoList);
  }

  static deleteTodo(id: string): void {
    const todoList = PreferenceUtil. getTodoList();
    const newList: TodoItem[] = [];
    for (let i = 0; i < todoList.length; i++) {
      if (todoList[i]. id !== id) {
        newList. push(todoList[i]);
      }
    }
    PreferenceUtil. saveTodoList(newList);
  }

  static generateId(): string {
    return Date.now().toString() + Math.random(). toString(36).substring(2, 9);
  }

  private static updateAllForms(): void {
    if (PreferenceUtil.appContext === null) {
      return;
    }

    const formIds = SharedDataUtil.getFormIds(PreferenceUtil.appContext);
    console.info('PreferenceUtil updateAllForms, count: ' + formIds.length.toString());

    if (formIds.length === 0) {
      return;
    }

    const formData = PreferenceUtil.buildFormData();
    const bindingData = formBindingData. createFormBindingData(formData);

    for (let i = 0; i < formIds.length; i++) {
      const formId = formIds[i];
      formProvider.updateForm(formId, bindingData)
        .then((): void => {
          console.info('PreferenceUtil updateForm success: ' + formId);
        })
        .catch((err: BusinessError): void => {
          console.error('PreferenceUtil updateForm failed: ' + formId + ', ' + err.message);
          if (err.code === 16501001 || err.code === 16501000) {
            if (PreferenceUtil.appContext !== null) {
              SharedDataUtil.removeFormId(PreferenceUtil.appContext, formId);
            }
          }
        });
    }
  }

  private static buildFormData(): FormData {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate()). getTime();
    const endOfDay = startOfDay + 86400000 - 1;

    const month = today. getMonth() + 1;
    const day = today.getDate();
    const dateText: string = month. toString() + '月' + day.toString() + '日';

    const todoList = PreferenceUtil. getTodoList();

    const filteredTodos: FormTodoData[] = [];
    for (let i = 0; i < todoList.length; i++) {
      const item = todoList[i];
      if (item.ddl >= startOfDay && item.ddl <= endOfDay) {
        filteredTodos.push({
          id: item.id,
          name: item.name,
          ddl: item.ddl,
          isFinished: item.isFinished,
          notice: item.notice
        });
      }
    }

    filteredTodos.sort((a: FormTodoData, b: FormTodoData): number => {
      if (a.isFinished !== b. isFinished) {
        if (a.isFinished) {
          return 1;
        }
        return -1;
      }
      return a.ddl - b.ddl;
    });

    let finishedCount = 0;
    for (let i = 0; i < filteredTodos.length; i++) {
      if (filteredTodos[i]. isFinished) {
        finishedCount++;
      }
    }

    const totalCount = filteredTodos.length;

    let displayList: FormTodoData[] = filteredTodos;
    if (filteredTodos.length > 5) {
      displayList = [];
      for (let i = 0; i < 5; i++) {
        displayList.push(filteredTodos[i]);
      }
    }

    const result: FormData = {
      todoList: displayList,
      totalCount: totalCount,
      finishedCount: finishedCount,
      unfinishedCount: totalCount - finishedCount,
      dateText: dateText
    };

    return result;
  }
}