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

const FILE_NAME = 'todo_data.json';

export class SharedDataUtil {
  private static getFilePath(context: common.Context): string {
    const filesDir = context.filesDir;
    return filesDir + '/' + FILE_NAME;
  }

  static readData(context: common. Context): StorageData {
    const defaultData: StorageData = {
      todoList: [],
      formIds: []
    };

    try {
      const filePath = SharedDataUtil.getFilePath(context);
      const isExist = fileIo.accessSync(filePath);
      if (!isExist) {
        return defaultData;
      }

      const file = fileIo. openSync(filePath, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo. statSync(filePath);
      const arrayBuffer = new ArrayBuffer(stat. size);
      fileIo.readSync(file. fd, arrayBuffer);
      fileIo.closeSync(file);

      const uint8Array = new Uint8Array(arrayBuffer);
      const content = buffer.from(uint8Array). toString('utf-8');
      const data: StorageData = JSON.parse(content) as StorageData;
      return data;
    } catch (err) {
      const error = err as BusinessError;
      console.error('SharedDataUtil readData failed: ' + error.message);
      return defaultData;
    }
  }

  static writeData(context: common.Context, data: StorageData): void {
    const filePath = SharedDataUtil.getFilePath(context);

    try {
      const content = JSON.stringify(data);
      const buf = buffer.from(content, 'utf-8');
      const uint8Array = new Uint8Array(buf. buffer);

      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(file.fd, uint8Array. buffer);
      fileIo.closeSync(file);
      console.info('SharedDataUtil writeData success');
    } catch (err) {
      const error = err as BusinessError;
      console.error('SharedDataUtil writeData failed: ' + error.message);
    }
  }

  static getTodoList(context: common. Context): TodoItemData[] {
    const data = SharedDataUtil.readData(context);
    return data.todoList;
  }

  static saveTodoList(context: common.Context, todoList: TodoItemData[]): void {
    const data = SharedDataUtil.readData(context);
    data.todoList = todoList;
    SharedDataUtil. writeData(context, data);
  }

  static getFormIds(context: common. Context): string[] {
    const data = SharedDataUtil.readData(context);
    return data.formIds;
  }

  static addFormId(context: common.Context, formId: string): void {
    if (formId === '') {
      return;
    }
    const data = SharedDataUtil.readData(context);
    let exists = false;
    for (let i = 0; i < data.formIds. length; i++) {
      if (data.formIds[i] === formId) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      data.formIds.push(formId);
      SharedDataUtil.writeData(context, data);
      console.info('SharedDataUtil addFormId: ' + formId);
    }
  }

  static removeFormId(context: common.Context, formId: string): void {
    if (formId === '') {
      return;
    }
    const data = SharedDataUtil.readData(context);
    const newFormIds: string[] = [];
    for (let i = 0; i < data. formIds.length; i++) {
      if (data.formIds[i] !== formId) {
        newFormIds. push(data.formIds[i]);
      }
    }
    data.formIds = newFormIds;
    SharedDataUtil.writeData(context, data);
    console.info('SharedDataUtil removeFormId: ' + formId);
  }
}