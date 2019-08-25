import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';
import '../models/auth_mode.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };

  final GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 700.0 : deviceWidth * .95;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _authFormKey,
              child: Container(
                width: targetWidth,
                child: Column(
                  children: <Widget>[
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _authMode == AuthMode.SignUp
                        ? _buildConfimPasswordTextField()
                        : Container(),
                    _buildAcceptSwitch(),
                    SizedBox(
                      height: 10.0,
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          _authMode = _authMode == AuthMode.Login
                              ? AuthMode.SignUp
                              : AuthMode.Login;
                        });
                      },
                      child: Text(
                          'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (BuildContext context, Widget child,
                          MainModel model) {
                        return model.isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                textColor: Colors.white,
                                child: Text(_authMode == AuthMode.Login
                                    ? 'LOGIN'
                                    : 'SIGNUP'),
                                onPressed: () =>
                                    _submitForm(model.authenticate));
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_authFormKey.currentState.validate() || !_formData['acceptTerms']) {
      return;
    }
    _authFormKey.currentState.save();
    Map<String, dynamic> successInfo = await authenticate(
        _formData['email'], _formData['password'], _authMode);

    if (successInfo['success']) {
      // Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An error occured'),
              content: Text(successInfo['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Accept the terms'),
      subtitle: Text('Don\'t worry you will like this terms'),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
        obscureText: true,
        controller: _passwordTextController,
        decoration: InputDecoration(
            labelText: 'Password',
            filled: true,
            fillColor: Colors.white.withOpacity(0.8)),
        onSaved: (String value) {
          _formData['password'] = value;
        },
        validator: (String value) {
          if (value.isEmpty || value.length <= 4) {
            return 'Please insert a valid password';
          }
        });
  }

  Widget _buildConfimPasswordTextField() {
    return TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            labelText: 'Confirm password',
            filled: true,
            fillColor: Colors.white.withOpacity(0.8)),
        validator: (String value) {
          if (_passwordTextController.text != value) {
            return 'passwords do not match!!';
          }
        });
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          labelText: 'Email',
          filled: true,
          fillColor: Colors.white.withOpacity(0.8)),
      onSaved: (String value) {
        _formData['email'] = value;
      },
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return "your email is not valid";
        }
      },
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        fit: BoxFit.cover,
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
        image: AssetImage('assets/background.jpg'));
  }
}
