import { formProvider, formBindingData } from '@kit.FormKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';

interface TodoItemData {
  id: string;
  name: string;
  ddl: number;
  isFinished: boolean;
  notice: boolean;
}

interface StorageData {
  todoList: TodoItemData[];
  formIds: string[];
}

interface FormData {
  todoList: TodoItemData[];
  totalCount: number;
  finishedCount: number;
  unfinishedCount: number;
  dateText: string;
}

const FILE_NAME = 'todo_data.json';

export class FormUpdateUtil {
  private static getFilePath(context: common.Context): string {
    return context.filesDir + '/' + FILE_NAME;
  }

  private static readData(context: common.Context): StorageData {
    const defaultData: StorageData = {
      todoList: [],
      formIds: []
    };

    try {
      const filePath = FormUpdateUtil.getFilePath(context);
      const isExist = fileIo.accessSync(filePath);
      if (! isExist) {
        return defaultData;
      }

      const file = fileIo. openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo. statSync(filePath);
      const arrayBuffer = new ArrayBuffer(stat.size);
      fileIo.readSync(file. fd, arrayBuffer);
      fileIo.closeSync(file);

      const uint8Array = new Uint8Array(arrayBuffer);
      const content = buffer.from(uint8Array).toString('utf-8');
      const data: StorageData = JSON.parse(content) as StorageData;
      return data;
    } catch (err) {
      const error = err as BusinessError;
      console.error('FormUpdateUtil readData failed: ' + error.message);
      return defaultData;
    }
  }

  static getFormIds(context: common. Context): string[] {
    const data = FormUpdateUtil.readData(context);
    return data.formIds;
  }

  static updateAllForms(context: common.Context): void {
    const formIds = FormUpdateUtil.getFormIds(context);
    console.info('FormUpdateUtil updateAllForms, count: ' + formIds.length. toString());

    if (formIds.length === 0) {
      console.info('FormUpdateUtil no forms to update');
      return;
    }

    const formData = FormUpdateUtil.getTodayTodoData(context);
    const bindingData = formBindingData.createFormBindingData(formData);

    for (let i = 0; i < formIds. length; i++) {
      const formId = formIds[i];
      console.info('FormUpdateUtil updating form: ' + formId);

      formProvider.updateForm(formId, bindingData)
        .then((): void => {
          console.info('FormUpdateUtil update form success: ' + formId);
        })
        .catch((err: BusinessError): void => {
          console. error('FormUpdateUtil update form failed: ' + formId + ', code: ' + err. code. toString() + ', message: ' + err.message);
        });
    }
  }

  static getTodayTodoData(context: common.Context): FormData {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate()). getTime();
    const endOfDay = startOfDay + 86400000 - 1;

    const month = today.getMonth() + 1;
    const day = today.getDate();
    const dateText: string = month. toString() + '月' + day.toString() + '日';

    const storageData = FormUpdateUtil.readData(context);
    const allTodos = storageData.todoList;

    const filteredTodos: TodoItemData[] = [];
    for (let i = 0; i < allTodos.length; i++) {
      const item: TodoItemData = allTodos[i];
      if (item.ddl >= startOfDay && item.ddl <= endOfDay) {
        filteredTodos.push(item);
      }
    }

    filteredTodos.sort((a: TodoItemData, b: TodoItemData): number => {
      if (a.isFinished !== b.isFinished) {
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

    let displayList: TodoItemData[] = filteredTodos;
    if (filteredTodos.length > 5) {
      displayList = [];
      for (let i = 0; i < 5; i++) {
        displayList. push(filteredTodos[i]);
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