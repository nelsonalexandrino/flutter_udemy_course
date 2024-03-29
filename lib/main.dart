import 'package:flutter/material.dart';
import './models/product.dart';
import 'package:flutter_udemy_course/scoped_models/main.dart';
//import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/product_admin.dart';
import './pages/products_page.dart';
import './pages/product_details.dart';

void main() {
  //debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  //MapView.setApiKey('AIzaSyCOoySAoufxVVB0BEbRmrVftFhPDwLEzOM');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('building main page');
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          fontFamily: 'Bitter',
          buttonColor: Colors.deepPurple,
        ),
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductsPage(_model),
          //'/homepage': (BuildContext context) => ProductsPage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductAdminPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });

            return MaterialPageRoute<bool>(
                builder: (BuildContext context) =>
                    !_isAuthenticated ? AuthPage() : ProductDetails(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? AuthPage() : ProductsPage(_model));
        },
      ),
    );
  }
}
