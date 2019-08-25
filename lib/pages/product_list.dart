import 'package:flutter/material.dart';
import './product_edit.dart';
import '../scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class ProducListPage extends StatefulWidget {
  final MainModel model;
  ProducListPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProducListPage> {
  @override
  void initState() {
    widget.model.fetchProducts(onlyForUser: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              onDismissed: (DismissDirection direction) {
                model.selectProduct(model.allProducts[index].id);
                if (direction == DismissDirection.endToStart) {
                  model.deleteProduct();
                } else if (direction == DismissDirection.startToEnd) {
                  print('Start to end');
                } else {
                  print('other swiping');
                }
              },
              key: Key(model.allProducts[index].title),
              background: Container(
                color: Colors.red,
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(model.allProducts[index].image)),
                    title: Text(model.allProducts[index].title),
                    subtitle:
                        Text('${model.allProducts[index].price.toString()} MT'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider()
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.allProducts[index].id);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext contect) {
            return ProductEditPage();
          },
        )).then((_) {
          model.selectProduct(null);
        });
      },
    );
  }
}
