import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> products = [
    {
      "image": "assets/2.png", // Добавлено изображение для предпросмотра
      "name": "Original",
      "color": "The one and only CactUs!",
      "price": "\◊ 0.02",
      "url": "https://opensea.io/assets/ethereum/0x3dbf429288b5e65fb5bcd8bc35fcfb24e9bba91a/1"
    },
    {
      "image": "assets/1.png",
      "name": "Cool",
      "color": "He is cool! I promise...",
      "price": "\◊ 0.005",
      "url": "https://opensea.io/assets/ethereum/0x3dbf429288b5e65fb5bcd8bc35fcfb24e9bba91a/2"
    },
    {
      "image": "assets/4.png",
      "name": "Zombie",
      "color": "He is dead... I guess...",
      "price": "\◊ 0.01",
      "url": "https://opensea.io/assets/ethereum/0x3dbf429288b5e65fb5bcd8bc35fcfb24e9bba91a/3"
    },
    {
      "image": "assets/3.png",
      "name": "Pirate",
      "color": "Yo Ho a pirate's life for me",
      "price": "✎ Make offer",
      "url": "https://opensea.io/assets/ethereum/0x3dbf429288b5e65fb5bcd8bc35fcfb24e9bba91a/4"
    },
  ];

  List<Map<String, String>> filteredProducts = [];
  int selectedIndex = 0;
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products); // Изначально показываем все товары
  }

  void _filterProducts(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "Expensive first") {
        // Сортировка от дорогих к дешёвым
        filteredProducts = products.where((product) {
          return product["price"] != "✎ Make offer"; // Исключаем товары без цены
        }).toList();
        filteredProducts.sort((a, b) {
          double? priceA = _parsePrice(a["price"]);
          double? priceB = _parsePrice(b["price"]);
          return priceB!.compareTo(priceA!); // Дорогие сверху
        });
      } else if (filter == "Cheap first") {
        // Сортировка от дешёвых к дорогим
        filteredProducts = products.where((product) {
          return product["price"] != "✎ Make offer"; // Исключаем товары без цены
        }).toList();
        filteredProducts.sort((a, b) {
          double? priceA = _parsePrice(a["price"]);
          double? priceB = _parsePrice(b["price"]);
          return priceA!.compareTo(priceB!); // Дешевые сверху
        });
      } else if (filter == "No price") {
        // Показываем только товары без цены (пиратский кактус)
        filteredProducts = products.where((product) {
          return product["price"] == "✎ Make offer";
        }).toList();
      } else if (filter == "Reset filters") {
        // Сбрасываем фильтры, показываем все товары
        filteredProducts = List.from(products);
      }
    });
  }

  double? _parsePrice(String? price) {
    if (price == null || price.contains("Make offer")) return null;
    return double.tryParse(price.replaceAll(RegExp(r"[^\d.]"), ""));
  }

  // Обновление метода отображения изображения с улучшенной отладочной информацией
  String _getDisplayImage(Map<String, String> product, double screenWidth) {
    try {
      print('Проверка размера экрана: $screenWidth <= 800 = ${screenWidth <= 800}');
      // Всегда используем стандартное изображение для маленьких экранов
      if (screenWidth <= 800 || !product.containsKey('preview_image')) {
        return product['image']!;
      }
      
      // Для больших экранов всегда используем preview
      return 'assets/${product['preview_image']}';
    } catch (e) {
      print('Ошибка в _getDisplayImage: $e');
      return product['image']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: DropdownButton<String>(
          dropdownColor: Colors.black,
          value: selectedFilter,
          onChanged: (value) {
            if (value != null) _filterProducts(value);
          },
          items: [
            DropdownMenuItem(value: "All", child: Text("All", style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: "Expensive first", child: Text("Expensive first", style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: "Cheap first", child: Text("Cheap first", style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: "No price", child: Text("No price", style: TextStyle(color: Colors.white))),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              _showWalletDialog(context);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final screenWidth = MediaQuery.of(context).size.width;
          
          print('Текущая ширина экрана: $screenWidth');
          print('Выбранный индекс: $selectedIndex');
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: maxHeight * 0.4, // 40% от высоты экрана
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 0), // Убираем анимацию для мгновенного переключения
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Container(
                        key: ValueKey<String>(_getDisplayImage(filteredProducts[selectedIndex], screenWidth)),
                        width: double.infinity,
                        height: maxHeight * 0.4, // Фиксированная высота для всех экранов
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: ClipRect(  // Добавляем ClipRect, чтобы изображение оставалось в пределах
                          child: _buildImage(_getDisplayImage(filteredProducts[selectedIndex], screenWidth)),
                        ),
                      ),
                    ),
                    // Градиентный наложение
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Позиционирование текста и кнопки остается прежним
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 70, // Добавляем отступ справа для FAB
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cactus",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            filteredProducts[selectedIndex]['name']!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        onPressed: _launchOpenSea,
                        backgroundColor: Color(0xFF669966),
                        child: Icon(Icons.shopping_bag_outlined, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: ProductCard(
                        image: filteredProducts[index]['image']!,
                        name: filteredProducts[index]['name']!,
                        color: filteredProducts[index]['color']!,
                        price: filteredProducts[index]['price']!,
                        isSelected: index == selectedIndex,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _launchOpenSea() async {
    final selectedUrl = filteredProducts[selectedIndex]["url"]!;
    if (await canLaunch(selectedUrl)) {
      await launch(selectedUrl);
    } else {
      throw 'Не удалось запустить $selectedUrl';
    }
  }

  void _showWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Сканируйте для подключения MetaMask'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: QrImageView(
              data: "ethereum:0xd648C0E1bb2e2E45684bC06cE2ceBaa5DEb03C92",
              size: 200.0,
            ),
          ),
          actions: [
            TextButton(
              child: Text("Закрыть"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage(String imagePath) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            imagePath,
            fit: screenWidth > 800 ? BoxFit.fill : BoxFit.contain,
            alignment: Alignment.center,
            // Убираем errorBuilder с fallback на стандартное изображение
            errorBuilder: (context, error, stackTrace) {
              print('Ошибка загрузки изображения: $error');
              return Container(
                color: Colors.black,
                child: Center(
                  child: Icon(Icons.error_outline, color: Colors.white),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String color;
  final String price;
  final bool isSelected;

  const ProductCard({
    required this.image,
    required this.name,
    required this.color,
    required this.price,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Восстановлена фиксированная ширина
            height: 100, // Восстановлена фиксированная высота
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: Color(0xFF669966), width: 2)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  color,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
