import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget é a raiz da sua aplicação.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Este é o tema do seu aplicativo.

        // EXPERIMENTE: Tente executar seu aplicativo com "flutter run". Você verá
        // que o aplicativo tem uma barra de ferramentas roxa. Em seguida, sem fechar o aplicativo,
        // tente alterar a cor seedColor no colorScheme abaixo para Colors.green
        // e então invoque o "hot reload" (salve suas alterações ou pressione o botão "hot
        // reload" em uma IDE compatível com Flutter, ou pressione "r" se você usou
        // a linha de comando para iniciar o aplicativo).

        // Observe que o contador não foi zerado; o estado do aplicativo
        // não é perdido durante a recarga. Para redefinir o estado, use o hot
        // restart.

        // Isso também funciona para código, não apenas para valores: A maioria das alterações de código pode ser
        // testada apenas com um hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
// Este widget é a página inicial do seu aplicativo. Ele é stateful, o que significa
// que possui um objeto State (definido abaixo) que contém campos que afetam
// sua aparência.

// Esta classe é a configuração do estado. Ela contém os valores (neste
// caso, o título) fornecidos pelo widget pai (neste caso, o widget App) e
// usados ​​pelo método build do State. Os campos em uma subclasse de Widget são
// sempre marcados como "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // Esta chamada a setState informa ao framework Flutter que algo
      // mudou neste estado, o que faz com que ele execute novamente o método build abaixo
      // para que a exibição possa refletir os valores atualizados. Se alterássemos
      // _counter sem chamar setState(), o método build não seria
      // chamado novamente e, portanto, nada pareceria acontecer.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Este método é executado novamente toda vez que setState é chamado, por exemplo, como feito
    // pelo método _incrementCounter acima.
    //
    // O framework Flutter foi otimizado para tornar a execução novamente dos métodos de build
    // rápida, para que você possa apenas reconstruir qualquer coisa que precise ser atualizada, em vez
    // de ter que alterar individualmente as instâncias dos widgets.
    return Scaffold(
      appBar: AppBar(
        // TENTE ISSO: Tente alterar a cor aqui para uma cor específica (para
        // Colors.amber, talvez?) e acione um hot reload para ver a AppBar
        // mudar de cor enquanto as outras cores permanecem as mesmas.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Aqui pegamos o valor do objeto MyHomePage que foi criado pelo
        // método App.build e o usamos para definir o título da nossa appbar.
        title: Text(widget.title),
      ),
      body: Center(
        // Center é um widget de layout. Ele pega um único filho e o posiciona
        // no meio do pai.
        child: Column(
            // Column também é um widget de layout. Ele pega uma lista de filhos e
            // os organiza verticalmente. Por padrão, ele se dimensiona para caber em seus
            // filhos horizontalmente e tenta ser tão alto quanto seu pai.
            //
            // Column tem várias propriedades para controlar como ele se dimensiona e
            // como posiciona seus filhos. Aqui usamos mainAxisAlignment para
            // centralizar os filhos verticalmente; o eixo principal aqui é o vertical
            // porque as Colunas são verticais (o eixo cruzado seria horizontal).
            //
            // TENTE ISSO: Invoque "debug painting" (escolha a ação "Toggle Debug Paint"
            // na IDE, ou pressione "p" no console), para ver a
            // estrutura de cada widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Você pressionou o botão esta quantidade de vezes:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // Esta vírgula final torna a formatação automática mais agradável para métodos de construção.
    );
  }
}
