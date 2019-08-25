import 'package:flutter/material.dart';

class ProductCreatePage extends StatefulWidget {
  final Function addProduct;

  ProductCreatePage(this.addProduct);

  @override
  State<StatefulWidget> createState() {
    return _ProductCreatePageState();
  }
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              _buildTitleTextField(),
              _buildDescriptionTextField(),
              _buildPriceTextField(),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                textColor: Colors.white,
                child: Text('Save'),
                onPressed: () {
                  _submitForm();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _submitForm() {
    if (!_formkey.currentState.validate()) {
      return;
    }
    _formkey.currentState.save();
    widget.addProduct(_formData);
    Navigator.pushReplacementNamed(context, '/homepage');
  }

  Widget _buildPriceTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product price'),
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

  Widget _buildDescriptionTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product description'),
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

  Widget _buildTitleTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product title'),
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
