import MyNavigation from '../navigation/NavBar';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer(){
      MyNavigation()
    }
  }
}