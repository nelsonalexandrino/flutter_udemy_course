import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../scoped_models/main.dart';
import '../widgets/form_input/image.dart';

class ProductEditPage extends StatefulWidget {
  /* final Function addProduct;
  final Function updateProduct;
  final Product product;
  final int productIndex;

  ProductEditPage(
      {this.addProduct, this.updateProduct, this.product, this.productIndex}); */

  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': null
  };

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit product'),
                ),
                body: pageContent,
              );
      },
    );
  }

  GestureDetector _buildPageContent(BuildContext context, Product product) {
    final double deviceWidh = MediaQuery.of(context).size.width;
    final double targetWith = deviceWidh > 550 ? 500.0 : deviceWidh * .95;
    final double targetPadding = deviceWidh - targetWith;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formkey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(
                height: 10.0,
              ),
              ImageInput(_setImage, product),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                textColor: Colors.white,
                child: Text('Save'),
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  _submitForm(
      Function addProduct, Function updateProduct, Function selectProductIndex,
      [int selectedProductIndex]) {
    if (!_formkey.currentState.validate() ||
        (_formData['image'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formkey.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct(_titleTextController.text, _descriptionTextController.text,
              _formData['image'], _formData['price'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/homepage')
              .then((_) => selectProductIndex(null));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Algo não correu bem'),
                  content: Text('Por favor tente mais uma vez'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateProduct(_titleTextController.text, _descriptionTextController.text,
              _formData['image'], _formData['price'])
          .then((_) => {
                Navigator.pushReplacementNamed(context, '/homepage')
                    .then((_) => selectProductIndex(null))
              });
    }
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      focusNode: _priceFocusNode,
      decoration: InputDecoration(labelText: 'Product price'),
      initialValue: product == null ? '' : product.price.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onSaved: (String value) {
        /* setState(() {
          _priceValue = double.parse(value);
        }); */
        _formData['price'] = double.parse(value);
      },
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return "Price is requeried and should be a number";
        }
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    if (product == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (product != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = product.description;
    }

    return TextFormField(
      focusNode: _descriptionFocusNode,
      decoration: InputDecoration(labelText: 'Product description'),
      //initialValue: product == null ? '' : product.description,
      controller: _descriptionTextController,
      maxLines: 4,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return "Please say more something";
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildTitleTextField(Product product) {
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    }

    return TextFormField(
      focusNode: _titleFocusNode,
      decoration: InputDecoration(labelText: 'Product title'),
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return "Title is required";
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }
}
