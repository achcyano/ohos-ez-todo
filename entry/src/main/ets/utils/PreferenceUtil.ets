import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const PREFERENCES_NAME = 'todo_preferences';
const TODO_KEY = 'todo_list';

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
    this.id = info. id;
    this.name = info. name;
    this.ddl = info.ddl;
    this.isFinished = info.isFinished;
    this.notice = info.notice;
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

export class PreferenceUtil {
  private static store: preferences.Preferences | null = null;

  static async init(context: common. UIAbilityContext): Promise<void> {
    try {
      PreferenceUtil.store = await preferences.getPreferences(context, PREFERENCES_NAME);
    } catch (err) {
      const error = err as BusinessError;
      console. error('Failed to get preferences: ' + error.message);
    }
  }

  static async getTodoList(): Promise<TodoItem[]> {
    if (!PreferenceUtil.store) {
      return [];
    }
    try {
      const jsonStr = await PreferenceUtil.store.get(TODO_KEY, '[]') as string;
      const infoList: TodoItemInfo[] = JSON.parse(jsonStr) as TodoItemInfo[];
      return infoList.map((info: TodoItemInfo) => new TodoItem(info));
    } catch (err) {
      const error = err as BusinessError;
      console.error('Failed to get todo list: ' + error.message);
      return [];
    }
  }

  static async saveTodoList(todoList: TodoItem[]): Promise<void> {
    if (! PreferenceUtil. store) {
      return;
    }
    try {
      const infoList: TodoItemInfo[] = todoList.map((item: TodoItem) => item.toInfo());
      await PreferenceUtil. store.put(TODO_KEY, JSON. stringify(infoList));
      await PreferenceUtil.store.flush();
    } catch (err) {
      const error = err as BusinessError;
      console.error('Failed to save todo list: ' + error.message);
    }
  }

  static async addTodo(todo: TodoItem): Promise<void> {
    const todoList = await PreferenceUtil.getTodoList();
    todoList. push(todo);
    await PreferenceUtil.saveTodoList(todoList);
  }

  static async updateTodo(todo: TodoItem): Promise<void> {
    const todoList = await PreferenceUtil.getTodoList();
    const index = todoList. findIndex((item: TodoItem) => item.id === todo. id);
    if (index !== -1) {
      todoList[index] = todo;
      await PreferenceUtil. saveTodoList(todoList);
    }
  }

  static async deleteTodo(id: string): Promise<void> {
    const todoList = await PreferenceUtil.getTodoList();
    const newList = todoList.filter((item: TodoItem) => item.id !== id);
    await PreferenceUtil.saveTodoList(newList);
  }

  static generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substring(2, 9);
  }
}