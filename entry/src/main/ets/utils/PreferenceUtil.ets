import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

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
    this. id = info.id;
    this. name = info.name;
    this. ddl = info. ddl;
    this.isFinished = info.isFinished;
    this.notice = info. notice;
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
  private static preferences: dataPreferences. Preferences | null = null;

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PreferenceUtil.preferences = await dataPreferences. getPreferences(context, PREFERENCES_NAME);
    } catch (err) {
      console.error('Failed to get preferences: ' + JSON.stringify(err));
    }
  }

  static async getTodoList(): Promise<TodoItem[]> {
    if (!PreferenceUtil.preferences) {
      return [];
    }
    try {
      const jsonStr = await PreferenceUtil.preferences. get(TODO_KEY, '[]') as string;
      const infoList: TodoItemInfo[] = JSON.parse(jsonStr) as TodoItemInfo[];
      return infoList.map((info: TodoItemInfo) => new TodoItem(info));
    } catch (err) {
      console.error('Failed to get todo list: ' + JSON. stringify(err));
      return [];
    }
  }

  static async saveTodoList(todoList: TodoItem[]): Promise<void> {
    if (! PreferenceUtil. preferences) {
      return;
    }
    try {
      const infoList: TodoItemInfo[] = todoList.map((item: TodoItem) => item.toInfo());
      await PreferenceUtil.preferences.put(TODO_KEY, JSON.stringify(infoList));
      await PreferenceUtil. preferences.flush();
    } catch (err) {
      console.error('Failed to save todo list: ' + JSON. stringify(err));
    }
  }

  static async addTodo(todo: TodoItem): Promise<void> {
    const todoList = await PreferenceUtil.getTodoList();
    todoList.push(todo);
    await PreferenceUtil. saveTodoList(todoList);
  }

  static async updateTodo(todo: TodoItem): Promise<void> {
    const todoList = await PreferenceUtil.getTodoList();
    const index = todoList.findIndex((item: TodoItem) => item.id === todo.id);
    if (index !== -1) {
      todoList[index] = todo;
      await PreferenceUtil.saveTodoList(todoList);
    }
  }

  static async deleteTodo(id: string): Promise<void> {
    const todoList = await PreferenceUtil.getTodoList();
    const newList = todoList. filter((item: TodoItem) => item. id !== id);
    await PreferenceUtil.saveTodoList(newList);
  }

  static generateId(): string {
    return Date.now().toString() + Math.random(). toString(36).substring(2, 9);
  }
}