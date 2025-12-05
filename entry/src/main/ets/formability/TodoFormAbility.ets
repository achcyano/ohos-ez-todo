import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
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

export default class TodoFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formId = this. getFormId(want);
    console.info('TodoFormAbility onAddForm: ' + formId);

    this.saveFormId(formId);

    const formData = this.getTodayTodoData();
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string): void {
    console. info('TodoFormAbility onCastToNormalForm: ' + formId);
  }

  onUpdateForm(formId: string): void {
    console.info('TodoFormAbility onUpdateForm: ' + formId);

    const formData = this.getTodayTodoData();
    const bindingData = formBindingData.createFormBindingData(formData);

    formProvider.updateForm(formId, bindingData)
      . then((): void => {
        console. info('TodoFormAbility updateForm success');
      })
      .catch((err: BusinessError): void => {
        console. error('TodoFormAbility updateForm failed: ' + err.message);
      });
  }

  onFormEvent(formId: string, message: string): void {
    console.info('TodoFormAbility onFormEvent: ' + formId + ', ' + message);
    if (message === 'refresh') {
      this.onUpdateForm(formId);
    }
  }

  onRemoveForm(formId: string): void {
    console.info('TodoFormAbility onRemoveForm: ' + formId);
    this.removeFormId(formId);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private getFormId(want: Want): string {
    if (want.parameters === null || want.parameters === undefined) {
      return '';
    }
    const wantParams: Record<string, Object> = want.parameters as Record<string, Object>;
    const formIdValue: Object | undefined = wantParams[formInfo.FormParam. IDENTITY_KEY];
    if (formIdValue === undefined) {
      return '';
    }
    return formIdValue.toString();
  }

  private getFilePath(): string {
    const extensionContext = this.context;
    return extensionContext.filesDir + '/' + FILE_NAME;
  }

  private readStorageData(): StorageData {
    const defaultData: StorageData = { todoList: [], formIds: [] };
    try {
      const filePath = this.getFilePath();
      let isExist = false;
      try {
        fileIo.accessSync(filePath);
        isExist = true;
      } catch (e) {
        isExist = false;
      }

      if (!isExist) {
        return defaultData;
      }

      const file = fileIo. openSync(filePath, fileIo. OpenMode.READ_ONLY);
      const stat = fileIo.statSync(filePath);
      const arrayBuffer = new ArrayBuffer(stat. size);
      fileIo.readSync(file.fd, arrayBuffer);
      fileIo.closeSync(file);

      const uint8Array = new Uint8Array(arrayBuffer);
      const content = buffer.from(uint8Array).toString('utf-8');
      const data: StorageData = JSON. parse(content) as StorageData;
      return data;
    } catch (err) {
      const error = err as BusinessError;
      console.error('TodoFormAbility readStorageData failed: ' + error.message);
      return defaultData;
    }
  }

  private writeStorageData(data: StorageData): void {
    try {
      const filePath = this.getFilePath();
      const content = JSON.stringify(data);
      const buf = buffer.from(content, 'utf-8');
      const uint8Array = new Uint8Array(buf.buffer);

      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, uint8Array. buffer);
      fileIo.closeSync(file);
    } catch (err) {
      const error = err as BusinessError;
      console. error('TodoFormAbility writeStorageData failed: ' + error.message);
    }
  }

  private saveFormId(formId: string): void {
    if (formId === '') {
      return;
    }
    const data = this.readStorageData();
    let exists = false;
    for (let i = 0; i < data.formIds.length; i++) {
      if (data.formIds[i] === formId) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      data. formIds.push(formId);
      this.writeStorageData(data);
      console.info('TodoFormAbility saveFormId: ' + formId);
    }
  }

  private removeFormId(formId: string): void {
    if (formId === '') {
      return;
    }
    const data = this.readStorageData();
    const newIds: string[] = [];
    for (let i = 0; i < data.formIds.length; i++) {
      if (data.formIds[i] !== formId) {
        newIds.push(data.formIds[i]);
      }
    }
    data.formIds = newIds;
    this.writeStorageData(data);
    console.info('TodoFormAbility removeFormId: ' + formId);
  }

  private getTodayTodoData(): FormData {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today. getMonth(), today. getDate()).getTime();
    const endOfDay = startOfDay + 86400000 - 1;

    const month = today.getMonth() + 1;
    const day = today.getDate();
    const dateText: string = month. toString() + '月' + day.toString() + '日';

    const storageData = this.readStorageData();
    const allTodos = storageData. todoList;

    const filteredTodos: TodoItemData[] = [];
    for (let i = 0; i < allTodos.length; i++) {
      const item = allTodos[i];
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
    for (let i = 0; i < filteredTodos. length; i++) {
      if (filteredTodos[i].isFinished) {
        finishedCount++;
      }
    }

    const totalCount = filteredTodos. length;

    let displayList: TodoItemData[] = filteredTodos;
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